import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/core/widgets/app_snackbar.dart';

/// Opens an https/http link in the platform browser or external app.
Future<void> launchExternalUrl(
  BuildContext context, {
  required String url,
  required String platformLabel,
}) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !(uri.scheme == 'https' || uri.scheme == 'http')) {
    if (context.mounted) {
      AppSnackBar.showError(
        context,
        GameCopy.socialLinkOpenFailed(platformLabel),
      );
    }
    return;
  }

  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      AppSnackBar.showError(
        context,
        GameCopy.socialLinkOpenFailed(platformLabel),
      );
    }
  } catch (_) {
    if (context.mounted) {
      AppSnackBar.showError(
        context,
        GameCopy.socialLinkOpenFailed(platformLabel),
      );
    }
  }
}
