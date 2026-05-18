import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';

enum AppSnackBarType { success, error, info, warning }

/// Consistent, user-facing feedback via [SnackBar].
class AppSnackBar {
  const AppSnackBar._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message: message, type: AppSnackBarType.success);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message: message, type: AppSnackBarType.error);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message: message, type: AppSnackBarType.info);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message: message, type: AppSnackBarType.warning);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required AppSnackBarType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();

    final (icon, background, foreground) = _styleFor(type);

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
        action: SnackBarAction(
          label: 'OK',
          textColor: foreground.withValues(alpha: 0.92),
          onPressed: messenger.hideCurrentSnackBar,
        ),
      ),
    );
  }

  static (IconData, Color, Color) _styleFor(AppSnackBarType type) {
    switch (type) {
      case AppSnackBarType.success:
        return (
          Icons.check_circle_rounded,
          const Color(0xFF1B5E20),
          Colors.white,
        );
      case AppSnackBarType.error:
        return (
          Icons.error_outline_rounded,
          const Color(0xFFB3261E),
          Colors.white,
        );
      case AppSnackBarType.warning:
        return (
          Icons.warning_amber_rounded,
          const Color(0xFF7A5C00),
          AppColors.onAccent,
        );
      case AppSnackBarType.info:
        return (
          Icons.info_outline_rounded,
          AppColors.primary,
          AppColors.onPrimary,
        );
    }
  }
}
