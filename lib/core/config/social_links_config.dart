import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stopwatch_game/core/config/env_config.dart';

/// A single external social profile link.
class SocialMediaLink {
  const SocialMediaLink({
    required this.platform,
    required this.url,
    required this.icon,
  });

  final String platform;
  final String url;
  final IconData icon;
}

/// Social URLs from `.env` — only non-empty entries are shown.
class SocialLinksConfig {
  SocialLinksConfig._();

  static List<SocialMediaLink> get activeLinks {
    final links = <SocialMediaLink>[];

    void add(String platform, String url, IconData icon) {
      final trimmed = url.trim();
      if (trimmed.isEmpty) return;
      links.add(SocialMediaLink(platform: platform, url: trimmed, icon: icon));
    }

    add('Facebook', EnvConfig.socialFacebookUrl, FontAwesomeIcons.facebook);
    add('Instagram', EnvConfig.socialInstagramUrl, FontAwesomeIcons.instagram);
    add('X', EnvConfig.socialXUrl, FontAwesomeIcons.xTwitter);
    add('YouTube', EnvConfig.socialYoutubeUrl, FontAwesomeIcons.youtube);

    return links;
  }
}
