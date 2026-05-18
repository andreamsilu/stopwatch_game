import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/core/services/game_feedback_service.dart';
import 'package:stopwatch_game/core/services/interaction_telemetry_service.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';
import 'package:stopwatch_game/core/config/env_config.dart';
import 'package:stopwatch_game/core/api/stopwatch_api.dart';
import 'package:stopwatch_game/features/game/data/game_service.dart';
import 'package:stopwatch_game/features/game/data/game_session_mapper.dart';
import 'package:stopwatch_game/features/game/data/models/game_start_response.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';

class GameController extends StateNotifier<GameState> {
  GameController({
    required String msisdn,
    GameService? gameService,
    StopwatchApi? api,
  }) : _msisdn = msisdn,
       _gameService = gameService ?? GameService.create(api: api),
       super(const GameState.initial()) {
    GameFeedbackService.setSoundEnabled(state.isSoundEnabled);
    _beginInteractionSession();
  }

  final String _msisdn;
  final GameService _gameService;

  String get _effectiveMsisdn {
    if (_msisdn.isNotEmpty) return _msisdn;
    final digits = LoginState.defaultPhoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('255')) return digits;
    return '255$digits';
  }

  final Stopwatch _stopwatch = Stopwatch();
  final Random _random = Random();
  Timer? _ticker;
  _RoundInteractionSession? _activeInteractionSession;
  final List<double> _reactionHistoryMs = [];
  final List<double> _clickVarianceHistory = [];
  GameStartResponse? _activeSession;

  void selectTab(GameTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void toggleSoundEnabled() {
    final nextEnabled = !state.isSoundEnabled;
    state = state.copyWith(isSoundEnabled: nextEnabled);
    GameFeedbackService.setSoundEnabled(nextEnabled);
  }

  Future<void> openRoundBoard() async {
    _beginInteractionSession();
    state = state.copyWith(
      selectedTab: GameTab.play,
      isLoadingTarget: true,
      clearLatestResult: true,
      clearLatestInteractionPayload: true,
      clearActiveSession: true,
      clearRoundError: true,
    );
    _activeSession = null;
    await _prepareRoundWithBilling();
  }

  Future<void> onStartPressed() async {
    if (state.isRunning || state.isSubmitting || state.isLoadingTarget) return;

    state = state.copyWith(isSubmitting: true, clearRoundError: true);
    try {
      await startGame();
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, roundErrorMessage: e.message);
      return;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        roundErrorMessage: 'Could not start the round. Try again.',
      );
      return;
    }

    _stopwatch.start();
    _ticker?.cancel();
    _ticker = Timer.periodic(GameConstants.timerUiTickInterval, (_) {
      state = state.copyWith(elapsed: _stopwatch.elapsed);
    });
    _beginInteractionSession();
    state = state.copyWith(
      isRunning: true,
      isSubmitting: false,
      elapsed: _stopwatch.elapsed,
    );
  }

  Future<void> onStopPressed() async {
    if (!state.isRunning || state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true);
    _stopwatch.stop();
    _ticker?.cancel();
    final stoppedElapsed = _stopwatch.elapsed;

    GameStartResponse? stoppedSession;
    try {
      stoppedSession = await stopGame(
        stoppedTimeMs: stoppedElapsed.inMilliseconds,
      );
    } on ApiException catch (e) {
      state = state.copyWith(roundErrorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        roundErrorMessage: 'Could not submit stop time. Showing local result.',
      );
    }

    final backendResult = await fetchRoundResultFromBackend(
      actualElapsed: stoppedElapsed,
      targetTime: state.targetTime,
      stoppedSession: stoppedSession,
    );
    final nextHistory = [
      HistoryEntry(
        timestamp: DateTime.now(),
        timeLabel: backendResult.finalTimeLabel,
        outcome: backendResult.outcomeLabel,
      ),
      ...state.history,
    ];
    _stopwatch.reset();
    final interactionPayload = _buildInteractionPayload();
    await InteractionTelemetryService.submitRoundPayload(interactionPayload);

    state = state.copyWith(
      isRunning: false,
      isSubmitting: false,
      elapsed: Duration.zero,
      latestResult: backendResult,
      latestInteractionPayload: interactionPayload,
      history: nextHistory,
      totalWins: state.totalWins + (backendResult.outcomeLabel == 'WIN' ? 1 : 0),
      totalPrizeCoins: state.totalPrizeCoins + backendResult.prizeCoins,
    );
  }

  Future<void> onResetPressed() async {
    if (state.isSubmitting || state.isLoadingTarget) return;

    _stopwatch.stop();
    _stopwatch.reset();
    _ticker?.cancel();

    _beginInteractionSession();
    _activeSession = null;
    state = state.copyWith(
      isRunning: false,
      elapsed: Duration.zero,
      isLoadingTarget: true,
      clearLatestInteractionPayload: true,
      clearActiveSession: true,
      clearRoundError: true,
    );
    await _prepareRoundWithBilling();
  }

  Future<void> onPullToRefresh() async {
    if (state.isSubmitting || state.isLoadingTarget) return;
    await onResetPressed();
    state = state.copyWith(clearLatestResult: true);
    // Keep the indicator visible briefly so users perceive refresh feedback.
    await Future<void>.delayed(const Duration(milliseconds: 260));
  }

  void dismissResultDialog() {
    state = state.copyWith(clearLatestResult: true);
  }

  void onStartControlPointerDown(Offset position, {bool? isTrusted}) {
    _activeInteractionSession?.recordDown(position, isTrusted: isTrusted);
  }

  void onStartControlPointerMove(Offset position) {
    _activeInteractionSession?.recordMove(position);
  }

  void onStartControlPointerUp(Offset position, {bool? isTrusted}) {
    _activeInteractionSession?.recordUp(position, isTrusted: isTrusted);
  }

  Future<void> startGame() async {
    final billingRequestId = state.billingRequestId;
    if (billingRequestId == null || billingRequestId.isEmpty) {
      throw ApiException(
        'Payment is not ready. Go to Home, tap Play, and wait for billing to complete.',
      );
    }

    final session = await _gameService.startGameSession(
      msisdn: _effectiveMsisdn,
      billingRequestId: billingRequestId,
      channel: EnvConfig.gameChannel,
    );
    _activeSession = session;
    state = state.copyWith(
      targetTime: Duration(milliseconds: session.targetTimeMs),
      billingRequestId: session.billingRequestId,
      sessionRef: session.sessionRef,
      activeSessionId: session.id,
    );
  }

  Future<GameStartResponse?> stopGame({required int stoppedTimeMs}) async {
    final sessionRef = _resolveSessionLookupRef();
    if (sessionRef.isEmpty) return null;

    final session = await _gameService.stopGameSession(
      sessionRef: sessionRef,
      stoppedTimeMs: stoppedTimeMs,
    );
    _activeSession = session;
    return session;
  }

  String _resolveSessionLookupRef() {
    return state.sessionRef ??
        state.billingRequestId ??
        _activeSession?.sessionRef ??
        _activeSession?.billingRequestId ??
        '';
  }

  Future<RoundResultData> fetchRoundResultFromBackend({
    required Duration actualElapsed,
    required Duration targetTime,
    GameStartResponse? stoppedSession,
  }) async {
    if (stoppedSession != null) {
      final fromStop = GameSessionMapper.toRoundResult(stoppedSession);
      if (fromStop != null) return fromStop;
    }

    final lookupRef = _resolveSessionLookupRef();
    if (lookupRef.isNotEmpty) {
      try {
        final session = await _gameService.getGameSession(sessionRef: lookupRef);
        final mapped = GameSessionMapper.toRoundResult(session);
        if (mapped != null) return mapped;
      } on ApiException catch (e) {
        state = state.copyWith(roundErrorMessage: e.message);
      } catch (_) {
        // Fall through to local result.
      }
    }

    final differenceMs =
        actualElapsed.inMilliseconds - targetTime.inMilliseconds;
    // Award a win when the stop is within +/-100ms of target.
    const winToleranceMs = 100;
    final isWin = differenceMs.abs() <= winToleranceMs;
    final absDifferenceMs = differenceMs.abs();
    final timingDirection = differenceMs < 0 ? 'Early' : 'Late';
    final deltaLabel = isWin
        ? 'Great timing! Within +/-$winToleranceMs ms. Prize unlocked!'
        : '$timingDirection by $absDifferenceMs ms';
    const perfectStopPrizeCoins = 100;
    const perfectStopPrizeLabel = 'Perfect Stop Reward';

    return RoundResultData(
      outcomeLabel: isWin ? 'WIN' : 'LOSE',
      deltaLabel: deltaLabel,
      finalTimeLabel: _formatDurationWithMilliseconds(actualElapsed),
      differenceMs: differenceMs,
      prizeLabel: isWin ? perfectStopPrizeLabel : 'No prize',
      prizeCoins: isWin ? perfectStopPrizeCoins : 0,
      isPrizeAwarded: isWin,
    );
  }

  Future<void> _prepareRoundWithBilling() async {
    try {
      final prepared = await _gameService.prepareRound(
        msisdn: _effectiveMsisdn,
      );

      state = state.copyWith(
        targetTime: Duration(milliseconds: prepared.targetTimeMs),
        billingRequestId: prepared.billingRequestId,
        isLoadingTarget: false,
        clearRoundError: true,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoadingTarget: false,
        roundErrorMessage: e.message,
        clearActiveSession: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingTarget: false,
        roundErrorMessage: 'Could not start billing or load target time.',
        clearActiveSession: true,
      );
    }
  }

  String _formatDurationWithMilliseconds(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    final milliseconds = value.inMilliseconds.remainder(1000).toString().padLeft(
      3,
      '0',
    );
    return '$minutes:$seconds.$milliseconds';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _beginInteractionSession() {
    final sessionId = _newSessionId();
    _activeInteractionSession = _RoundInteractionSession(
      sessionId: sessionId,
      uiReadyAt: DateTime.now(),
    );
    state = state.copyWith(
      interactionSessionId: sessionId,
      // Keep visible motion subtle so users do not perceive jitter.
      startButtonVisualOffset: _randomVisualOffset(),
      // Keep interaction layer randomized to reduce coordinate automation reliability.
      startButtonHitboxOffset: _randomHitboxOffset(),
    );
  }

  Offset _randomVisualOffset() {
    final magnitudeX = 1 + _random.nextInt(3); // 1..3 px
    final magnitudeY = 1 + _random.nextInt(3); // 1..3 px
    final dx = (_random.nextBool() ? 1 : -1) * magnitudeX.toDouble();
    final dy = (_random.nextBool() ? 1 : -1) * magnitudeY.toDouble();
    return Offset(dx, dy);
  }

  Offset _randomHitboxOffset() {
    final magnitudeX = 5 + _random.nextInt(11); // 5..15 px
    final magnitudeY = 5 + _random.nextInt(11); // 5..15 px
    final dx = (_random.nextBool() ? 1 : -1) * magnitudeX.toDouble();
    final dy = (_random.nextBool() ? 1 : -1) * magnitudeY.toDouble();
    return Offset(dx, dy);
  }

  String _newSessionId() {
    return '${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(100000)}';
  }

  Map<String, dynamic> _buildInteractionPayload() {
    final session =
        _activeInteractionSession ??
        _RoundInteractionSession(
          sessionId: state.interactionSessionId,
          uiReadyAt: DateTime.now(),
        );
    final reactionTimeMs = session.reactionTimeMs;
    final movementEntropy = session.movementEntropy;
    final clickVariance = session.clickPrecisionVariance;

    _reactionHistoryMs.add(reactionTimeMs.toDouble());
    _clickVarianceHistory.add(clickVariance);
    final interactionConsistency = _computeInteractionConsistency();

    return {
      'reactionTime': reactionTimeMs,
      'movementEntropy': movementEntropy,
      'clickVariance': clickVariance,
      'interactionConsistency': interactionConsistency,
      'sessionId': session.sessionId,
      'timestamp': DateTime.now().toIso8601String(),
      'isTrusted': session.latestTrustedFlag,
    };
  }

  double _computeInteractionConsistency() {
    if (_reactionHistoryMs.length < 2) return 1.0;
    final recentReaction = _reactionHistoryMs.takeLast(10).toList();
    final recentClickVariance = _clickVarianceHistory.takeLast(10).toList();
    final reactionStdDev = _stdDev(recentReaction);
    final clickStdDev = _stdDev(recentClickVariance);
    final instability = reactionStdDev + clickStdDev;
    return (1 / (1 + instability)).clamp(0.0, 1.0);
  }

  double _stdDev(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((v) => math.pow(v - mean, 2).toDouble()).reduce((a, b) => a + b) /
        values.length;
    return math.sqrt(variance);
  }
}

class _RoundInteractionSession {
  _RoundInteractionSession({required this.sessionId, required this.uiReadyAt});

  final String sessionId;
  final DateTime uiReadyAt;
  final List<_PointerSample> _samples = [];
  bool? latestTrustedFlag;

  void recordDown(Offset position, {bool? isTrusted}) {
    latestTrustedFlag = isTrusted ?? latestTrustedFlag;
    _samples.add(
      _PointerSample(
        type: _PointerType.down,
        position: position,
        timestamp: DateTime.now(),
      ),
    );
  }

  void recordMove(Offset position) {
    _samples.add(
      _PointerSample(
        type: _PointerType.move,
        position: position,
        timestamp: DateTime.now(),
      ),
    );
  }

  void recordUp(Offset position, {bool? isTrusted}) {
    latestTrustedFlag = isTrusted ?? latestTrustedFlag;
    _samples.add(
      _PointerSample(
        type: _PointerType.up,
        position: position,
        timestamp: DateTime.now(),
      ),
    );
  }

  int get reactionTimeMs {
    final firstDown = _samples.firstWhereOrNull((s) => s.type == _PointerType.down);
    if (firstDown == null) return 0;
    return firstDown.timestamp.difference(uiReadyAt).inMilliseconds.clamp(0, 60000);
  }

  double get movementEntropy {
    final points = _samples.map((s) => s.position).toList();
    if (points.length < 3) return 0;
    final bins = List<int>.filled(8, 0);
    for (var i = 1; i < points.length; i++) {
      final delta = points[i] - points[i - 1];
      if (delta.distance < 1) continue;
      final angle = math.atan2(delta.dy, delta.dx);
      final normalized = (angle + math.pi) / (2 * math.pi);
      final bin = (normalized * 8).floor().clamp(0, 7);
      bins[bin] += 1;
    }
    final total = bins.fold<int>(0, (sum, b) => sum + b);
    if (total == 0) return 0;
    double entropy = 0;
    for (final count in bins) {
      if (count == 0) continue;
      final p = count / total;
      entropy -= p * (math.log(p) / math.ln2);
    }
    return entropy;
  }

  double get clickPrecisionVariance {
    final downPoints =
        _samples.where((s) => s.type == _PointerType.down).map((s) => s.position).toList();
    final upPoints =
        _samples.where((s) => s.type == _PointerType.up).map((s) => s.position).toList();
    final pairCount = math.min(downPoints.length, upPoints.length);
    if (pairCount == 0) return 0;
    final distances = <double>[];
    for (var i = 0; i < pairCount; i++) {
      distances.add((upPoints[i] - downPoints[i]).distance);
    }
    final mean = distances.reduce((a, b) => a + b) / distances.length;
    final variance =
        distances.map((d) => math.pow(d - mean, 2).toDouble()).reduce((a, b) => a + b) /
        distances.length;
    return variance;
  }
}

enum _PointerType { down, move, up }

class _PointerSample {
  _PointerSample({
    required this.type,
    required this.position,
    required this.timestamp,
  });

  final _PointerType type;
  final Offset position;
  final DateTime timestamp;
}

extension _TakeLast<T> on List<T> {
  Iterable<T> takeLast(int count) {
    if (length <= count) return this;
    return sublist(length - count);
  }
}

extension _FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T value) test) {
    for (final value in this) {
      if (test(value)) return value;
    }
    return null;
  }
}
