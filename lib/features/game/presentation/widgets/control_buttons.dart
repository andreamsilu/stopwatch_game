import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({
    required this.isRunning,
    required this.isBusy,
    required this.onStart,
    required this.onStop,
    required this.onReset,
    required this.isCompact,
    super.key,
  });

  final bool isRunning;
  final bool isBusy;
  final Future<void> Function() onStart;
  final Future<void> Function() onStop;
  final VoidCallback onReset;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      _GameActionButton(
        label: 'Start',
        semanticLabel: 'Start stopwatch',
        onPressed: isRunning || isBusy ? null : onStart,
      ),
      _GameActionButton(
        label: 'Stop',
        semanticLabel: 'Stop stopwatch',
        onPressed: isRunning && !isBusy ? onStop : null,
      ),
      _GameActionButton(
        label: 'Reset',
        semanticLabel: 'Reset stopwatch',
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        onPressed: isBusy ? null : onReset,
      ),
    ];

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            buttons[i],
            if (i != buttons.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          Flexible(child: buttons[i]),
          if (i != buttons.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _GameActionButton extends StatelessWidget {
  const _GameActionButton({
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final String semanticLabel;
  final FutureOr<void> Function()? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: SizedBox(
        height: GameConstants.minTouchTargetSize + 8,
        child: ElevatedButton(
          onPressed: onPressed == null
              ? null
              : () async {
                  await onPressed?.call();
                },
          style: backgroundColor == null && foregroundColor == null
              ? null
              : ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  foregroundColor: foregroundColor,
                ),
          child: Text(label),
        ),
      ),
    );
  }
}
