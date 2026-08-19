import 'package:flutter/material.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/round_prepare_phase.dart';

enum GameTab { play, history, howToPlay, support }

class RoundResultData {
  const RoundResultData({
    required this.outcomeLabel,
    required this.deltaLabel,
    required this.targetTimeLabel,
    required this.finalTimeLabel,
    required this.differenceMs,
    required this.prizeLabel,
    required this.prizeCoins,
    required this.isPrizeAwarded,
  });

  final String outcomeLabel;
  final String deltaLabel;
  final String targetTimeLabel;
  final String finalTimeLabel;
  final int differenceMs;
  final String prizeLabel;
  final int prizeCoins;
  final bool isPrizeAwarded;
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
    required this.statusMessage,
    required this.latestResult,
    required this.totalWins,
    required this.roundsPlayed,
    required this.bestDifferenceAbsMs,
  });

  const GameState.initial()
    : selectedTab = GameTab.play,
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
      targetTime = Duration.zero,
      billingRequestId = null,
      pendingBillingRequestId = null,
      sessionRef = null,
      activeSessionId = null,
      roundErrorMessage = null,
      statusMessage = null,
      latestResult = null,
      totalWins = 0,
      roundsPlayed = 0,
      bestDifferenceAbsMs = null;

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
  final String? statusMessage;
  final RoundResultData? latestResult;
  final int totalWins;
  final int roundsPlayed;
  final int? bestDifferenceAbsMs;

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

  /// Start/stop tap on the billed control only.
  bool get canTapStartRound => isRunning || (canStartRound && !isSubmitting);

  /// Play (charge round) before billing is complete.
  bool get canTapPlayRound =>
      !hasBillingForRound && !isSubmitting && !isPreparingRound;

  /// Start/stop control is active while running or when start can be tapped.
  bool get canControlStopwatch => isRunning || canTapStartRound;

  /// True when start/stop (and pointer hitbox) must be inactive.
  bool get isStopwatchControlDisabled =>
      isSubmitting || isPreparingRound || !canControlStopwatch;

  bool get isPreparingRound => preparePhase != RoundPreparePhase.idle;

  String get targetTimeLabel => formatTargetTime(targetTime);
  String get elapsedTimeLabel =>
      _formatDuration(elapsed, withMilliseconds: true);

  /// Target display: `mm:ss.ms` (e.g. `00:00.000`, `00:08.200`).
  static String formatTargetTime(Duration value) =>
      _formatDuration(value, withMilliseconds: true);

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
    String? statusMessage,
    bool clearStatusMessage = false,
    bool clearActiveSession = false,
    RoundResultData? latestResult,
    bool clearLatestResult = false,
    int? totalWins,
    int? roundsPlayed,
    int? bestDifferenceAbsMs,
    bool clearBestDifference = false,
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
      statusMessage: clearStatusMessage
          ? null
          : (statusMessage ?? this.statusMessage),
      latestResult: clearLatestResult
          ? null
          : (latestResult ?? this.latestResult),
      totalWins: totalWins ?? this.totalWins,
      roundsPlayed: roundsPlayed ?? this.roundsPlayed,
      bestDifferenceAbsMs: clearBestDifference
          ? null
          : (bestDifferenceAbsMs ?? this.bestDifferenceAbsMs),
    );
  }
}
