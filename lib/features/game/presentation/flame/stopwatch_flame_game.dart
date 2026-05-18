import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
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
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final ring = _ring;
    if (ring != null && children.contains(ring)) {
      ring
        ..position = Vector2(size.x / 2, size.y / 2)
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
    final dialRadius = radius - 6;

    // Depth stack: rear shadow ring → face → inner bevel → accent rim.
    final depthShadow = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center.translate(0, 5), dialRadius - 2, depthShadow);

    final facePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.35),
        radius: 1.0,
        colors: [
          const Color(0xFFFFFFFF),
          const Color(0xFFE8EEF5),
          const Color(0xFFD9E4F0),
        ],
        stops: const [0.0, 0.62, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: dialRadius));

    final innerBevel = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.85),
          AppColors.primary.withValues(alpha: 0.22),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: dialRadius));

    final glowPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.08 + (pulse * 0.17))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8 + (pulse * 7);
    final borderPaint = Paint()
      ..color = isRunning
          ? AppColors.accent.withValues(alpha: 0.70 + (pulse * 0.20))
          : AppColors.secondary.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isRunning ? 5.5 : 4.5;

    if (isRunning) {
      canvas.drawCircle(center, dialRadius + (pulse * 5), glowPaint);
    }
    canvas.drawCircle(center, dialRadius, facePaint);
    canvas.drawCircle(center, dialRadius - 4, innerBevel);
    canvas.drawCircle(center, dialRadius, borderPaint);

    if (!kIsWeb) {
      final tickPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.18)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 12; i++) {
        final angle = (i / 12) * 2 * pi - pi / 2;
        final inner = dialRadius - 14;
        final outer = dialRadius - 6;
        final start = center + Offset(cos(angle) * inner, sin(angle) * inner);
        final end = center + Offset(cos(angle) * outer, sin(angle) * outer);
        canvas.drawLine(start, end, tickPaint);
      }
    }
  }
}
