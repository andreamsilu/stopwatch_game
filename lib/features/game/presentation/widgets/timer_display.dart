import 'package:flutter/material.dart';

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
      label: 'Elapsed stopwatch time',
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
            color: const Color(0xFF002B68),
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            height: 1.1,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
