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
                          offset: Offset(0, 5),
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
                  minimumSize: const Size(86, GameConstants.minTouchTargetSize),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
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
        return 'Home';
      case GameTab.play:
        return 'Play';
      case GameTab.history:
        return 'History';
      case GameTab.support:
        return 'Support';
    }
  }
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      