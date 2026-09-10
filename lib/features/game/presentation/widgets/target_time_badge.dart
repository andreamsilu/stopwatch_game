import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/core/theme/showcase_style.dart';

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
    final style = ShowcaseStyle(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: (style.size.height * .018).clamp(12.0, 18.0),
      ),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 224),
            child: Row(
              children: [
                const Expanded(
                  child: Divider(color: AppColors.accent, thickness: 3),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    GameCopy.targetUpper,
                    style: TextStyle(
                      fontSize: style.label,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: style.label * .14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Expanded(
                  child: Divider(color: AppColors.accent, thickness: 3),
                ),
              ],
            ),
          ),
          SizedBox(height: (style.size.height * .008).clamp(4.0, 8.0)),
          if (isLoading)
            const CircularProgressIndicator()
          else
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                targetTimeLabel,
                style: TextStyle(
                  fontSize: style.target,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: -style.target * .03,
                  color: AppColors.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
