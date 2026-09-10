import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({
    required this.timeText,
    required this.fontSize,
    super.key,
  });

  final String timeText;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLanguage.pick(
        'Muda uliopita kwenye kipima muda',
        'Elapsed stopwatch time',
      ),
      value: timeText,
      liveRegion: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          timeText,
          textAlign: TextAlign.center,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: const Color(0xFF00377D),
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: -fontSize * .06,
            height: 1,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
