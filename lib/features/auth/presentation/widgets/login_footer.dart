import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final mutedColor = AppColors.onBackground.withValues(alpha: 0.58);
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: const [
            _FooterLink(label: 'Privacy Policy'),
            _FooterLink(label: 'Terms of Service'),
            _FooterLink(label: 'Contact Support'),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '© ${DateTime.now().year} Chrono Precision. All rights reserved.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: mutedColor.withValues(alpha: 0.62),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        tapTargetSize: MaterialTapTargetSize.padded,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.onBackground.withValues(alpha: 0.55),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
