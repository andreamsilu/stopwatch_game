import 'package:stopwatch_game/core/api/api_exception.dart';
import 'package:stopwatch_game/core/api/api_response.dart';
import 'package:stopwatch_game/core/api/stopwatch_api.dart';
import 'package:stopwatch_game/core/config/api_config.dart';
import 'package:stopwatch_game/core/config/env_config.dart';
import 'package:stopwatch_game/features/game/data/mock_game_api_service.dart';
import 'package:stopwatch_game/features/game/data/models/billing_transaction_response.dart';
import 'package:stopwatch_game/features/game/data/models/game_start_response.dart';
import 'package:stopwatch_game/features/game/data/models/round_preparation.dart';
import 'package:stopwatch_game/features/game/data/models/target_time_response.dart';

export 'package:stopwatch_game/core/api/api_exception.dart' show ApiException;

/// Gameplay and billing workflows.
class GameService {
  GameService._(this._useMock, this._api) : _mock = MockGameApiService();

  factory GameService.create({StopwatchApi? api}) =>
      GameService._(EnvConfig.useMockGame, api ?? StopwatchApi.create());

  final bool _useMock;
  final StopwatchApi _api;
  final MockGameApiService _mock;

  /// Billing → poll until paid → allocate target time.
  Future<RoundPreparation> prepareRound({required String msisdn}) async {
    final billing = await enqueueBilling(
      msisdn: msisdn,
      amount: EnvConfig.gameEntryFee,
    );
    await waitForBillingSuccess(requestId: billing.requestId);
    final target = await fetchTargetTime(msisdn: msisdn);
    return RoundPreparation(
      billingRequestId: billing.requestId,
      targetTimeMs: target.targetTimeMs,
    );
  }

  Future<BillingTransactionResponse> enqueueBilling({
    required String msisdn,
    required double amount,
  }) {
    return _useMock
        ? _mock.enqueueBilling(msisdn: msisdn, amount: amount)
        : _postBillingTransaction(msisdn: msisdn, amount: amount);
  }

  Future<BillingTransactionResponse> getBillingStatus({
    required String requestId,
  }) {
    return _useMock
        ? _mock.getBillingStatus(requestId: requestId)
        : _fetchBillingStatus(requestId);
  }

  Future<BillingTransactionResponse> waitForBillingSuccess({
    required String requestId,
  }) async {
    final deadline = DateTime.now().add(EnvConfig.billingPollTimeout);

    while (DateTime.now().isBefore(deadline)) {
      final transaction = await getBillingStatus(requestId: requestId);

      if (transaction.isBillingSuccess) return transaction;

      if (transaction.isBillingFailed) {
        final detail = transaction.callbackDescription ??
            transaction.ackDescription ??
            'Payment was not completed.';
        throw ApiException(detail);
      }

      await Future<void>.delayed(EnvConfig.billingPollInterval);
    }

    throw ApiException(
      'Payment is still pending. Confirm the charge on your phone, then tap Play again.',
    );
  }

  Future<TargetTimeResponse> fetchTargetTime({required String msisdn}) {
    return _useMock
        ? _mock.fetchTargetTime(msisdn: msisdn)
        : _postTargetTime(msisdn);
  }

  Future<GameStartResponse> startGameSession({
    required String msisdn,
    required String billingRequestId,
    String? channel,
  }) {
    final resolvedChannel = channel ?? EnvConfig.gameChannel;
    return _useMock
        ? _mock.startGameSession(
            msisdn: msisdn,
            billingRequestId: billingRequestId,
            channel: resolvedChannel,
          )
        : _postGameStart(
            msisdn: msisdn,
            billingRequestId: billingRequestId,
            channel: resolvedChannel,
          );
  }

  Future<GameStartResponse> stopGameSession({
    required String sessionRef,
    required int stoppedTimeMs,
  }) {
    return _useMock
        ? _mock.stopGameSession(
            sessionRef: sessionRef,
            stoppedTimeMs: stoppedTimeMs,
          )
        : _postGameStop(sessionRef: sessionRef, stoppedTimeMs: stoppedTimeMs);
  }

  Future<GameStartResponse> getGameSession({required String sessionRef}) {
    return _useMock
        ? _mock.getGameSession(sessionRef: sessionRef)
        : _fetchGameSession(sessionRef);
  }

  Future<BillingTransactionResponse> _postBillingTransaction({
    required String msisdn,
    required double amount,
  }) async {
    final response = await _api.post(
      Uri.parse(ApiConfig.billingTransactions),
      body: {'msisdn': msisdn, 'amount': amount},
    );
    return _parseBilling(response, 'Billing could not be started.');
  }

  Future<BillingTransactionResponse> _fetchBillingStatus(String requestId) async {
    final response = await _api.get(
      Uri.parse(ApiConfig.billingTransaction(requestId)),
      headers: StopwatchApi.acceptJsonHeaders,
    );
    return _parseBilling(response, 'Could not check payment status.');
  }

  Future<TargetTimeResponse> _postTargetTime(String msisdn) async {
    final response = await _api.post(
      Uri.parse(ApiConfig.targetTime),
      body: {'msisdn': msisdn},
    );
    if (!response.hasJson) {
      throw ApiException('Could not load target time.');
    }
    return TargetTimeResponse.fromJson(response.json!);
  }

  Future<GameStartResponse> _postGameStart({
    required String msisdn,
    required String billingRequestId,
    required String channel,
  }) async {
    final response = await _api.post(
      Uri.parse(ApiConfig.gameStart),
      body: {
        'msisdn': msisdn,
        'billingRequestId': billingRequestId,
        'channel': channel,
      },
    );
    return _parseGameSession(response, 'Could not start game session.');
  }

  Future<GameStartResponse> _postGameStop({
    required String sessionRef,
    required int stoppedTimeMs,
  }) async {
    final response = await _api.post(
      Uri.parse(ApiConfig.gameStop),
      body: {
        'sessionRef': sessionRef,
        'stoppedTimeMs': stoppedTimeMs,
      },
    );

    if (response.hasJson) {
      return GameStartResponse.fromJson(response.json!);
    }

    return getGameSession(sessionRef: sessionRef);
  }

  Future<GameStartResponse> _fetchGameSession(String sessionRef) async {
    final response = await _api.get(
      Uri.parse(ApiConfig.gameSession(sessionRef)),
    );
    return _parseGameSession(response, 'Could not load game session.');
  }

  BillingTransactionResponse _parseBilling(ApiResponse response, String fallback) {
    if (!response.hasJson) throw ApiException(fallback);
    return BillingTransactionResponse.fromJson(response.json!);
  }

  GameStartResponse _parseGameSession(ApiResponse response, String fallback) {
    if (!response.hasJson) throw ApiException(fallback);
    return GameStartResponse.fromJson(response.json!);
  }
}
