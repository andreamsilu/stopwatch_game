import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/how_to_play_steps_card.dart';

class HomeOverviewPanel extends StatelessWidget {
  const HomeOverviewPanel({
    required this.onPlayPressed,
    required this.onOpenHistory,
    required this.onOpenTips,
    super.key,
  });

  final VoidCallback onPlayPressed;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenTips;

  static const _cardRadius = 24.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroCard(onPlayPressed: onPlayPressed),
        const SizedBox(height: 14),
        const HowToPlayStepsCard(),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 560;
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HomeFeatureCard(
                    title: GameCopy.historyCardTitle,
                    body: GameCopy.historyCardSubtitle,
                    actionLabel: GameCopy.viewHistoryLink,
                    actionColor: AppColors.secondary,
                    icon: Icons.history_rounded,
                    iconBackground: AppColors.secondary.withValues(alpha: 0.18),
                    iconColor: AppColors.primary,
                    watermarkIcon: Icons.history_rounded,
                    onAction: onOpenHistory,
                  ),
                  const SizedBox(height: 12),
                  _HomeFeatureCard(
                    title: GameCopy.howToPlayTitle,
                    body: GameCopy.howToPlayTipsBody,
                    actionLabel: GameCopy.learnTipsLink,
                    actionColor: const Color(0xFFB8860B),
                    icon: Icons.lightbulb_outline_rounded,
                    iconBackground: AppColors.accent.withValues(alpha: 0.28),
                    iconColor: const Color(0xFFB8860B),
                    watermarkIcon: Icons.lightbulb_outline_rounded,
                    onAction: onOpenTips,
                  ),
                ],
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _HomeFeatureCard(
                      title: GameCopy.historyCardTitle,
                      body: GameCopy.historyCardSubtitle,
                      actionLabel: GameCopy.viewHistoryLink,
                      actionColor: AppColors.secondary,
                      icon: Icons.history_rounded,
                      iconBackground:
                          AppColors.secondary.withValues(alpha: 0.18),
                      iconColor: AppColors.primary,
                      watermarkIcon: Icons.history_rounded,
                      onAction: onOpenHistory,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HomeFeatureCard(
                      title: GameCopy.howToPlayTitle,
                      body: GameCopy.howToPlayTipsBody,
                      actionLabel: GameCopy.learnTipsLink,
                      actionColor: const Color(0xFFB8860B),
                      icon: Icons.lightbulb_outline_rounded,
                      iconBackground: AppColors.accent.withValues(alpha: 0.28),
                      iconColor: const Color(0xFFB8860B),
                      watermarkIcon: Icons.lightbulb_outline_rounded,
                      onAction: onOpenTips,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onPlayPressed});

  final VoidCallback onPlayPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallMobile = constraints.maxWidth < 380;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(HomeOverviewPanel._cardRadius),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1200377D),
                blurRadius: 22,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isSmallMobile ? 18 : 24,
            vertical: isSmallMobile ? 20 : 24,
          ),
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
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                GameCopy.appName,
                textAlign: TextAlign.center,
                style: (isSmallMobile
                        ? Theme.of(context).textTheme.headlineSmall
                        : Theme.of(context).textTheme.displaySmall)
                    ?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                GameCopy.homeHeadline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                GameCopy.homeTagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onBackground.withValues(alpha: 0.78),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                GameCopy.homeWinLine,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB8860B),
                ),
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
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(GameCopy.goToPlayRound),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeFeatureCard extends StatefulWidget {
  const _HomeFeatureCard({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.actionColor,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.watermarkIcon,
    required this.onAction,
  });

  final String title;
  final String body;
  final String actionLabel;
  final Color actionColor;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final IconData watermarkIcon;
  final VoidCallback onAction;

  @override
  State<_HomeFeatureCard> createState() => _HomeFeatureCardState();
}

class _HomeFeatureCardState extends State<_HomeFeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.title,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.01 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onAction,
              borderRadius: BorderRadius.circular(HomeOverviewPanel._cardRadius),
              child: Ink(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      BorderRadius.circular(HomeOverviewPanel._cardRadius),
                  border: Border.all(
                    color: _isHovered
                        ? widget.actionColor.withValues(alpha: 0.45)
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: _isHovered ? 0.14 : 0.07,
                      ),
                      blurRadius: _isHovered ? 18 : 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: widget.iconBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.iconColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.body,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              height: 1.45,
                              color: AppColors.onBackground.withValues(alpha: 0.72),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.actionLabel,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: widget.actionColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 4,
                      child: IgnorePointer(
                        child: Icon(
                          widget.watermarkIcon,
                          size: 72,
                          color: AppColors.onBackground.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
