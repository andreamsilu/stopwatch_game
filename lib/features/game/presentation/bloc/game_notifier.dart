import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/core/services/game_feedback_service.dart';
import 'package:stopwatch_game/core/services/interaction_telemetry_service.dart';
import 'package:stopwatch_game/core/api/api_messages.dart';
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
    InteractionTelemetryService? telemetryService,
  }) : _msisdn = msisdn,
       _isSubscribed = isSubscribed,
       _gameService = gameService ?? GameService.create(api: api),
       _telemetry =
           telemetryService ??
           InteractionTelemetryService(api: api, enabled: false),
       super(const GameState.initial()) {
    GameFeedbackService.setSoundEnabled(state.isSoundEnabled);
    _beginInteractionSession();
    _track('portal.session_started');
  }

  final String _msisdn;
  final bool _isSubscribed;
  final GameService _gameService;
  final InteractionTelemetryService _telemetry;

  String get _effectiveMsisdn => _msisdn;

  final Stopwatch _stopwatch = Stopwatch();
  final Random _random = Random();
  Timer? _ticker;
  _RoundInteractionSession? _activeInteractionSession;
  final List<double> _reactionHistoryMs = [];
  final List<double> _clickVarianceHistory = [];
  GameStartResponse? _activeSession;
  int _roundOperationId = 0;

  /// Stops in-flight billing/target prep from updating state after dispose/logout.
  void invalidatePendingWork() => _roundOperationId++;

  void _patchState(GameState Function(GameState current) patch) {
    if (!mounted) return;
    state = patch(state);
  }

  bool _isActiveRoundOp(int operationId) =>
      mounted && operationId == _roundOperationId;

  int _beginRoundOperation() => ++_roundOperationId;

  void selectTab(GameTab tab) {
    if (state.selectedTab == tab) return;
    state = state.copyWith(selectedTab: tab);
    _track('navigation.tab_viewed', properties: {'tab': tab.name});
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
        roundErrorMessage: RoundBillingCopy.loginRequired,
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
    _track('game.play_opened');
    await _chargeAndPrepareRound();
  }

  /// Clears the current round UI without charging (subscription already active).
  Future<void> cancelRound({bool goHome = false}) async {
    if (!mounted) return;
    if (state.isSubmitting && state.isRunning) return;

    invalidatePendingWork();
    _stopwatch.stop();
    _stopwatch.reset();
    _ticker?.cancel();
    _activeSession = null;
    await GameFeedbackService.onRoundReset();

    state = state.copyWith(
      isRunning: false,
      isSubmitting: false,
      elapsed: Duration.zero,
      targetTime: Duration.zero,
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
      _patchState(
        (s) => s.copyWith(roundErrorMessage: RoundBillingCopy.loginRequired),
      );
      return;
    }
    if (state.isSubmitting || state.isPreparingRound) return;

    await cancelRound();
    if (!mounted) return;

    _beginInteractionSession();
    _activeSession = null;
    _patchState(
      (s) => s.copyWith(
        selectedTab: GameTab.play,
        clearLatestResult: true,
        clearLatestInteractionPayload: true,
        clearActiveSession: true,
        clearRoundError: true,
      ),
    );
    await _chargeAndPrepareRound();
  }

  /// Charge this round and load target time (Play). Does not start the stopwatch.
  Future<void> onPlayRoundPressed() async {
    if (state.isRunning || state.isSubmitting || state.isPreparingRound) {
      return;
    }
    if (state.canStartRound) return;

    if (!_isSubscribed) {
      _patchState(
        (s) => s.copyWith(
          selectedTab: GameTab.play,
          roundErrorMessage: RoundBillingCopy.loginRequired,
        ),
      );
      return;
    }

    await _chargeAndPrepareRound();
  }

  /// Start or stop the stopwatch (Start round / Stop). Requires billing first.
  Future<void> onStartPressed() async {
    if (state.isRunning || state.isSubmitting || state.isPreparingRound) {
      return;
    }

    if (!state.canStartRound) return;

    // Billed: user explicitly starts the stopwatch.
    _patchState((s) => s.copyWith(isSubmitting: true, clearRoundError: true));
    try {
      await startGame();
      if (!mounted) return;
    } on ApiException catch (e) {
      _patchState(
        (s) => s.copyWith(
          isSubmitting: false,
          roundErrorMessage: e.message,
          clearActiveSession: true,
        ),
      );
      return;
    } catch (e) {
      _patchState(
        (s) => s.copyWith(
          isSubmitting: false,
          roundErrorMessage: ApiMessages.fromError(e),
          clearActiveSession: true,
        ),
      );
      return;
    }

    _stopwatch.start();
    _ticker?.cancel();
    _ticker = Timer.periodic(GameConstants.timerUiTickInterval, (_) {
      if (!mounted) return;
      _patchState((s) => s.copyWith(elapsed: _stopwatch.elapsed));
    });
    _beginInteractionSession();
    await GameFeedbackService.onRoundStart();
    _patchState(
      (s) => s.copyWith(
        isRunning: true,
        isSubmitting: false,
        elapsed: _stopwatch.elapsed,
      ),
    );
    _track(
      'game.started',
      properties: {
        'sessionRef': state.sessionRef,
        'gameSessionId': state.activeSessionId,
        'targetTimeMs': state.targetTime.inMilliseconds,
      },
    );
  }

  Future<void> onStopPressed() async {
    if (!state.isRunning || state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true);
    await GameFeedbackService.onRoundStop();
    _stopwatch.stop();
    _ticker?.cancel();

    try {
      final backendResult = await fetchRoundResultFromBackend();
      if (!mounted) return;

      _stopwatch.reset();
      final interactionPayload = _buildInteractionPayload();
      unawaited(_telemetry.submitRoundPayload(interactionPayload));

      _patchState((s) {
        final absDiff = backendResult.differenceMs.abs();
        final prevBest = s.bestDifferenceAbsMs;
        final newBest = prevBest == null
            ? absDiff
            : (absDiff < prevBest ? absDiff : prevBest);
        return s.copyWith(
          isRunning: false,
          isSubmitting: false,
          elapsed: Duration.zero,
          latestResult: backendResult,
          latestInteractionPayload: interactionPayload,
          totalWins:
              s.totalWins + (backendResult.outcomeLabel == 'WIN' ? 1 : 0),
          roundsPlayed: s.roundsPlayed + 1,
          bestDifferenceAbsMs: newBest,
          clearActiveSession: true,
        );
      });
      _track(
        'game.completed',
        properties: {
          'sessionRef': interactionPayload['sessionRef'],
          'differenceMs': backendResult.differenceMs,
          'winner': backendResult.outcomeLabel == 'WIN',
        },
      );
    } on ApiException catch (e) {
      _stopwatch.reset();
      _patchState(
        (s) => s.copyWith(
          isRunning: false,
          isSubmitting: false,
          elapsed: Duration.zero,
          roundErrorMessage: e.message,
        ),
      );
    } catch (e) {
      _stopwatch.reset();
      _patchState(
        (s) => s.copyWith(
          isRunning: false,
          isSubmitting: false,
          elapsed: Duration.zero,
          roundErrorMessage: ApiMessages.fromError(e),
        ),
      );
    }
  }

  Future<void> onResetPressed() async {
    await cancelRound();
  }

  Future<void> onPullToRefresh() async {
    if (state.isSubmitting || state.isPreparingRound) return;
    await prepareNewPaidRound();
    if (!mounted) return;
    _patchState((s) => s.copyWith(clearLatestResult: true));
    await Future<void>.delayed(const Duration(milliseconds: 260));
  }

  void dismissResultDialog() {
    state = state.copyWith(clearLatestResult: true);
  }

  /// Clears transient copy shown via snackbars (not on-screen banners).
  void clearFeedbackMessages() {
    state = state.copyWith(clearRoundError: true, clearStatusMessage: true);
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
      return;
    }

    final session = await _gameService.startGameSession(
      msisdn: _effectiveMsisdn,
      billingRequestId: billingRequestId,
      channel: EnvConfig.gameChannel,
    );
    _activeSession = session;
    _patchState(
      (s) => s.copyWith(
        targetTime: Duration(milliseconds: session.targetTimeMs),
        billingRequestId: session.billingRequestId,
        sessionRef: session.sessionRef,
        activeSessionId: session.id,
      ),
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
      throw ApiException(_activeSession?.status ?? '');
    }

    var session = await _gameService.stopGameSession(sessionRef: sessionRef);
    _activeSession = session;

    final fromStop = GameSessionMapper.toRoundResult(session);
    if (fromStop != null) return fromStop;

    session = await _gameService.getGameSession(sessionRef: sessionRef);
    _activeSession = session;

    final fromGet = GameSessionMapper.toRoundResult(session);
    if (fromGet != null) return fromGet;

    throw ApiException(session.status);
  }

  Future<void> _finishRoundPreparationAfterPayment(
    String requestId, {
    required int operationId,
  }) async {
    _patchState(
      (s) => s.copyWith(
        preparePhase: RoundPreparePhase.loadingTarget,
        isLoadingTarget: true,
      ),
    );

    final target = await _gameService.fetchTargetTime(msisdn: _effectiveMsisdn);
    if (!_isActiveRoundOp(operationId)) return;

    _patchState(
      (s) => s.copyWith(
        targetTime: Duration(milliseconds: target.targetTimeMs),
        billingRequestId: requestId,
        isLoadingTarget: false,
        isSubmitting: false,
        preparePhase: RoundPreparePhase.idle,
        clearPendingBilling: true,
        clearRoundError: true,
        statusMessage: RoundBillingCopy.playReadyHint,
      ),
    );
  }

  Future<void> _chargeAndPrepareRound() async {
    final operationId = _beginRoundOperation();

    _patchState(
      (s) => s.copyWith(
        isSubmitting: true,
        isLoadingTarget: true,
        preparePhase: RoundPreparePhase.charging,
        statusMessage: RoundBillingCopy.preparingRoundCharge,
        clearRoundError: true,
        clearPendingBilling: true,
      ),
    );

    try {
      if (_effectiveMsisdn.trim().isEmpty) {
        if (!_isActiveRoundOp(operationId)) return;
        _patchState(
          (s) => s.copyWith(
            isSubmitting: false,
            isLoadingTarget: false,
            preparePhase: RoundPreparePhase.idle,
            roundErrorMessage: RoundBillingCopy.loginRequired,
          ),
        );
        return;
      }

      final billing = await _gameService.enqueueBilling(
        msisdn: _effectiveMsisdn,
      );
      if (!_isActiveRoundOp(operationId)) return;

      _track(
        'billing.initiated',
        properties: {'billingRequestId': billing.requestId},
      );

      _patchState(
        (s) => s.copyWith(
          preparePhase: RoundPreparePhase.awaitingPayment,
          pendingBillingRequestId: billing.requestId,
          statusMessage: RoundBillingCopy.waitingForPayment,
        ),
      );

      await _gameService.waitForBillingSuccess(requestId: billing.requestId);
      if (!_isActiveRoundOp(operationId)) return;

      _track(
        'billing.succeeded',
        properties: {'billingRequestId': billing.requestId},
      );

      _patchState(
        (s) => s.copyWith(
          preparePhase: RoundPreparePhase.loadingTarget,
          statusMessage: RoundBillingCopy.loadingTarget,
        ),
      );
      await _finishRoundPreparationAfterPayment(
        billing.requestId,
        operationId: operationId,
      );
    } on ApiException catch (e) {
      if (!_isActiveRoundOp(operationId)) return;
      _track(
        'round.preparation_failed',
        properties: {
          'phase': state.preparePhase.name,
          'reasonType': e.runtimeType.toString(),
        },
      );
      _patchState(
        (s) => s.copyWith(
          isSubmitting: false,
          isLoadingTarget: false,
          preparePhase: RoundPreparePhase.idle,
          roundErrorMessage: e.message,
          clearActiveSession: true,
          clearPendingBilling: true,
          clearStatusMessage: true,
        ),
      );
    } catch (e) {
      if (!_isActiveRoundOp(operationId)) return;
      _track(
        'round.preparation_failed',
        properties: {
          'phase': state.preparePhase.name,
          'reasonType': e.runtimeType.toString(),
        },
      );
      _patchState(
        (s) => s.copyWith(
          isSubmitting: false,
          isLoadingTarget: false,
          preparePhase: RoundPreparePhase.idle,
          roundErrorMessage: ApiMessages.fromError(e),
          clearActiveSession: true,
          clearPendingBilling: true,
          clearStatusMessage: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    invalidatePendingWork();
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
      'interactionSessionId': session.sessionId,
      'sessionRef': _resolveSessionLookupRef(),
      'isTrusted': session.latestTrustedFlag,
    };
  }

  void _track(String eventName, {Map<String, dynamic> properties = const {}}) {
    unawaited(_telemetry.track(eventName, properties: properties));
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
        values
            .map((v) => math.pow(v - mean, 2).toDouble())
            .reduce((a, b) => a + b) /
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
    final firstDown = _samples.firstWhereOrNull(
      (s) => s.type == _PointerType.down,
    );
    if (firstDown == null) return 0;
    return firstDown.timestamp
        .difference(uiReadyAt)
        .inMilliseconds
        .clamp(0, 60000);
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
    final downPoints = _samples
        .where((s) => s.type == _PointerType.down)
        .map((s) => s.position)
        .toList();
    final upPoints = _samples
        .where((s) => s.type == _PointerType.up)
        .map((s) => s.position)
        .toList();
    final pairCount = math.min(downPoints.length, upPoints.length);
    if (pairCount == 0) return 0;
    final distances = <double>[];
    for (var i = 0; i < pairCount; i++) {
      distances.add((upPoints[i] - downPoints[i]).distance);
    }
    final mean = distances.reduce((a, b) => a + b) / distances.length;
    final variance =
        distances
            .map((d) => math.pow(d - mean, 2).toDouble())
            .reduce((a, b) => a + b) /
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
