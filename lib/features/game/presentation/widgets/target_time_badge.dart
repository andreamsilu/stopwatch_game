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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF2B8), Color(0xFFFFD100)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FFD100),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            GameCopy.targetTimeBadge,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.onAccent.withValues(alpha: 0.9),
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
              targetTimeLabel,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.onAccent,
              ),
            ),
        ],
      ),
    );
  }
}
