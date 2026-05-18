class GameConstants {
  const GameConstants._();

  static const String gameTitle = 'Stopwatch Challenge';
  /// Internal stopwatch accuracy (stop uses real elapsed time).
  static const Duration timerTickInterval = Duration(milliseconds: 10);

  /// How often the UI rebuilds while running (lower = less memory on web).
  static const Duration timerUiTickInterval = Duration(milliseconds: 50);

  static const double minTouchTargetSize = 48;
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double stopwatchCircleMobileDiameter = 200;
  static const double stopwatchCircleDesktopDiameter = 248;
}
