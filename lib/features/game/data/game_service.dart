import 'dart:math' as math;

import 'package:stopwatch_game/core/api/api_exception.dart';
import 'package:stopwatch_game/core/api/stopwatch_api.dart';
import 'package:stopwatch_game/core/config/api_config.dart';
import 'package:stopwatch_game/core/config/env_config.dart';
import 'package:stopwatch_game/features/game/data/models/billing_transaction_request.dart';
import 'package:stopwatch_game/features/game/data/models/billing_transaction_response.dart';
import 'package:stopwatch_game/features/game/data/models/game_history_response.dart';
import 'package:stopwatch_game/features/game/data/models/game_start_response.dart';
import 'package:stopwatch_game/features/game/data/models/start_game_request.dart';
import 'package:stopwatch_game/features/game/data/models/stop_game_request.dart';
import 'package:stopwatch_game/features/game/data/models/target_time_request.dart';
import 'package:stopwatch_game/features/game/data/models/target_time_response.dart';

export 'package:stopwatch_game/core/api/api_exception.dart' show ApiException;

/// Gameplay and billing workflows.
class GameService {
  GameService({StopwatchApi? api}) : _api = api ?? StopwatchApi.create();

  factory GameService.create({StopwatchApi? api}) => GameService(api: api);

  final StopwatchApi _api;

  Future<BillingTransactionResponse> enqueueBilling({required String msisdn}) =>
      _postBillingTransaction(msisdn: msisdn);

  Future<BillingTransactionResponse> getBillingStatus({
    required String requestId,
  }) => _fetchBillingStatus(requestId);

  /// Polls until billing succeeds, fails, or [EnvConfig.billingPollTimeout] elapses.
  ///
  /// Uses **exponential backoff with jitter** between attempts (starts at
  /// [EnvConfig.billingPollInterval], capped by [EnvConfig.billingPollBackoffMax])
  /// instead of a fixed interval — fewer requests while the charge is pending.
  Future<BillingTransactionResponse> waitForBillingSuccess({
    required String requestId,
    bool Function()? isCancelled,
  }) async {
    final deadline = DateTime.now().add(EnvConfig.billingPollTimeout);
    final random = math.Random();
    String? lastPendingMessage;
    var backoff = EnvConfig.billingPollInterval;

    while (true) {
      if (isCancelled?.call() ?? false) {
        throw StateError('Billing status polling was cancelled.');
      }

      if (DateTime.now().isAfter(deadline)) {
        throw ApiException(lastPendingMessage ?? 'pending');
      }

      final transaction = await getBillingStatus(requestId: requestId);

      if (isCancelled?.call() ?? false) {
        throw StateError('Billing status polling was cancelled.');
      }

      if (transaction.isBillingSuccess) return transaction;

      if (transaction.isBillingFailed) {
        throw ApiException(
          transaction.userMessage ?? transaction.normalizedStatus,
        );
      }

      lastPendingMessage = transaction.userMessage;

      final remaining = deadline.difference(DateTime.now());
      if (remaining <= Duration.zero) {
        throw ApiException(lastPendingMessage ?? 'pending');
      }

      final capMs = math.min(remaining.inMilliseconds, backoff.inMilliseconds);
      if (capMs > 0) {
        const jitterLow = 0.85;
        const jitterHigh = 1.15;
        final factor =
            jitterLow + random.nextDouble() * (jitterHigh - jitterLow);
        final sleepMs = math.max(0, (capMs * factor).round());
        await Future<void>.delayed(Duration(milliseconds: sleepMs));
      }

      if (isCancelled?.call() ?? false) {
        throw StateError('Billing status polling was cancelled.');
      }

      final nextMs =
          (backoff.inMilliseconds * EnvConfig.billingPollBackoffMultiplier)
              .round();
      final maxMs = EnvConfig.billingPollBackoffMax.inMilliseconds;
      backoff = Duration(milliseconds: math.min(maxMs, math.max(nextMs, 1)));
    }
  }

  Future<TargetTimeResponse> fetchTargetTime({required String msisdn}) =>
      _postTargetTime(msisdn);

  Future<GameStartResponse> startGameSession({
    required String msisdn,
    required String billingRequestId,
    String? channel,
  }) => _postGameStart(
    msisdn: msisdn,
    billingRequestId: billingRequestId,
    channel: channel ?? EnvConfig.gameChannel,
  );

  Future<GameStartResponse> stopGameSession({required String sessionRef}) =>
      _postGameStop(sessionRef: sessionRef);

  Future<GameStartResponse> getGameSession({required String sessionRef}) =>
      _fetchGameSession(sessionRef);

  /// `GET /api/v1/game/history` — paginated playing history for the logged-in user.
  Future<GameHistoryResponse> fetchGameHistory({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _api.get(
      Uri.parse(ApiConfig.gameHistory(page: page, size: size)),
    );
    return response.parse(
      GameHistoryResponse.fromJson,
      context: 'GET /game/history',
    );
  }

  Future<BillingTransactionResponse> _postBillingTransaction({
    required String msisdn,
  }) async {
    final response = await _api.post(
      Uri.parse(ApiConfig.billingTransactions),
      body: BillingTransactionRequest(msisdn: msisdn).toJson(),
    );
    return response.parse(
      BillingTransactionResponse.fromJson,
      context: 'POST /billing/transactions',
    );
  }

  Future<BillingTransactionResponse> _fetchBillingStatus(
    String requestId,
  ) async {
    final response = await _api.get(
      Uri.parse(ApiConfig.billingTransaction(requestId)),
    );
    return response.parse(
      BillingTransactionResponse.fromJson,
      context: 'GET /billing/transactions/{requestId}',
    );
  }

  Future<TargetTimeResponse> _postTargetTime(String msisdn) async {
    final response = await _api.post(
      Uri.parse(ApiConfig.targetTime),
      body: TargetTimeRequest(msisdn: msisdn).toJson(),
    );
    return response.parse(
      TargetTimeResponse.fromJson,
      context: 'POST /game/target-time',
    );
  }

  Future<GameStartResponse> _postGameStart({
    required String msisdn,
    required String billingRequestId,
    required String channel,
  }) async {
    final response = await _api.post(
      Uri.parse(ApiConfig.gameStart),
      body: StartGameRequest(
        msisdn: msisdn,
        billingRequestId: billingRequestId,
        channel: channel,
      ).toJson(),
    );
    return response.parse(
      GameStartResponse.fromJson,
      context: 'POST /game/start',
    );
  }

  Future<GameStartResponse> _postGameStop({required String sessionRef}) async {
    final response = await _api.post(
      Uri.parse(ApiConfig.gameStop),
      body: StopGameRequest(sessionRef: sessionRef).toJson(),
    );

    if (response.hasJson) {
      return response.parse(
        GameStartResponse.fromJson,
        context: 'POST /game/stop',
      );
    }

    return getGameSession(sessionRef: sessionRef);
  }

  Future<GameStartResponse> _fetchGameSession(String sessionRef) async {
    final response = await _api.get(
      Uri.parse(ApiConfig.gameSession(sessionRef)),
    );
    return response.parse(
      GameStartResponse.fromJson,
      context: 'GET /game/sessions/{sessionRef}',
    );
  }
}
