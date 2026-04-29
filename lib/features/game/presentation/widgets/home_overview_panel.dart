import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';

class HomeOverviewPanel extends StatelessWidget {
  const HomeOverviewPanel({
    required this.onPlayPressed,
    required this.onOpenLeaderboard,
    required this.onOpenHistory,
    super.key,
  });

  final VoidCallback onPlayPressed;
  final VoidCallback onOpenLeaderboard;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(
                    Icons.timer_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'STOPWATCH',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Stop at the perfect time',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: GameConstants.minTouchTargetSize + 6,
                  child: ElevatedButton.icon(
                    onPressed: onPlayPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.onAccent,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('PLAY'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 560;
            if (compact) {
              return Column(
                children: [
                  _QuickCard(
                    title: 'Leaderboard',
                    subtitle: 'Rank #124 globally',
                    icon: Icons.emoji_events_outlined,
                    onTap: onOpenLeaderboard,
                  ),
                  const SizedBox(height: 10),
                  _QuickCard(
                    title: 'History',
                    subtitle: 'Last: 00:05.02',
                    icon: Icons.history,
                    onTap: onOpenHistory,
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: _QuickCard(
                    title: 'Leaderboard',
                    subtitle: 'Rank #124 globally',
                    icon: Icons.emoji_events_outlined,
                    onTap: onOpenLeaderboard,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickCard(
                    title: 'History',
                    subtitle: 'Last: 00:05.02',
                    icon: Icons.history,
                    onTap: onOpenHistory,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title section',
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Card(
          margin: EdgeInsets.zero,
          color: AppColors.secondary.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
