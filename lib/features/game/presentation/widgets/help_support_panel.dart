import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/core/widgets/social_media_links.dart';

class HelpSupportPanel extends StatelessWidget {
  const HelpSupportPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              GameCopy.helpTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              GameCopy.helpIntro,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const _SupportItem(
              title: GameCopy.helpHowToPlayTitle,
              subtitle: GameCopy.helpHowToPlayBody,
            ),
            const SizedBox(height: 10),
            const _SupportItem(
              title: GameCopy.helpReportTitle,
              subtitle: GameCopy.helpReportBody,
            ),
            const SizedBox(height: 10),
            const _SupportItem(
              title: GameCopy.helpContactTitle,
              subtitle: GameCopy.helpContactBody,
            ),
            const SizedBox(height: 16),
            const Center(child: SocialMediaLinks()),
          ],
        ),
      ),
    );
  }
}

class _SupportItem extends StatelessWidget {
  const _SupportItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          Icons.help_outline,
          color: AppColors.primary,
          shadows: [
            Shadow(
              color: AppColors.accent.withValues(alpha: 0.35),
              blurRadius: 8,
            ),
          ],
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }
}
