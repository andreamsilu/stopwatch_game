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
import 'package:stopwatch_game/core/billing/round_billing_copy.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/round_prepare_phase.dart';

class GameController extends StateNotifier<GameState> {
  GameController({
    required String msisdn,
    required bool isSubscribed,
    GameService? gameService,
    StopwatchApi? api,
  }) : _msisdn = msisdn,
       _isSubscribed = isSubscribed,
       _gameService = gameService ?? GameService.create(api: api),
       super(const GameState.initial()) {
    GameFeedbackService.setSoundEnabled(state.isSoundEnabled);
    _beginInteractionSession();
  }

  final String _msisdn;
  final bool _isSubscribed;
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
    if (!_isSubscribed) {
      state = state.copyWith(
        selectedTab: GameTab.play,
        roundErrorMessage: RoundBillingCopy.notSubscribed,
      );
      return;
    }

    _beginInteractionSession();
    _activeSession = null;
    state = state.copyWith(
      selectedTab: GameTab.play,
      clearLatestResult: true,
      clearLatestInteractionPayload: true,
      clearActiveSession: true,
      clearRoundError: true,
    );
    await _chargeAndPrepareRound();
  }

  /// New round after a result or retry — always charges again.
  Future<void> tryAgainRound() => prepareNewPaidRound();

  /// Clears the current round UI without charging (subscription already active).
  Future<void> cancelRound({bool goHome = false}) async {
    if (state.isSubmitting && state.isRunning) return;

    _stopwatch.stop();
    _stopwatch.reset();
    _ticker?.cancel();
    _activeSession = null;

    state = state.copyWith(
      isRunning: false,
      isSubmitting: false,
      elapsed: Duration.zero,
      isLoadingTarget: false,
      preparePhase: RoundPreparePhase.idle,
      clearActiveSession: true,
      clearPendingBilling: true,
      clearRoundError: true,
      selectedTab: goHome ? GameTab.home : state.selectedTab,
    );
  }

  /// New paid round: charge subscription fee, then allocate target time.
  Future<void> prepareNewPaidRound() async {
    if (!_isSubscribed) {
      state = state.copyWith(roundErrorMessage: RoundBillingCopy.notSubscribed);
      return;
    }
    if (state.isSubmitting || state.isPreparingRound) return;

    await cancelRound();
    _beginInteractionSession();
    _activeSession = null;
    state = state.copyWith(
      selectedTab: GameTab.play,
      clearLatestResult: true,
      clearLatestInteractionPayload: true,
      clearActiveSession: true,
      clearRoundError: true,
    );
    await _chargeAndPrepareRound();
  }

  Future<void> onStartPressed() async {
    if (state.isRunning ||
        state.isSubmitting ||
        state.isPreparingRound ||
        !state.canStartRound) {
      return;
    }

    state = state.copyWith(isSubmitting: true, clearRoundError: true);
    try {
      await startGame();
    } on ApiException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        roundErrorMessage: e.message,
        clearActiveSession: true,
      );
      return;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        roundErrorMessage:
            'Could not start the round. Use Try again to start a new charged round.',
        clearActiveSession: true,
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

    try {
      final backendResult = await fetchRoundResultFromBackend();
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
        totalWins:
            state.totalWins + (backendResult.outcomeLabel == 'WIN' ? 1 : 0),
        totalPrizeCoins: state.totalPrizeCoins + backendResult.prizeCoins,
        clearActiveSession: true,
      );
    } on ApiException catch (e) {
      _stopwatch.reset();
      state = state.copyWith(
        isRunning: false,
        isSubmitting: false,
        elapsed: Duration.zero,
        roundErrorMessage: e.message,
      );
    } catch (_) {
      _stopwatch.reset();
      state = state.copyWith(
        isRunning: false,
        isSubmitting: false,
        elapsed: Duration.zero,
        roundErrorMessage: 'Could not load round result from the server.',
      );
    }
  }

  Future<void> onResetPressed() async {
    await cancelRound();
  }

  Future<void> onPullToRefresh() async {
    if (state.isSubmitting || state.isPreparingRound) return;
    await prepareNewPaidRound();
    state = state.copyWith(clearLatestResult: true);
    await Future<void>.delayed(const Duration(milliseconds: 260));
  }

  void dismissResultDialog() {
    state = state.copyWith(clearLatestResult: true);
  }

  void onStartControlPointerDown(Offset position, {bool? isTrusted}) {
    if (state.isStopwatchControlDisabled) return;
    _activeInteractionSession?.recordDown(position, isTrusted: isTrusted);
  }

  void onStartControlPointerMove(Offset position) {
    if (state.isStopwatchControlDisabled) return;
    _activeInteractionSession?.recordMove(position);
  }

  void onStartControlPointerUp(Offset position, {bool? isTrusted}) {
    if (state.isStopwatchControlDisabled) return;
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

  String _resolveSessionLookupRef() {
    return state.sessionRef ??
        state.billingRequestId ??
        _activeSession?.sessionRef ??
        _activeSession?.billingRequestId ??
        '';
  }

  Future<RoundResultData> fetchRoundResultFromBackend() async {
    final sessionRef = _resolveSessionLookupRef();
    if (sessionRef.isEmpty) {
      throw ApiException('No active game session to submit your stop.');
    }

    GameStartResponse session;
    try {
      session = await _gameService.stopGameSession(sessionRef: sessionRef);
      _activeSession = session;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Could not submit your stop to the server.');
    }

    final fromStop = GameSessionMapper.toRoundResult(session);
    if (fromStop != null) return fromStop;

    try {
      session = await _gameService.getGameSession(sessionRef: sessionRef);
      _activeSession = session;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Could not load round result from the server.');
    }

    final fromGet = GameSessionMapper.toRoundResult(session);
    if (fromGet != null) return fromGet;

    throw ApiException(
      'The server has not returned a round result yet. Try again shortly.',
    );
  }

  Future<void> _finishRoundPreparationAfterPayment(String requestId) async {
    state = state.copyWith(
      preparePhase: RoundPreparePhase.loadingTarget,
      isLoadingTarget: true,
    );

    final target = await _gameService.fetchTargetTime(msisdn: _effectiveMsisdn);

    state = state.copyWith(
      targetTime: Duration(milliseconds: target.targetTimeMs),
      billingRequestId: requestId,
      isLoadingTarget: false,
      isSubmitting: false,
      preparePhase: RoundPreparePhase.idle,
      clearPendingBilling: true,
      clearRoundError: true,
    );
  }

  Future<void> _chargeAndPrepareRound() async {
    state = state.copyWith(
      isSubmitting: true,
      isLoadingTarget: true,
      preparePhase: RoundPreparePhase.charging,
      clearRoundError: true,
      clearPendingBilling: true,
    );

    try {
      final billing = await _gameService.enqueueBilling(
        msisdn: _effectiveMsisdn,
        amount: EnvConfig.gameEntryFee,
      );

      state = state.copyWith(
        preparePhase: RoundPreparePhase.awaitingPayment,
        pendingBillingRequestId: billing.requestId,
      );

      await _gameService.waitForBillingSuccess(requestId: billing.requestId);
      await _finishRoundPreparationAfterPayment(billing.requestId);
    } on ApiException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        isLoadingTarget: false,
        preparePhase: RoundPreparePhase.idle,
        roundErrorMessage: e.message,
        clearActiveSession: true,
        clearPendingBilling: true,
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        isLoadingTarget: false,
        preparePhase: RoundPreparePhase.idle,
        roundErrorMessage: 'Could not start charging for this round.',
        clearActiveSession: true,
        clearPendingBilling: true,
      );
    }
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
