import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';

enum AppSnackBarType { success, error, info, warning }

/// Centered, toast-style feedback overlay.
class AppSnackBar {
  const AppSnackBar._();

  static OverlayEntry? _entry;
  static Timer? _timer;

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

  /// Hides the current centered toast, if any.
  static void dismiss() => _dismiss();

  static void _show(
    BuildContext context, {
    required String message,
    required AppSnackBarType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _dismiss();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) => _CenterToast(
        message: message,
        type: type,
        onDismiss: () {
          if (_entry == entry) {
            _dismiss();
          }
        },
      ),
    );

    _entry = entry;
    overlay.insert(entry);

    _timer = Timer(duration, _dismiss);
  }

  static void _dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _CenterToast extends StatefulWidget {
  const _CenterToast({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  final String message;
  final AppSnackBarType type;
  final VoidCallback onDismiss;

  @override
  State<_CenterToast> createState() => _CenterToastState();
}

class _CenterToastState extends State<_CenterToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(widget.type);
    final width = MediaQuery.sizeOf(context).width;
    final maxWidth = width > 480 ? 380.0 : width - 40;

    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black.withValues(alpha: 0.08)),
            ),
          ),
          FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: GestureDetector(
                onTap: _close,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: style.background,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: style.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3300377D),
                          blurRadius: 28,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: style.iconBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              style.icon,
                              color: style.iconColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                widget.message,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: style.textColor,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _close,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            icon: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: style.textColor.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToastStyle {
  const _ToastStyle({
    required this.icon,
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.iconColor,
    required this.textColor,
  });

  final IconData icon;
  final Color background;
  final Color border;
  final Color iconBackground;
  final Color iconColor;
  final Color textColor;
}

_ToastStyle _styleFor(AppSnackBarType type) {
  switch (type) {
    case AppSnackBarType.success:
      return const _ToastStyle(
        icon: Icons.check_circle_rounded,
        background: Color(0xFFF1FAF3),
        border: Color(0xFFA5D6A7),
        iconBackground: Color(0xFF2E7D32),
        iconColor: Colors.white,
        textColor: Color(0xFF1B5E20),
      );
    case AppSnackBarType.error:
      return const _ToastStyle(
        icon: Icons.error_outline_rounded,
        background: Color(0xFFFFF5F5),
        border: Color(0xFFEF9A9A),
        iconBackground: Color(0xFFB3261E),
        iconColor: Colors.white,
        textColor: Color(0xFF8C1D18),
      );
    case AppSnackBarType.warning:
      return const _ToastStyle(
        icon: Icons.warning_amber_rounded,
        background: Color(0xFFFFFBEB),
        border: Color(0xFFFCD34D),
        iconBackground: Color(0xFFF59E0B),
        iconColor: Colors.white,
        textColor: Color(0xFF92400E),
      );
    case AppSnackBarType.info:
      return _ToastStyle(
        icon: Icons.info_outline_rounded,
        background: const Color(0xFFF0F7FF),
        border: AppColors.primary.withValues(alpha: 0.25),
        iconBackground: AppColors.primary,
        iconColor: AppColors.onPrimary,
        textColor: AppColors.primary,
      );
  }
}
