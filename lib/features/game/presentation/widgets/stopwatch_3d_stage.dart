import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';

/// Wraps the play-area stopwatch with perspective, bezel depth, and idle motion.
class Stopwatch3DStage extends StatefulWidget {
  const Stopwatch3DStage({
    required this.diameter,
    required this.isRunning,
    required this.child,
    super.key,
  });

  final double diameter;
  final bool isRunning;
  final Widget child;

  @override
  State<Stopwatch3DStage> createState() => _Stopwatch3DStageState();
}

class _Stopwatch3DStageState extends State<Stopwatch3DStage>
    with SingleTickerProviderStateMixin {
  AnimationController? _motionController;

  bool get _enableMotion => !kIsWeb;

  @override
  void initState() {
    super.initState();
    if (_enableMotion) {
      _motionController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.isRunning ? 2200 : 4200),
      )..repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant Stopwatch3DStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controller = _motionController;
    if (controller == null) return;
    if (oldWidget.isRunning != widget.isRunning) {
      controller.duration = Duration(
        milliseconds: widget.isRunning ? 2200 : 4200,
      );
      if (!controller.isAnimating) {
        controller.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _motionController?.dispose();
    super.dispose();
  }

  Matrix4 _buildTransform(double t) {
    if (!_enableMotion) {
      return Matrix4.identity()
        ..setEntry(3, 2, 0.00115)
        ..rotateX(-0.11)
        ..rotateY(0.02);
    }

    final tiltX = lerpDouble(-0.14, -0.08, t)!;
    final tiltY = math.sin(t * math.pi * 2) * (widget.isRunning ? 0.06 : 0.035);
    final lift = widget.isRunning
        ? 6 + (math.sin(t * math.pi * 2) * 4)
        : 2 + (math.sin(t * math.pi * 2) * 2);

    return Matrix4.identity()
      ..setEntry(3, 2, 0.00115)
      ..rotateX(tiltX)
      ..rotateY(tiltY)
      ..translateByDouble(0.0, 0.0, lift, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final dialContent = _DialContent(
      diameter: widget.diameter,
      isRunning: widget.isRunning,
      child: widget.child,
    );

    if (!_enableMotion) {
      return Transform(
        alignment: Alignment.center,
        transform: _buildTransform(0),
        child: dialContent,
      );
    }

    final controller = _motionController!;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: _buildTransform(controller.value),
          child: child,
        );
      },
      child: dialContent,
    );
  }
}

class _DialContent extends StatelessWidget {
  const _DialContent({
    required this.diameter,
    required this.isRunning,
    required this.child,
  });

  final double diameter;
  final bool isRunning;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final d = diameter;
    final platformWidth = d * 1.08;
    final platformHeight = d * 0.14;
    final shadowBlur = kIsWeb ? 20.0 : (isRunning ? 36.0 : 24.0);

    return SizedBox(
      width: d,
      height: d + platformHeight + 28,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: d * 0.78 + platformHeight * 0.4,
            child: _GroundShadow(
              diameter: d * 0.92,
              isRunning: isRunning,
              blurRadius: shadowBlur,
            ),
          ),
          Positioned(
            top: d * 0.72,
            child: _PlatformDisk(
              width: platformWidth,
              height: platformHeight,
              isRunning: isRunning,
            ),
          ),
          Positioned(
            top: 0,
            child: RepaintBoundary(
              child: SizedBox(
                width: d,
                height: d,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    RepaintBoundary(
                      child: CustomPaint(
                        size: Size(d, d),
                        painter: _StopwatchBezel3DPainter(isRunning: isRunning),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(d * 0.045),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            center: Alignment(-0.35, -0.42),
                            radius: 1.05,
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0xFFF1F5F9),
                              Color(0x1A5F99D2),
                            ],
                            stops: [0.0, 0.55, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x3800377D),
                              blurRadius: kIsWeb ? 12 : 18,
                              offset: Offset(d * 0.04, d * 0.06),
                            ),
                            if (isRunning && !kIsWeb)
                              BoxShadow(
                                color: const Color(0x59FFD100),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: ClipOval(child: child),
                      ),
                    ),
                    if (!kIsWeb)
                      IgnorePointer(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            size: Size(d, d),
                            painter: _StopwatchGlassHighlightPainter(
                              isRunning: isRunning,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroundShadow extends StatelessWidget {
  const _GroundShadow({
    required this.diameter,
    required this.isRunning,
    required this.blurRadius,
  });

  final double diameter;
  final bool isRunning;
  final double blurRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter * 0.22,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(diameter),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(
                alpha: isRunning ? 0.32 : 0.2,
              ),
              blurRadius: blurRadius,
              spreadRadius: kIsWeb ? 1 : (isRunning ? 6 : 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformDisk extends StatelessWidget {
  const _PlatformDisk({
    required this.width,
    required this.height,
    required this.isRunning,
  });

  final double width;
  final double height;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.secondary.withValues(alpha: isRunning ? 0.55 : 0.42),
            AppColors.primary.withValues(alpha: 0.88),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4000377D),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
    );
  }
}

class _StopwatchBezel3DPainter extends CustomPainter {
  const _StopwatchBezel3DPainter({required this.isRunning});

  final bool isRunning;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final bezelWidth = outerRadius * 0.11;

    final outerBezel = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF8FAFD4),
          const Color(0xFF00377D),
          const Color(0xFF5F99D2),
          if (isRunning) AppColors.accent else const Color(0xFF8FAFD4),
          const Color(0xFF00377D),
        ],
        transform: GradientRotation(-math.pi / 4),
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));

    canvas.drawCircle(center, outerRadius - bezelWidth * 0.35, outerBezel);

    final innerRim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = bezelWidth * 0.45
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFFCBD5E1)],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));

    canvas.drawCircle(center, outerRadius - bezelWidth * 0.85, innerRim);

    final highlight = Paint()
      ..color = const Color(0x8CFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius - bezelWidth * 0.5),
      -2.4,
      1.1,
      false,
      highlight,
    );
  }

  @override
  bool shouldRepaint(covariant _StopwatchBezel3DPainter oldDelegate) {
    return oldDelegate.isRunning != isRunning;
  }
}

class _StopwatchGlassHighlightPainter extends CustomPainter {
  const _StopwatchGlassHighlightPainter({required this.isRunning});

  final bool isRunning;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final gloss = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.55, -0.62),
        radius: 0.75,
        colors: [
          Color.fromRGBO(255, 255, 255, isRunning ? 0.42 : 0.28),
          const Color(0x00FFFFFF),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius * 0.92, gloss);
  }

  @override
  bool shouldRepaint(covariant _StopwatchGlassHighlightPainter oldDelegate) {
    return oldDelegate.isRunning != isRunning;
  }
}

/// Subtle perspective tilt for stat chips and badges on the play screen.
class PlaySurface3DTilt extends StatelessWidget {
  const PlaySurface3DTilt({required this.child, this.depth = 0.045, super.key});

  final Widget child;
  final double depth;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return child;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0009)
        ..rotateX(-depth),
      child: child,
    );
  }
}
