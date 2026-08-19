import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
/// Shared site footer — uses [Theme] / [AppColors] like the rest of the app.
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

  static const _borderColor = Color(0xFFD6DFEA);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final muted = colorScheme.onSurface.withValues(alpha: 0.62);
    final year = DateTime.now().year;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: const Border(top: BorderSide(color: _borderColor)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            GameCopy.appName,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.primary,
              letterSpacing: 0.15,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            GameCopy.footerCopyright(year),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: muted,
              height: 1.2,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 0,
            runSpacing: 0,
            children: [
              _FooterLink(
                label: GameCopy.termsOfService,
                onPressed: onTerms,
                color: colorScheme.primary,
              ),
              _FooterDot(color: muted),
              _FooterLink(
                label: GameCopy.privacyPolicy,
                onPressed: onPrivacy,
                color: colorScheme.primary,
              ),
              _FooterDot(color: muted),
              _FooterLink(
                label: GameCopy.contactSupport,
                onPressed: onContactSupport,
                color: colorScheme.secondary,
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
        style: TextStyle(color: color.withValues(alpha: 0.45), fontSize: 11),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.label,
    required this.color,
    this.onPressed,
  });

  final String label;
  final Color color;
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
        foregroundColor: color,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.05,
          height: 1.1,
          color: color,
        ),
      ),
    );
  }
}
