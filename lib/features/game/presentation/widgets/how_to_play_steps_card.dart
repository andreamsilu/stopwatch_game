import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';

/// Horizontal “How to play” steps card for the home screen.
class HowToPlayStepsCard extends StatelessWidget {
  const HowToPlayStepsCard({super.key});

  static const _cardRadius = 24.0;
  static const _stepFill = Color(0xFFF1F5F9);
  static const _highlight = Color(0xFFB8860B);

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      height: 1.4,
      color: AppColors.onBackground.withValues(alpha: 0.82),
      fontWeight: FontWeight.w500,
    );
    final highlightStyle = bodyStyle?.copyWith(
      color: _highlight,
      fontWeight: FontWeight.w800,
    );

    return Container(
      decoration: _homeCardDecoration(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.flag_rounded,
                  size: 18,
                  color: _highlight,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                GameCopy.howToPlayTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 640;
              final step1 = _HowToPlayStepTile(
                number: 1,
                spans: [
                  TextSpan(text: GameCopy.howToPlayStep1Prefix, style: bodyStyle),
                  TextSpan(
                    text: GameCopy.howToPlayStep1Highlight,
                    style: highlightStyle,
                  ),
                  TextSpan(text: GameCopy.howToPlayStep1Suffix, style: bodyStyle),
                ],
              );
              final step2 = _HowToPlayStepTile(
                number: 2,
                spans: [
                  TextSpan(text: GameCopy.howToPlayStep2Prefix, style: bodyStyle),
                  TextSpan(
                    text: GameCopy.howToPlayStep2Highlight,
                    style: highlightStyle,
                  ),
                  TextSpan(text: GameCopy.howToPlayStep2Suffix, style: bodyStyle),
                ],
              );
              final step3 = _HowToPlayStepTile(
                number: 3,
                spans: [
                  TextSpan(text: GameCopy.howToPlayStep3Prefix, style: bodyStyle),
                  TextSpan(
                    text: GameCopy.howToPlayStep3Highlight,
                    style: highlightStyle,
                  ),
                ],
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: step1),
                    const SizedBox(width: 10),
                    Expanded(child: step2),
                    const SizedBox(width: 10),
                    Expanded(child: step3),
                  ],
                );
              }
              return Column(
                children: [
                  step1,
                  const SizedBox(height: 10),
                  step2,
                  const SizedBox(height: 10),
                  step3,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static BoxDecoration _homeCardDecoration() {
    return BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(_cardRadius),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1200377D),
          blurRadius: 22,
          offset: Offset(0, 8),
        ),
      ],
    );
  }
}

class _HowToPlayStepTile extends StatelessWidget {
  const _HowToPlayStepTile({
    required this.number,
    required this.spans,
  });

  final int number;
  final List<InlineSpan> spans;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: HowToPlayStepsCard._stepFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              '$number',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(TextSpan(children: spans)),
        ],
      ),
    );
  }
}
