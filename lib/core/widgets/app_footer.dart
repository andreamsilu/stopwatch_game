import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';

/// Shared site footer — title, copyright, and legal/support links.
class AppFooter extends StatelessWidget {
  const AppFooter({
    this.onTerms,
    this.onPrivacy,
    this.onContactSupport,
    super.key,
  });

  final VoidCallback? onTerms;
  final VoidCallback? onPrivacy;
  final VoidCallback? onContactSupport;

  static const _titleColor = Color(0xFF6B5B2E);

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.onBackground.withValues(alpha: 0.62);
    final year = DateTime.now().year;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 2),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFE8EEF4),
            Color(0xFFF5F1E8),
          ],
        ),
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            GameCopy.appName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: _titleColor,
              letterSpacing: 0.15,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            GameCopy.footerCopyright(year),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: muted,
              height: 1.2,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 0,
            runSpacing: 0,
            children: [
              _FooterLink(
                label: GameCopy.termsOfService,
                onPressed: onTerms,
              ),
              _FooterDot(color: muted),
              _FooterLink(
                label: GameCopy.privacyPolicy,
                onPressed: onPrivacy,
              ),
              _FooterDot(color: muted),
              _FooterLink(
                label: GameCopy.contactSupport,
                onPressed: onContactSupport,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterDot extends StatelessWidget {
  const _FooterDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        '·',
        style: TextStyle(color: color.withValues(alpha: 0.5), fontSize: 11),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(32, 24),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
        visualDensity: VisualDensity.compact,
        foregroundColor: AppColors.onBackground.withValues(alpha: 0.65),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.05,
          height: 1.1,
        ),
      ),
    );
  }
}
