import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stopwatch_game/core/config/social_links_config.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/core/utils/external_url_launcher.dart';

/// Row of branded social icons — Facebook plus any URLs set in `.env`.
class SocialMediaLinks extends StatelessWidget {
  const SocialMediaLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final links = SocialLinksConfig.activeLinks;
    if (links.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          GameCopy.followUs,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface.withValues(alpha: 0.65),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final link in links)
              _SocialIconButton(
                link: link,
                color: _iconColor(link.platform, colorScheme),
              ),
          ],
        ),
      ],
    );
  }

  static Color _iconColor(String platform, ColorScheme colorScheme) {
    switch (platform) {
      case 'Facebook':
        return const Color(0xFF1877F2);
      case 'Instagram':
        return const Color(0xFFE4405F);
      case 'X':
        return colorScheme.onSurface.withValues(alpha: 0.85);
      case 'YouTube':
        return const Color(0xFFFF0000);
      default:
        return colorScheme.primary;
    }
  }
}

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({required this.link, required this.color});

  final SocialMediaLink link;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${GameCopy.followUs} ${link.platform}',
      child: IconButton(
        onPressed: () => launchExternalUrl(
          context,
          url: link.url,
          platformLabel: link.platform,
        ),
        icon: FaIcon(link.icon, size: 20, color: color),
        style: IconButton.styleFrom(
          minimumSize: const Size(40, 40),
          padding: const EdgeInsets.all(8),
          visualDensity: VisualDensity.compact,
        ),
        tooltip: link.platform,
      ),
    );
  }
}
