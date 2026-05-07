import 'package:flutter/material.dart';

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
    required this.isSoundEnabled,
    required this.startButtonVisualOffset,
    required this.startButtonHitboxOffset,
    required this.interactionSessionId,
    required this.latestInteractionPayload,
    required this.targetTime,
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
      isSoundEnabled = true,
      startButtonVisualOffset = Offset.zero,
      startButtonHitboxOffset = Offset.zero,
      interactionSessionId = 'bootstrap-session',
      latestInteractionPayload = null,
      targetTime = const Duration(milliseconds: 8200),
      latestResult = null,
      history = const [],
      totalWins = 0,
      totalPrizeCoins = 0;

  final GameTab selectedTab;
  final Duration elapsed;
  final bool isRunning;
  final bool isSubmitting;
  final bool isSoundEnabled;
  final Offset startButtonVisualOffset;
  final Offset startButtonHitboxOffset;
  final String interactionSessionId;
  final Map<String, dynamic>? latestInteractionPayload;
  final Duration targetTime;
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
    bool? isSoundEnabled,
    Offset? startButtonVisualOffset,
    Offset? startButtonHitboxOffset,
    String? interactionSessionId,
    Map<String, dynamic>? latestInteractionPayload,
    bool clearLatestInteractionPayload = false,
    Duration? targetTime,
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
      latestResult: clearLatestResult
          ? null
          : (latestResult ?? this.latestResult),
      history: history ?? this.history,
      totalWins: totalWins ?? this.totalWins,
      totalPrizeCoins: totalPrizeCoins ?? this.totalPrizeCoins,
    );
  }
}
