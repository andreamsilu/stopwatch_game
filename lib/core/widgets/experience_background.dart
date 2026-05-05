import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';

class ExperienceBackground extends StatefulWidget {
  const ExperienceBackground({required this.child, super.key});

  final Widget child;

  @override
  State<ExperienceBackground> createState() => _ExperienceBackgroundState();
}

class _ExperienceBackgroundState extends State<ExperienceBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + (t * 0.6), -1),
              end: Alignment(1, 1 - (t * 0.3)),
              colors: [
                AppColors.secondary.withValues(alpha: 0.16),
                AppColors.primary.withValues(alpha: 0.08),
                AppColors.background,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -90 + (t * 18),
                left: -70,
                child: _GlowCircle(
                  diameter: 250,
                  color: AppColors.secondary.withValues(alpha: 0.22),
                ),
              ),
              Positioned(
                top: 70 - (t * 16),
                right: -95,
                child: _GlowCircle(
                  diameter: 290,
                  color: AppColors.accent.withValues(alpha: 0.14),
                ),
              ),
              Positioned(
                bottom: -120 + (t * 14),
                left: 18 + (t * 12),
                child: _GlowCircle(
                  diameter: 270,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
              Positioned(
                top: 200 + (t * 12),
                right: 80,
                child: _GlowCircle(
                  diameter: 70,
                  color: AppColors.background.withValues(alpha: 0.34),
                ),
              ),
              Positioned(
                bottom: 120 - (t * 10),
                right: 220,
                child: _GlowCircle(
                  diameter: 42,
                  color: AppColors.secondary.withValues(alpha: 0.2),
                ),
              ),
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
