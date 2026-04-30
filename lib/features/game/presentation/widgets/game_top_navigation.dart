import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';

class GameTopNavigation extends StatelessWidget {
  const GameTopNavigation({
    required this.activeTab,
    required this.onTabSelected,
    super.key,
  });

  final GameTab activeTab;
  final ValueChanged<GameTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final tabs = GameTab.values;
    return Card(
      margin: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final tab in tabs) ...[
                      _TabButton(
                        tab: tab,
                        isActive: tab == activeTab,
                        onPressed: () => onTabSelected(tab),
                      ),
                      if (tab != tabs.last) const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.isActive,
    required this.onPressed,
  });

  final GameTab tab;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${_labelForTab(tab)} tab',
      button: true,
      selected: isActive,
      child: SizedBox(
        height: GameConstants.minTouchTargetSize,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? const [
                    BoxShadow(
                      color: Color(0x26A88300),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: isActive
                  ? AppColors.onAccent
                  : AppColors.onBackground.withValues(alpha: 0.82),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(86, GameConstants.minTouchTargetSize),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            child: Text(
              _labelForTab(tab),
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  String _labelForTab(GameTab tab) {
    switch (tab) {
      case GameTab.home:
        return 'Home';
      case GameTab.play:
        return 'Play';
      case GameTab.leaderboard:
        return 'Leaderboard';
      case GameTab.history:
        return 'History';
      case GameTab.settings:
        return 'Settings';
    }
  }
}
