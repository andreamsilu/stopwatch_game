import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';

class TargetTimeBadge extends StatelessWidget {
  const TargetTimeBadge({
    required this.targetTimeLabel,
    this.isLoading = false,
    super.key,
  });

  final String targetTimeLabel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final secondsText = _secondsDisplay(targetTimeLabel);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F2FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC9DEEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            GameCopy.targetTimeBadge,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          if (isLoading)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.onAccent,
              ),
            )
          else
            Text(
              secondsText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 28,
                color: AppColors.primary,
              ),
            ),
          const SizedBox(height: 1),
          const Text(
            'SECONDS',
            style: TextStyle(
              color: Color(0xFF52657A),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  static String _secondsDisplay(String value) {
    final seconds = double.tryParse(value.split(':').last);
    return seconds?.toStringAsFixed(2) ?? value;
  }
}
