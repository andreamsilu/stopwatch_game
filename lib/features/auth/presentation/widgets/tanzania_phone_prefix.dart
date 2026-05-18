import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';

/// Tanzania (+255) dial prefix with an inline flag (no network, no asset bundle).
class TanzaniaPhonePrefix extends StatelessWidget {
  const TanzaniaPhonePrefix({
    this.size = 24,
    super.key,
  });

  final int size;

  @override
  Widget build(BuildContext context) {
    final flagWidth = size.toDouble();
    final flagHeight = (size * 0.72).clamp(14.0, 20.0);

    return SizedBox(
      width: 100,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: CustomPaint(
              size: Size(flagWidth, flagHeight),
              painter: const _TanzaniaFlagPainter(),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '+255',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simplified Tanzania flag (green / yellow-black-yellow / blue).
class _TanzaniaFlagPainter extends CustomPainter {
  const _TanzaniaFlagPainter();

  static const _green = Color(0xFF1EB53A);
  static const _blue = Color(0xFF00A3DD);
  static const _black = Color(0xFF000000);
  static const _gold = Color(0xFFFCD116);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = _green);

    final bluePath = Path()
      ..moveTo(w, 0)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(bluePath, Paint()..color = _blue);

    final band = Path()
      ..moveTo(0, h * 0.58)
      ..lineTo(w, h * 0.12)
      ..lineTo(w, h * 0.28)
      ..lineTo(0, h * 0.74)
      ..close();
    canvas.drawPath(band, Paint()..color = _black);

    final goldUpper = Path()
      ..moveTo(0, h * 0.54)
      ..lineTo(w, h * 0.08)
      ..lineTo(w, h * 0.12)
      ..lineTo(0, h * 0.58)
      ..close();
    canvas.drawPath(goldUpper, Paint()..color = _gold);

    final goldLower = Path()
      ..moveTo(0, h * 0.74)
      ..lineTo(w, h * 0.28)
      ..lineTo(w, h * 0.32)
      ..lineTo(0, h * 0.78)
      ..close();
    canvas.drawPath(goldLower, Paint()..color = _gold);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
