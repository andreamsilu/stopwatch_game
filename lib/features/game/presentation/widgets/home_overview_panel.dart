import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';

class HomeOverviewPanel extends StatelessWidget {
  const HomeOverviewPanel({
    required this.onPlayPressed,
    required this.onOpenHistory,
    super.key,
  });

  final VoidCallback onPlayPressed;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.98, end: 1),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Card(
            margin: EdgeInsets.zero,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallMobile = constraints.maxWidth < 380;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.background,
                        AppColors.secondary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallMobile ? 16 : 24,
                      vertical: isSmallMobile ? 20 : 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(34),
                          ),
                          child: const Icon(
                            Icons.timer_outlined,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Beat the Clock',
                          style: (isSmallMobile
                                  ? textTheme.headlineSmall
                                  : textTheme.displaySmall)
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Stop as close as possible to the target to win coins.',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            _StatPill(
                              icon: Icons.bolt_rounded,
                              label: 'Win window',
                              value: '±100 ms',
                            ),
                            _StatPill(
                              icon: Icons.graphic_eq_rounded,
                              label: 'Rhythm',
                              value: '1s beat',
                            ),
                            _StatPill(
                              icon: Icons.monetization_on_outlined,
                              label: 'Reward',
                              value: '+100 coins',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final compactActions = constraints.maxWidth < 520;
                            final playButton = SizedBox(
                              height: GameConstants.minTouchTargetSize + 6,
                              child: ElevatedButton.icon(
                                onPressed: onPlayPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: AppColors.onAccent,
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Start Round'),
                              ),
                            );
                            final historyButton = SizedBox(
                              height: GameConstants.minTouchTargetSize + 6,
                              child: OutlinedButton.icon(
                                onPressed: onOpenHistory,
                                icon: const Icon(Icons.history),
                                label: const Text('View History'),
                              ),
                            );
                            if (compactActions) {
                              return Column(
                                children: [
                                  SizedBox(width: double.infinity, child: playButton),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: historyButton,
                                  ),
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(child: playButton),
                                const SizedBox(width: 10),
                                Expanded(child: historyButton),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
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
                    title: 'How to play',
                    subtitle: 'Start, track the beat, stop near target.',
                    icon: Icons.rocket_launch_outlined,
                    onTap: onPlayPressed,
                  ),
                  const SizedBox(height: 10),
                  _QuickCard(
                    title: 'History',
                    subtitle: 'View your recent round results',
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
                    title: 'How to play',
                    subtitle: 'Start, track the beat, stop near target.',
                    icon: Icons.rocket_launch_outlined,
                    onTap: onPlayPressed,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickCard(
                    title: 'History',
                    subtitle: 'View your recent round results',
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

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          RichText(
            text: TextSpan(
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.onBackground),
              children: [
                TextSpan(text: '$label: '),
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatefulWidget {
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
  State<_QuickCard> createState() => _QuickCardState();
}

class _QuickCardState extends State<_QuickCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${widget.title} section',
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          scale: _isHovered ? 1.01 : 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: widget.onTap,
            splashColor: AppColors.secondary.withValues(alpha: 0.14),
            highlightColor: AppColors.secondary.withValues(alpha: 0.08),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.background,
                    AppColors.secondary.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isHovered
                      ? AppColors.accent.withValues(alpha: 0.55)
                      : AppColors.primary.withValues(alpha: 0.08),
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.16),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Card(
                margin: EdgeInsets.zero,
                color: Colors.transparent,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(widget.icon, size: 18, color: AppColors.primary),
                      const SizedBox(height: 10),
                      Text(
                        widget.title,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
