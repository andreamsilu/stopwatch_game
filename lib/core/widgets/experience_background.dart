import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';

/// Responsive decorative canvas used behind the game experience.
class ExperienceBackground extends StatelessWidget {
  const ExperienceBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF0F4FA),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: CustomPaint(painter: _ChallengeBackdropPainter()),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _ChallengeBackdropPainter extends CustomPainter {
  const _ChallengeBackdropPainter();

  static const _leftBands = <({Color color, double top, double reach})>[
    (color: Color(0xFFBAC9DC), top: 0.42, reach: 0.215),
    (color: Color(0xFFF7EAAF), top: 0.435, reach: 0.198),
    (color: Color(0xFFFFDD57), top: 0.47, reach: 0.188),
    (color: Color(0xFFBEB66A), top: 0.49, reach: 0.178),
    (color: Color(0xFF6F7D62), top: 0.515, reach: 0.169),
    (color: Color(0xFF31566C), top: 0.545, reach: 0.161),
    (color: AppColors.primary, top: 0.585, reach: 0.151),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF0F4FA),
    );
    _paintRightContour(canvas, size);
    _paintLeftBands(canvas, size);
    _paintBottomRightWave(canvas, size);
  }

  void _paintLeftBands(Canvas canvas, Size size) {
    for (final band in _leftBands) {
      final path = Path()
        ..moveTo(-size.width * 0.055, size.height * band.top)
        ..cubicTo(
          size.width * 0.055,
          size.height * (band.top + 0.045),
          size.width * band.reach,
          size.height * (band.top + 0.17),
          size.width * band.reach,
          size.height * 0.76,
        )
        ..cubicTo(
          size.width * (band.reach + 0.012),
          size.height * 0.88,
          size.width * (band.reach - 0.035),
          size.height * 0.96,
          size.width * 0.065,
          size.height * 1.055,
        )
        ..lineTo(-size.width * 0.08, size.height * 1.055)
        ..close();
      canvas.drawPath(path, Paint()..color = band.color);
    }
  }

  void _paintRightContour(Canvas canvas, Size size) {
    final center = Offset(size.width * 1.012, size.height * 0.335);
    const colors = [
      Color(0xFFDCE5F1),
      Color(0xFFC4D2E5),
      Color(0xFFA9BDD8),
      Color(0xFF95ACCC),
    ];

    for (var index = 0; index < colors.length; index++) {
      final radiusX = size.width * (0.133 - (index * 0.013));
      final radiusY = size.height * (0.263 - (index * 0.027));
      if (radiusX <= 0 || radiusY <= 0) continue;
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radiusX * 2,
          height: radiusY * 2,
        ),
        Paint()..color = colors[index],
      );
    }
  }

  void _paintBottomRightWave(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.75, size.height * 1.03)
      ..cubicTo(
        size.width * 0.79,
        size.height * 0.91,
        size.width * 0.82,
        size.height * 0.72,
        size.width * 0.90,
        size.height * 0.735,
      )
      ..cubicTo(
        size.width * 0.975,
        size.height * 0.745,
        size.width * 1.005,
        size.height * 0.81,
        size.width * 1.055,
        size.height * 0.885,
      )
      ..lineTo(size.width * 1.055, size.height * 1.055)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant _ChallengeBackdropPainter oldDelegate) => false;
}
