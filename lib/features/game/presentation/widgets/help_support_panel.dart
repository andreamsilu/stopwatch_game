import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';

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
              'Help & Support',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Need assistance with Stopwatch Challenge? Use these quick support channels.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const _SupportItem(
              title: 'How to play',
              subtitle: 'Start the round, stop near target time, and improve precision.',
            ),
            const SizedBox(height: 10),
            const _SupportItem(
              title: 'Report an issue',
              subtitle: 'Send game bugs or unexpected behavior to support team.',
            ),
            const SizedBox(height: 10),
            const _SupportItem(
              title: 'Contact support',
              subtitle: 'Email: support@stopwatchchallenge.app',
            ),
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6DFEA)),
      ),
      child: ListTile(
        leading: const Icon(Icons.help_outline, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }
}
