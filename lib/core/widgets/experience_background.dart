import 'package:flutter/material.dart';

class ExperienceBackground extends StatelessWidget {
  const ExperienceBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF4FF), Color(0xFFF7FAFF), Color(0xFFFFFFFF)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -90,
            left: -70,
            child: _GlowCircle(
              diameter: 240,
              color: Color(0x335F99D2),
            ),
          ),
          const Positioned(
            top: 80,
            right: -95,
            child: _GlowCircle(
              diameter: 280,
              color: Color(0x22FFD100),
            ),
          ),
          const Positioned(
            bottom: -120,
            left: 20,
            child: _GlowCircle(
              diameter: 260,
              color: Color(0x1F00377D),
            ),
          ),
          child,
        ],
      ),
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
