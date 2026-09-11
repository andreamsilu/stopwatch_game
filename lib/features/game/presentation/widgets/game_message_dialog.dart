import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';

/// Displays the portal's message without rewriting its content.
class GameMessageDialog extends StatelessWidget {
  const GameMessageDialog({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    void close() => Navigator.of(context).pop();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(56, 24, 56, 26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF477DBF),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: close,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(82, 44),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          elevation: 2,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        child: Text(AppLanguage.pick('Funga', 'Close')),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: IconButton(
                  onPressed: close,
                  tooltip: GameCopy.close,
                  color: const Color(0xFF477DBF),
                  icon: const Icon(Icons.close, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
