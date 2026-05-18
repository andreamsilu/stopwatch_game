import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';

/// Tanzania (+255) dial prefix with flag from [flagsapi.com](https://flagsapi.com).
class TanzaniaPhonePrefix extends StatelessWidget {
  const TanzaniaPhonePrefix({
    this.style = 'flat',
    this.size = 24,
    super.key,
  });

  final String style;
  final int size;

  /// ISO 3166-1 alpha-2 for Tanzania (dial code +255).
  static const String countryCode = 'TZ';

  String get flagUrl => 'https://flagsapi.com/$countryCode/$style/$size.png';

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
            child: Image.network(
              flagUrl,
              width: flagWidth,
              height: flagHeight,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) => Icon(
                Icons.flag_outlined,
                size: flagHeight,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
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
