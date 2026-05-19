import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/providers/player_session_provider.dart';
import 'package:stopwatch_game/core/utils/msisdn_format.dart';

/// Shows the logged-in subscriber and their MSISDN.
class LoggedInUserBar extends ConsumerWidget {
  const LoggedInUserBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(playerUserProvider);
    final msisdn = ref.watch(playerMsisdnProvider);
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logged in',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onBackground.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayMsisdn,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (showUsername) ...[
                    const SizedBox(height: 2),
                    Text(
                      username,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onBackground.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.verified_user_outlined,
              size: 20,
              color: AppColors.primary.withValues(alpha: 0.55),
            ),
          ],
        ),
      ),
    );
  }
}
