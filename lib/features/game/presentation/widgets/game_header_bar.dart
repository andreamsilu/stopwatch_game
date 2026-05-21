import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/core/providers/player_session_provider.dart';
import 'package:stopwatch_game/core/utils/msisdn_format.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';

/// App header: primary tab strip + compact account actions on the right.
class GameHeaderBar extends ConsumerStatefulWidget {
  const GameHeaderBar({
    required this.activeTab,
    required this.onTabSelected,
    required this.onLogout,
    super.key,
  });

  final GameTab activeTab;
  final ValueChanged<GameTab> onTabSelected;
  final Future<void> Function() onLogout;

  @override
  ConsumerState<GameHeaderBar> createState() => _GameHeaderBarState();
}

class _GameHeaderBarState extends ConsumerState<GameHeaderBar> {
  bool _loggingOut = false;

  Future<void> _handleLogout() async {
    setState(() => _loggingOut = true);
    try {
      await widget.onLogout();
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final msisdn = ref.watch(playerMsisdnProvider);
    final user = ref.watch(playerUserProvider);
    final displayMsisdn = MsisdnFormat.display(user?.msisdn ?? msisdn);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 640;
            final tabs = _HeaderTabStrip(
              activeTab: widget.activeTab,
              onTabSelected: widget.onTabSelected,
            );
            final account = _HeaderAccountActions(
              displayMsisdn: displayMsisdn,
              loggingOut: _loggingOut,
              onLogout: _handleLogout,
              compact: narrow,
            );

            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  tabs,
                  const SizedBox(height: 10),
                  account,
                ],
              );
            }

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: tabs),
                  const SizedBox(width: 12),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AppColors.primary.withValues(alpha: 0.12),
                  ),
                  const SizedBox(width: 8),
                  account,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderTabStrip extends StatelessWidget {
  const _HeaderTabStrip({
    required this.activeTab,
    required this.onTabSelected,
  });

  final GameTab activeTab;
  final ValueChanged<GameTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final tabs = GameTab.values;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 400) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < tabs.length; i++) ...[
                      _HeaderTabButton(
                        label: _labelForTab(tabs[i]),
                        isActive: tabs[i] == activeTab,
                        onPressed: () => onTabSelected(tabs[i]),
                      ),
                      if (i < tabs.length - 1) const SizedBox(width: 6),
                    ],
                  ],
                ),
              );
            }

            return Row(
              children: [
                for (var i = 0; i < tabs.length; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: i == 0 ? 0 : 3),
                      child: _HeaderTabButton(
                        label: _labelForTab(tabs[i]),
                        isActive: tabs[i] == activeTab,
                        onPressed: () => onTabSelected(tabs[i]),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _labelForTab(GameTab tab) {
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

class _HeaderTabButton extends StatefulWidget {
  const _HeaderTabButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  State<_HeaderTabButton> createState() => _HeaderTabButtonState();
}

class _HeaderTabButtonState extends State<_HeaderTabButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        height: GameConstants.minTouchTargetSize - 4,
        decoration: BoxDecoration(
          gradient: widget.isActive
              ? const LinearGradient(
                  colors: [AppColors.accent, AppColors.secondary],
                )
              : null,
          color: widget.isActive
              ? null
              : (_hovered
                    ? AppColors.secondary.withValues(alpha: 0.12)
                    : Colors.transparent),
          borderRadius: BorderRadius.circular(9),
          boxShadow: widget.isActive
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(9),
            child: Center(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: widget.isActive
                      ? AppColors.onAccent
                      : AppColors.onBackground.withValues(alpha: 0.85),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderAccountActions extends StatelessWidget {
  const _HeaderAccountActions({
    required this.displayMsisdn,
    required this.loggingOut,
    required this.onLogout,
    required this.compact,
  });

  final String displayMsisdn;
  final bool loggingOut;
  final VoidCallback onLogout;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final phone = Text(
      displayMsisdn,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (compact) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              const _AvatarChip(),
              const SizedBox(width: 10),
              Expanded(child: phone),
              _LogoutButton(
                loggingOut: loggingOut,
                onLogout: onLogout,
                tooltip: displayMsisdn,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _AvatarChip(),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 168),
            child: phone,
          ),
          const SizedBox(width: 6),
          _LogoutButton(
            loggingOut: loggingOut,
            onLogout: onLogout,
            tooltip: displayMsisdn,
          ),
        ],
      ),
    );
  }
}

class _AvatarChip extends StatelessWidget {
  const _AvatarChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.person_outline_rounded,
        color: AppColors.primary,
        size: 20,
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({
    required this.loggingOut,
    required this.onLogout,
    required this.tooltip,
  });

  final bool loggingOut;
  final VoidCallback onLogout;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: loggingOut ? null : onLogout,
      tooltip: '${GameCopy.logOut}\n$tooltip',
      style: IconButton.styleFrom(
        visualDensity: VisualDensity.compact,
        minimumSize: const Size(40, 40),
        foregroundColor: AppColors.primary,
      ),
      icon: loggingOut
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.logout_rounded, size: 22),
    );
  }
}
