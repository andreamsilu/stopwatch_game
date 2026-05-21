import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/core/providers/player_session_provider.dart';
import 'package:stopwatch_game/core/utils/msisdn_format.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/game_top_navigation.dart';

/// Single header: tabs + logged-in user + logout (replaces two separate cards).
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(playerUserProvider);
    final msisdn = ref.watch(playerMsisdnProvider);
    final displayMsisdn = MsisdnFormat.display(user?.msisdn ?? msisdn);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stackUserBelow = constraints.maxWidth < 720;

            final tabs = _GameTabStrip(
              activeTab: widget.activeTab,
              onTabSelected: widget.onTabSelected,
            );

            final account = _AccountStrip(
              displayMsisdn: displayMsisdn,
              loggingOut: _loggingOut,
              onLogout: () async {
                setState(() => _loggingOut = true);
                try {
                  await widget.onLogout();
                } finally {
                  if (mounted) setState(() => _loggingOut = false);
                }
              },
            );

            if (stackUserBelow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  tabs,
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  account,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 2, child: account),
                const SizedBox(width: 16),
                Expanded(flex: 5, child: tabs),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GameTabStrip extends StatelessWidget {
  const _GameTabStrip({
    required this.activeTab,
    required this.onTabSelected,
  });

  final GameTab activeTab;
  final ValueChanged<GameTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return GameTopNavigation(
      activeTab: activeTab,
      onTabSelected: onTabSelected,
      embedded: true,
    );
  }
}

class _AccountStrip extends StatelessWidget {
  const _AccountStrip({
    required this.displayMsisdn,
    required this.loggingOut,
    required this.onLogout,
  });

  final String displayMsisdn;
  final bool loggingOut;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                GameCopy.loggedIn,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onBackground.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                displayMsisdn,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Icon(
          Icons.verified_user_outlined,
          size: 20,
          color: AppColors.primary.withValues(alpha: 0.55),
        ),
        const SizedBox(width: 4),
        IconButton.filledTonal(
          onPressed: loggingOut ? null : onLogout,
          tooltip: GameCopy.logOut,
          style: IconButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: AppColors.primary,
          ),
          icon: loggingOut
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout_rounded),
        ),
      ],
    );
  }
}
