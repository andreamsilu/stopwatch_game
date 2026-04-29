import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';

class LeaderboardPanel extends StatelessWidget {
  const LeaderboardPanel({required this.entries, super.key});

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leaderboard',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Top precision players',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            if (entries.isEmpty)
              Text(
                'No leaderboard entries yet. Complete rounds to start ranking.',
                style: Theme.of(context).textTheme.bodyLarge,
              )
            else
              for (final entry in entries) ...[
                _LeaderboardTile(entry: entry),
                if (entry != entries.last) const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: entry.isCurrentUser
                ? const Color(0xFFEAF2FF)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD6DFEA)),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${entry.rank}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.emoji_events_outlined,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.playerName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '${entry.points} pts',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    if (entry.isCurrentUser) ...[
                      const SizedBox(height: 4),
                      Text('You', style: Theme.of(context).textTheme.bodySmall),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      'Best: ${entry.bestTime} (error ${entry.errorMs} ms)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Consistency: ${entry.consistency}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.rank}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.emoji_events_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.playerName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (entry.isCurrentUser)
                            Text('You', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${entry.points} pts',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Best: ${entry.bestTime} (error ${entry.errorMs} ms)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'Consistency: ${entry.consistency}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }
}
