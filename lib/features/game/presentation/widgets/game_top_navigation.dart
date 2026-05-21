import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';

class GameTopNavigation extends StatelessWidget {
  const GameTopNavigation({
    required this.activeTab,
    required this.onTabSelected,
    this.embedded = false,
    super.key,
  });

  final GameTab activeTab;
  final ValueChanged<GameTab> onTabSelected;

  /// When true, omits the outer [Card] (used inside [GameHeaderBar]).
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final tabs = GameTab.values;
    final content = LayoutBuilder(
          builder: (context, constraints) {
            final tabButtons = [
              for (var i = 0; i < tabs.length; i++) ...[
                _TabButton(
                  tab: tabs[i],
                  isActive: tabs[i] == activeTab,
                  onPressed: () => onTabSelected(tabs[i]),
                ),
                if (i < tabs.length - 1) const SizedBox(width: 8),
              ],
            ];

            // Narrow: scroll. Wide: equal-width tabs across the full bar.
            if (constraints.maxWidth < 520) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: tabButtons,
                ),
              );
            }

            return Row(
              children: [
                for (var i = 0; i < tabs.length; i++) ...[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: i == 0 ? 0 : 4,
                        right: i == tabs.length - 1 ? 0 : 4,
                      ),
                      child: _TabButton(
                        tab: tabs[i],
                        isActive: tabs[i] == activeTab,
                        onPressed: () => onTabSelected(tabs[i]),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        );

    if (embedded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: content,
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: content,
      ),
    );
  }
}

class _TabButton extends StatefulWidget {
  const _TabButton({
    required this.tab,
    required this.isActive,
    required this.onPressed,
  });

  final GameTab tab;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${_labelForTab(widget.tab)} tab',
      button: true,
      selected: widget.isActive,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: _isHovered && !widget.isActive ? 1.03 : 1,
          curve: Curves.easeOutCubic,
          child: SizedBox(
            width: double.infinity,
            height: GameConstants.minTouchTargetSize,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                gradient: widget.isActive
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.accent, AppColors.secondary],
                      )
                    : null,
                color: widget.isActive
                    ? null
                    : (_isHovered
                          ? AppColors.secondary.withValues(alpha: 0.14)
                          : Colors.transparent),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.isActive
                      ? AppColors.primary.withValues(alpha: 0.25)
                      : AppColors.primary.withValues(alpha: 0.1),
                ),
                boxShadow: widget.isActive
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: TextButton(
                onPressed: widget.onPressed,
                style: TextButton.styleFrom(
                  foregroundColor: widget.isActive
                      ? AppColors.onAccent
                      : AppColors.onBackground.withValues(alpha: 0.82),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(0, GameConstants.minTouchTargetSize),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(
                  _labelForTab(widget.tab),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _labelForTab(GameTab tab) {
    switch (tab) {
      case GameTab.home:
        return GameCopy.home;
      case GameTab.play:
        return GameCopy.playTab;
      case GameTab.history:
        return GameCopy.historyTab;
      case GameTab.support:
        return GameCopy.supportTab;
    }
  }
}
