enum GameTab { home, play, leaderboard, history, support }

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.playerName,
    required this.points,
    required this.bestTime,
    required this.errorMs,
    required this.consistency,
    required this.isCurrentUser,
  });

  final int rank;
  final String playerName;
  final int points;
  final String bestTime;
  final int errorMs;
  final int consistency;
  final bool isCurrentUser;
}

class RoundResultData {
  const RoundResultData({
    required this.outcomeLabel,
    required this.deltaLabel,
    required this.finalTimeLabel,
    required this.differenceMs,
  });

  final String outcomeLabel;
  final String deltaLabel;
  final String finalTimeLabel;
  final int differenceMs;
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
    required this.targetTime,
    required this.latestResult,
    required this.leaderboard,
    required this.history,
  });

  const GameState.initial()
    : selectedTab = GameTab.home,
      elapsed = Duration.zero,
      isRunning = false,
      isSubmitting = false,
      targetTime = const Duration(milliseconds: 8200),
      latestResult = null,
      leaderboard = const [
        LeaderboardEntry(
          rank: 1,
          playerName: 'Alex Chen',
          points: 1110,
          bestTime: '00:08.420',
          errorMs: 12,
          consistency: 940,
          isCurrentUser: false,
        ),
        LeaderboardEntry(
          rank: 2,
          playerName: 'Sara Wallace',
          points: 1045,
          bestTime: '00:08.954',
          errorMs: 20,
          consistency: 900,
          isCurrentUser: false,
        ),
        LeaderboardEntry(
          rank: 3,
          playerName: 'Marcus Allen',
          points: 998,
          bestTime: '00:08.991',
          errorMs: 27,
          consistency: 860,
          isCurrentUser: false,
        ),
        LeaderboardEntry(
          rank: 4,
          playerName: 'Precision Master',
          points: 940,
          bestTime: '00:09.152',
          errorMs: 36,
          consistency: 810,
          isCurrentUser: true,
        ),
        LeaderboardEntry(
          rank: 5,
          playerName: 'Jordan Smith',
          points: 910,
          bestTime: '00:09.300',
          errorMs: 41,
          consistency: 790,
          isCurrentUser: false,
        ),
      ],
      history = const [];

  final GameTab selectedTab;
  final Duration elapsed;
  final bool isRunning;
  final bool isSubmitting;
  final Duration targetTime;
  final RoundResultData? latestResult;
  final List<LeaderboardEntry> leaderboard;
  final List<HistoryEntry> history;

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
    Duration? targetTime,
    RoundResultData? latestResult,
    bool clearLatestResult = false,
    List<LeaderboardEntry>? leaderboard,
    List<HistoryEntry>? history,
  }) {
    return GameState(
      selectedTab: selectedTab ?? this.selectedTab,
      elapsed: elapsed ?? this.elapsed,
      isRunning: isRunning ?? this.isRunning,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      targetTime: targetTime ?? this.targetTime,
      latestResult: clearLatestResult
          ? null
          : (latestResult ?? this.latestResult),
      leaderboard: leaderboard ?? this.leaderboard,
      history: history ?? this.history,
    );
  }
}
