import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/core/services/game_feedback_service.dart';
import 'package:stopwatch_game/features/game/presentation/flame/stopwatch_flame_game.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/timer_display.dart';

class RoundPlayPanel extends StatefulWidget {
  const RoundPlayPanel({
    required this.targetTimeLabel,
    required this.currentTimeLabel,
    required this.elapsed,
    required this.targetTime,
    required this.isRunning,
    required this.isBusy,
    required this.onReset,
    required this.onStartOrStopRound,
    required this.totalWins,
    required this.totalPrizeCoins,
    super.key,
  });

  final String targetTimeLabel;
  final String currentTimeLabel;
  final Duration elapsed;
  final Duration targetTime;
  final bool isRunning;
  final bool isBusy;
  final VoidCallback onReset;
  final Future<void> Function() onStartOrStopRound;
  final int totalWins;
  final int totalPrizeCoins;

  @override
  State<RoundPlayPanel> createState() => _RoundPlayPanelState();
}

class _RoundPlayPanelState extends State<RoundPlayPanel>
    with SingleTickerProviderStateMixin {
  late final StopwatchFlameGame _stopwatchGame;
  AnimationController? _ringRotationController;

  @override
  void initState() {
    super.initState();
    _stopwatchGame = StopwatchFlameGame(
      isRunning: widget.isRunning,
      diameter: GameConstants.stopwatchCircleDesktopDiameter,
    );
    _ringRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    if (widget.isRunning) {
      _ringRotationController?.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant RoundPlayPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRunning != widget.isRunning) {
      _stopwatchGame.updateState(
        isRunning: widget.isRunning,
        diameter: _stopwatchGame.diameter,
      );
      if (widget.isRunning) {
        _ringRotationController?.repeat();
      } else {
        _ringRotationController?.stop();
      }
    }
  }

  @override
  void dispose() {
    _ringRotationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 380;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallMobile ? 12 : 18,
                  vertical: isSmallMobile ? 8 : 10,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompactHeader = constraints.maxWidth < 380;
                    if (isCompactHeader) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Target time',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      letterSpacing: 0.2,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.volume_up_outlined),
                                tooltip: 'Sound settings',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _TargetTimeBadge(
                            targetTimeLabel: widget.targetTimeLabel,
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        _TargetTimeBadge(
                          targetTimeLabel: widget.targetTimeLabel,
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.volume_up_outlined),
                          tooltip: 'Sound settings',
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallMobile ? 12 : 20,
                  vertical: isSmallMobile ? 8 : 14,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final responsivePreferred = maxWidth < 600
                        ? (maxWidth * 0.82)
                        : GameConstants.stopwatchCircleDesktopDiameter;
                    final maxAllowedDiameter = (maxWidth - 20).clamp(140.0, 360.0);
                    final circleDiameter = responsivePreferred
                        .clamp(140.0, maxAllowedDiameter)
                        .toDouble();
                    final circleRadius = circleDiameter / 2;
                    final progressValue = widget.targetTime.inMilliseconds <= 0
                        ? 0.0
                        : (widget.elapsed.inMilliseconds /
                                  widget.targetTime.inMilliseconds)
                              .clamp(0.0, 1.0);
                    // Keep elapsed time clear of rotating progress cycles.
                    final timerFontSize = (circleDiameter * 0.19)
                        .clamp(24.0, 44.0)
                        .toDouble();
                    final timerMaxWidth = (circleDiameter * 0.56)
                        .clamp(88.0, 180.0)
                        .toDouble();
                    _stopwatchGame.updateState(
                      isRunning: widget.isRunning,
                      diameter: circleDiameter,
                    );

                    return Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          width: circleDiameter,
                          height: circleDiameter,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.background,
                                AppColors.secondary.withValues(alpha: 0.1),
                              ],
                            ),
                            border: Border.all(
                              color: widget.isRunning
                                  ? AppColors.accent.withValues(alpha: 0.72)
                                  : AppColors.secondary.withValues(alpha: 0.32),
                              width: widget.isRunning ? 6 : 5,
                            ),
                            borderRadius: BorderRadius.circular(circleRadius),
                            boxShadow: widget.isRunning
                                ? const [
                                    BoxShadow(
                                      color: Color(0x2EFFD100),
                                      blurRadius: 24,
                                      offset: Offset(0, 8),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    circleRadius,
                                  ),
                                  child: SizedBox(
                                    width: circleDiameter,
                                    height: circleDiameter,
                                    child: GameWidget(
                                      game: _stopwatchGame,
                                      backgroundBuilder: (context) =>
                                          const SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: timerMaxWidth,
                                  child: TimerDisplay(
                                    timeText: widget.currentTimeLabel,
                                    fontSize: timerFontSize,
                                  ),
                                ),
                                IgnorePointer(
                                  child: SizedBox(
                                    width: circleDiameter,
                                    height: circleDiameter,
                                    child: AnimatedBuilder(
                                      animation: _ringRotationController ??
                                          const AlwaysStoppedAnimation<double>(0),
                                      builder: (context, _) {
                                        return TweenAnimationBuilder<double>(
                                          tween: Tween<double>(
                                            begin: 0,
                                            end: progressValue,
                                          ),
                                          duration: const Duration(milliseconds: 180),
                                          curve: Curves.easeOutCubic,
                                          builder: (context, animatedProgress, _) {
                                            return CustomPaint(
                                              painter: _RoundProgressRingPainter(
                                                progress: animatedProgress,
                                                rotation:
                                                    _ringRotationController?.value ??
                                                    0,
                                                isRunning: widget.isRunning,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final compactStats = constraints.maxWidth < 420;
                            if (compactStats) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _RoundStatCard(
                                          label: 'Start time',
                                          value: '00:00.000',
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _RoundStatCard(
                                          label: 'Target time',
                                          value: widget.targetTimeLabel,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _RoundStatCard(
                                          label: 'Prize coins',
                                          value: '${widget.totalPrizeCoins}',
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _RoundStatCard(
                                          label: 'Perfect stops',
                                          value: '${widget.totalWins}',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(
                                  child: _RoundStatCard(
                                    label: 'Start time',
                                    value: '00:00.000',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _RoundStatCard(
                                    label: 'Target time',
                                    value: widget.targetTimeLabel,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _RoundStatCard(
                                    label: 'Prize coins',
                                    value: '${widget.totalPrizeCoins}',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _RoundStatCard(
                                    label: 'Perfect stops',
                                    value: '${widget.totalWins}',
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 560;
            final resetButton = SizedBox(
              height: GameConstants.minTouchTargetSize + 6,
              child: OutlinedButton.icon(
                onPressed: widget.isBusy
                    ? null
                    : () async {
                        await GameFeedbackService.onRoundReset();
                        widget.onReset();
                      },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reset round'),
              ),
            );
            final startButton = SizedBox(
              height: GameConstants.minTouchTargetSize + 6,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 170),
                curve: Curves.easeOutCubic,
                scale: widget.isRunning ? 1.02 : 1,
                child: ElevatedButton.icon(
                  onPressed: widget.isBusy
                      ? null
                      : () async {
                          if (widget.isRunning) {
                            await GameFeedbackService.onRoundStop();
                          } else {
                            await GameFeedbackService.onRoundStart();
                          }
                          await widget.onStartOrStopRound();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.onAccent,
                    elevation: widget.isRunning ? 3 : 1,
                  ),
                  icon: widget.isBusy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          widget.isRunning
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                        ),
                  label: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: Text(
                      widget.isRunning ? 'Stop round' : 'Start round',
                      key: ValueKey<bool>(widget.isRunning),
                    ),
                  ),
                ),
              ),
            );

            if (compact) {
              return Row(
                children: [
                  Expanded(child: resetButton),
                  const SizedBox(width: 10),
                  Expanded(child: startButton),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: resetButton),
                const SizedBox(width: 10),
                Expanded(child: startButton),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TargetTimeBadge extends StatelessWidget {
  const _TargetTimeBadge({required this.targetTimeLabel});

  final String targetTimeLabel;

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
            'TARGET TIME',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.onAccent.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 2),
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

class _RoundStatCard extends StatelessWidget {
  const _RoundStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background,
            AppColors.secondary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: Text(
              value,
              key: ValueKey<String>(value),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundProgressRingPainter extends CustomPainter {
  const _RoundProgressRingPainter({
    required this.progress,
    required this.rotation,
    required this.isRunning,
  });

  final double progress;
  final double rotation;
  final bool isRunning;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = (size.width * 0.013).clamp(2.2, 4.6);
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (size.width / 2) - (strokeWidth * 1.5);
    final midRadius = outerRadius - (strokeWidth * 2.0);
    final innerRadius = midRadius - (strokeWidth * 2.0);
    final outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final midRect = Rect.fromCircle(center: center, radius: midRadius);
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    final outerTrackPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final midTrackPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final innerTrackPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final outerProgressPaint = Paint()
      ..color = isRunning
          ? AppColors.accent.withValues(alpha: 0.95)
          : AppColors.accent.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final midRotatingPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: isRunning ? 0.95 : 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final innerRotatingPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: isRunning ? 0.95 : 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, outerRadius, outerTrackPaint);
    canvas.drawCircle(center, midRadius, midTrackPaint);
    canvas.drawCircle(center, innerRadius, innerTrackPaint);

    canvas.drawArc(
      outerRect,
      -1.5708,
      6.28318530718 * progress,
      false,
      outerProgressPaint,
    );
    canvas.drawArc(
      midRect,
      (rotation * 6.28318530718) - 1.5708,
      2.2,
      false,
      midRotatingPaint,
    );
    canvas.drawArc(
      innerRect,
      (-rotation * 6.28318530718) + 0.6,
      1.7,
      false,
      innerRotatingPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RoundProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.rotation != rotation ||
        oldDelegate.isRunning != isRunning;
  }
}
