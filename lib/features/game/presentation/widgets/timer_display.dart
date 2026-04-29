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
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 140),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.985,
                end: 1,
              ).animate(animation),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
          );
        },
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            timeText,
            key: ValueKey<String>(timeText),
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
