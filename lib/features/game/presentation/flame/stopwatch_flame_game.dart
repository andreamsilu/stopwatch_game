import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';

class StopwatchFlameGame extends FlameGame {
  StopwatchFlameGame({
    required this.isRunning,
    required this.diameter,
  });

  bool isRunning;
  double diameter;

  _StopwatchRingComponent? _ring;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _ring = _StopwatchRingComponent(
      isRunning: isRunning,
      diameter: diameter,
    );
    add(_ring!);
  }

  void updateState({
    required bool isRunning,
    required double diameter,
  }) {
    this.isRunning = isRunning;
    this.diameter = diameter;
    final ring = _ring;
    if (ring == null) return;

    ring
      ..isRunning = isRunning
      ..diameter = diameter
      ..position = Vector2(size.x / 2, size.y / 2)
      ..size = Vector2.all(diameter);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    final ring = _ring;
    if (ring != null && children.contains(ring)) {
      ring
        ..position = Vector2(canvasSize.x / 2, canvasSize.y / 2)
        ..size = Vector2.all(diameter);
    }
  }
}

class _StopwatchRingComponent extends PositionComponent {
  _StopwatchRingComponent({
    required this.isRunning,
    required this.diameter,
  }) : super(
         anchor: Anchor.center,
         size: Vector2.all(diameter),
       );

  bool isRunning;
  double diameter;
  double _pulsePhase = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (!isRunning) {
      _pulsePhase = 0;
      return;
    }

    // Drive a soft pulse animation while the round is active.
    _pulsePhase = (_pulsePhase + dt * 2.7) % (2 * pi);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final radius = diameter / 2;
    final center = Offset(size.x / 2, size.y / 2);
    final pulse = isRunning ? (sin(_pulsePhase) + 1) / 2 : 0.0;
    final fillPaint = Paint()..color = const Color(0xFFF8FAFC);
    final glowPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.08 + (pulse * 0.17))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8 + (pulse * 7);
    final borderPaint = Paint()
      ..color = isRunning
          ? AppColors.accent.withValues(alpha: 0.70 + (pulse * 0.20))
          : AppColors.secondary.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isRunning ? 6 : 5;

    if (isRunning) {
      canvas.drawCircle(center, (radius - 3) + (pulse * 5), glowPaint);
    }
    canvas.drawCircle(center, radius - 3, fillPaint);
    canvas.drawCircle(center, radius - 3, borderPaint);
  }
}
