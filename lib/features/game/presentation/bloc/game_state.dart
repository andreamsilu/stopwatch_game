import 'package:flutter/material.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/round_prepare_phase.dart';

enum GameTab { home, play, history, support }

class RoundResultData {
  const RoundResultData({
    required this.outcomeLabel,
    required this.deltaLabel,
    required this.finalTimeLabel,
    required this.differenceMs,
    required this.prizeLabel,
    required this.prizeCoins,
    required this.isPrizeAwarded,
  });

  final String outcomeLabel;
  final String deltaLabel;
  final String finalTimeLabel;
  final int differenceMs;
  final String prizeLabel;
  final int prizeCoins;
  final bool isPrizeAwarded;
}

class HistoryEntry {
  const HistoryEntry({
    required this.timestamp,
    required this.timeLabel,
    required this.outcome,
  });

  final DateTime timestamp;
  final String timeLabel;
  final String outcome;
}

class GameState {
  const GameState({
    required this.selectedTab,
    required this.elapsed,
    required this.isRunning,
    required this.isSubmitting,
    required this.isLoadingTarget,
    required this.preparePhase,
    required this.isSoundEnabled,
    required this.startButtonVisualOffset,
    required this.startButtonHitboxOffset,
    required this.interactionSessionId,
    required this.latestInteractionPayload,
    required this.targetTime,
    required this.billingRequestId,
    required this.pendingBillingRequestId,
    required this.sessionRef,
    required this.activeSessionId,
    required this.roundErrorMessage,
    required this.latestResult,
    required this.history,
    required this.totalWins,
    required this.totalPrizeCoins,
  });

  const GameState.initial()
    : selectedTab = GameTab.home,
      elapsed = Duration.zero,
      isRunning = false,
      isSubmitting = false,
      isLoadingTarget = false,
      preparePhase = RoundPreparePhase.idle,
      isSoundEnabled = true,
      startButtonVisualOffset = Offset.zero,
      startButtonHitboxOffset = Offset.zero,
      interactionSessionId = 'bootstrap-session',
      latestInteractionPayload = null,
      targetTime = const Duration(milliseconds: 8200),
      billingRequestId = null,
      pendingBillingRequestId = null,
      sessionRef = null,
      activeSessionId = null,
      roundErrorMessage = null,
      latestResult = null,
      history = const [],
      totalWins = 0,
      totalPrizeCoins = 0;

  final GameTab selectedTab;
  final Duration elapsed;
  final bool isRunning;
  final bool isSubmitting;
  final bool isLoadingTarget;
  final RoundPreparePhase preparePhase;
  final bool isSoundEnabled;
  final Offset startButtonVisualOffset;
  final Offset startButtonHitboxOffset;
  final String interactionSessionId;
  final Map<String, dynamic>? latestInteractionPayload;
  final Duration targetTime;
  final String? billingRequestId;
  final String? pendingBillingRequestId;
  final String? sessionRef;
  final int? activeSessionId;
  final String? roundErrorMessage;
  final RoundResultData? latestResult;
  final List<HistoryEntry> history;
  final int totalWins;
  final int totalPrizeCoins;

  String get formattedTime {
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    final centiseconds = (elapsed.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds.$centiseconds';
  }

  bool get hasBillingForRound =>
      billingRequestId != null && billingRequestId!.isNotEmpty;

  bool get canStartRound =>
      hasBillingForRound &&
      !isLoadingTarget &&
      preparePhase == RoundPreparePhase.idle;

  /// Start/stop are allowed only after billing, or while a paid round is running.
  bool get canControlStopwatch => isRunning || canStartRound;

  /// True when start/stop (and pointer hitbox) must be inactive.
  bool get isStopwatchControlDisabled =>
      isSubmitting || isPreparingRound || !canControlStopwatch;

  bool get isPreparingRound => preparePhase != RoundPreparePhase.idle;

  bool get canTryAgainRound =>
      preparePhase == RoundPreparePhase.idle &&
      !hasBillingForRound &&
      !isRunning;

  String get targetTimeLabel =>
      _formatDuration(targetTime, withMilliseconds: true);
  String get elapsedTimeLabel =>
      _formatDuration(elapsed, withMilliseconds: true);

  static String _formatDuration(
    Duration value, {
    required bool withMilliseconds,
  }) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    final fraction = withMilliseconds
        ? value.inMilliseconds.remainder(1000).toString().padLeft(3, '0')
        : (value.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(
            2,
            '0',
          );
    return '$minutes:$seconds.$fraction';
  }

  GameState copyWith({
    GameTab? selectedTab,
    Duration? elapsed,
    bool? isRunning,
    bool? isSubmitting,
    bool? isLoadingTarget,
    RoundPreparePhase? preparePhase,
    bool? isSoundEnabled,
    Offset? startButtonVisualOffset,
    Offset? startButtonHitboxOffset,
    String? interactionSessionId,
    Map<String, dynamic>? latestInteractionPayload,
    bool clearLatestInteractionPayload = false,
    Duration? targetTime,
    String? billingRequestId,
    String? pendingBillingRequestId,
    bool clearPendingBilling = false,
    String? sessionRef,
    int? activeSessionId,
    String? roundErrorMessage,
    bool clearRoundError = false,
    bool clearActiveSession = false,
    RoundResultData? latestResult,
    bool clearLatestResult = false,
    List<HistoryEntry>? history,
    int? totalWins,
    int? totalPrizeCoins,
  }) {
    return GameState(
      selectedTab: selectedTab ?? this.selectedTab,
      elapsed: elapsed ?? this.elapsed,
      isRunning: isRunning ?? this.isRunning,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoadingTarget: isLoadingTarget ?? this.isLoadingTarget,
      preparePhase: preparePhase ?? this.preparePhase,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      startButtonVisualOffset:
          startButtonVisualOffset ?? this.startButtonVisualOffset,
      startButtonHitboxOffset:
          startButtonHitboxOffset ?? this.startButtonHitboxOffset,
      interactionSessionId: interactionSessionId ?? this.interactionSessionId,
      latestInteractionPayload: clearLatestInteractionPayload
          ? null
          : (latestInteractionPayload ?? this.latestInteractionPayload),
      targetTime: targetTime ?? this.targetTime,
      billingRequestId: clearActiveSession
          ? null
          : (billingRequestId ?? this.billingRequestId),
      pendingBillingRequestId: clearActiveSession || clearPendingBilling
          ? null
          : (pendingBillingRequestId ?? this.pendingBillingRequestId),
      sessionRef: clearActiveSession ? null : (sessionRef ?? this.sessionRef),
      activeSessionId: clearActiveSession
          ? null
          : (activeSessionId ?? this.activeSessionId),
      roundErrorMessage: clearRoundError
          ? null
          : (roundErrorMessage ?? this.roundErrorMessage),
      latestResult: clearLatestResult
          ? null
          : (latestResult ?? this.latestResult),
      history: history ?? this.history,
      totalWins: totalWins ?? this.totalWins,
      totalPrizeCoins: totalPrizeCoins ?? this.totalPrizeCoins,
    );
  }
}
