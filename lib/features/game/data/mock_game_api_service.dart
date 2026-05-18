import 'dart:math';

import 'package:stopwatch_game/core/config/env_config.dart';
import 'package:stopwatch_game/features/game/data/models/billing_transaction_response.dart';
import 'package:stopwatch_game/features/game/data/models/game_session_result.dart';
import 'package:stopwatch_game/features/game/data/models/game_start_response.dart';
import 'package:stopwatch_game/features/game/data/models/target_time_response.dart';

class MockGameApiService {
  MockGameApiService();

  static const Duration _latency = Duration(milliseconds: 350);

  int _targetTimeMs = 8200;
  GameStartResponse? _activeSession;

  Future<BillingTransactionResponse> enqueueBilling({
    required String msisdn,
    required double amount,
  }) async {
    await Future<void>.delayed(_latency);
    final now = DateTime.now().toUtc().toIso8601String();

    return BillingTransactionResponse(
      id: 1,
      msisdn: msisdn,
      requestId: EnvConfig.mockBillingRequestId,
      billingType: 'YAS',
      amount: amount,
      status: 'pending',
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<BillingTransactionResponse> getBillingStatus({
    required String requestId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now().toUtc().toIso8601String();

    return BillingTransactionResponse(
      id: 1,
      msisdn: '',
      requestId: requestId,
      billingType: 'YAS',
      amount: EnvConfig.gameEntryFee,
      status: 'success',
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<TargetTimeResponse> fetchTargetTime({required String msisdn}) async {
    await Future<void>.delayed(_latency);

    const minMs = 3000;
    const maxMs = 12000;
    final random = Random();
    final raw = minMs + random.nextInt(maxMs - minMs + 1);
    _targetTimeMs = (raw ~/ 10) * 10;

    return TargetTimeResponse(
      msisdn: msisdn,
      targetTimeMs: _targetTimeMs,
      billingRequestId: EnvConfig.mockBillingRequestId,
    );
  }

  Future<GameStartResponse> startGameSession({
    required String msisdn,
    required String billingRequestId,
    required String channel,
  }) async {
    await Future<void>.delayed(_latency);
    final now = DateTime.now().toUtc().toIso8601String();

    _activeSession = GameStartResponse(
      id: 1,
      sessionRef: billingRequestId,
      billingRequestId: billingRequestId,
      msisdn: msisdn,
      channel: channel,
      entryFee: 0,
      targetTimeMs: _targetTimeMs,
      status: 'ACTIVE',
      startedAt: now,
    );
    return _activeSession!;
  }

  Future<GameStartResponse> stopGameSession({
    required String sessionRef,
    required int stoppedTimeMs,
  }) async {
    await Future<void>.delayed(_latency);
    final completed = _completedSession(sessionRef, stoppedTimeMs);
    _activeSession = completed;
    return completed;
  }

  Future<GameStartResponse> getGameSession({
    required String sessionRef,
    int? stoppedTimeMs,
  }) async {
    await Future<void>.delayed(_latency);
    return _completedSession(sessionRef, stoppedTimeMs ?? _targetTimeMs);
  }

  GameStartResponse _completedSession(String sessionRef, int stoppedTimeMs) {
    final session = _activeSession;
    if (session == null) {
      throw StateError('No active mock session.');
    }
    if (session.sessionRef != sessionRef &&
        session.billingRequestId != sessionRef) {
      throw StateError('Session not found: $sessionRef');
    }

    final differenceMs = stoppedTimeMs - session.targetTimeMs;
    const winToleranceMs = 100;
    final isWin = differenceMs.abs() <= winToleranceMs;
    final now = DateTime.now().toUtc().toIso8601String();

    return GameStartResponse(
      id: session.id,
      sessionRef: session.sessionRef,
      billingRequestId: session.billingRequestId,
      msisdn: session.msisdn,
      channel: session.channel,
      entryFee: session.entryFee,
      targetTimeMs: session.targetTimeMs,
      status: 'COMPLETED',
      startedAt: session.startedAt,
      endedAt: now,
      result: GameSessionResult(
        stoppedTimeMs: stoppedTimeMs,
        differenceMs: differenceMs,
        winner: isWin,
        prizeAmount: isWin ? 100 : 0,
        createdAt: now,
      ),
    );
  }
}
