import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/core/providers/player_session_provider.dart';
import 'package:stopwatch_game/core/utils/msisdn_format.dart';
import 'package:stopwatch_game/core/widgets/app_logo.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';

/// Centered nav tabs with account avatar + menu on the right.
class GameHeaderBar extends ConsumerStatefulWidget {
  const GameHeaderBar({
    required this.activeTab,
    required this.navigationEnabled,
    required this.onTabSelected,
    required this.onLogout,
    super.key,
  });

  final GameTab activeTab;
  final bool navigationEnabled;
  final ValueChanged<GameTab> onTabSelected;
  final Future<void> Function() onLogout;

  static const double _sideSlotWidth = 52;
  static const double _logoSize = 36;

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
    final username = user?.username;
    final showUsername =
        username != null &&
        username.isNotEmpty &&
        username != user?.msisdn &&
        username != msisdn;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabs = _CenteredTabStrip(
              activeTab: widget.activeTab,
              enabled: widget.navigationEnabled,
              onTabSelected: widget.onTabSelected,
            );
            final avatar = _AvatarAccountMenu(
              displayMsisdn: displayMsisdn,
              subtitle: showUsername ? username : null,
              loggingOut: _loggingOut,
              onLogout: _handleLogout,
            );

            const logo = AppLogo(size: GameHeaderBar._logoSize);

            if (constraints.maxWidth < 560) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [logo, const Spacer(), avatar]),
                  const SizedBox(height: 8),
                  Center(child: tabs),
                ],
              );
            }

            return SizedBox(
              height: GameConstants.minTouchTargetSize + 4,
              child: Row(
                children: [
                  SizedBox(
                    width: GameHeaderBar._sideSlotWidth,
                    child: Align(alignment: Alignment.centerLeft, child: logo),
                  ),
                  Expanded(child: Center(child: tabs)),
                  SizedBox(
                    width: GameHeaderBar._sideSlotWidth,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: avatar,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CenteredTabStrip extends StatelessWidget {
  const _CenteredTabStrip({
    required this.activeTab,
    required this.enabled,
    required this.onTabSelected,
  });

  final GameTab activeTab;
  final bool enabled;
  final ValueChanged<GameTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final tabs = GameTab.values;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            _HeaderTabButton(
              label: _labelForTab(tabs[i]),
              isActive: tabs[i] == activeTab,
              onPressed: enabled ? () => onTabSelected(tabs[i]) : null,
            ),
            if (i < tabs.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  static String _labelForTab(GameTab tab) {
    switch (tab) {
      case GameTab.play:
        return GameCopy.playTab;
      case GameTab.history:
        return GameCopy.historyTab;
      case GameTab.howToPlay:
        return GameCopy.howToPlayTab;
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
  final VoidCallback? onPressed;

  @override
  State<_HeaderTabButton> createState() => _HeaderTabButtonState();
}

class _HeaderTabButtonState extends State<_HeaderTabButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.onPressed == null
          ? null
          : (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: widget.onPressed == null && !widget.isActive ? 0.42 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: GameConstants.minTouchTargetSize,
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
                : (_hovered
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Center(
                  child: Text(
                    widget.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: widget.isActive
                          ? AppColors.onAccent
                          : AppColors.onBackground.withValues(alpha: 0.82),
                    ),
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

class _AvatarAccountMenu extends StatelessWidget {
  const _AvatarAccountMenu({
    required this.displayMsisdn,
    required this.loggingOut,
    required this.onLogout,
    this.subtitle,
  });

  final String displayMsisdn;
  final String? subtitle;
  final bool loggingOut;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      enabled: !loggingOut,
      offset: const Offset(0, 8),
      tooltip: GameCopy.loggedIn,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'logout') onLogout();
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                GameCopy.loggedIn,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onBackground.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayMsisdn,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onBackground.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 20, color: AppColors.primary),
              SizedBox(width: 10),
              Text(GameCopy.logOut),
            ],
          ),
        ),
      ],
      child: loggingOut
          ? const SizedBox(
              width: 40,
              height: 40,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.22),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
    );
  }
}
