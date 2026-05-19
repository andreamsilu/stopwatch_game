import 'package:flutter/material.dart';
import 'package:flame/game.dart' hide Matrix4;
import 'package:stopwatch_game/core/billing/round_billing_copy.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/core/services/game_feedback_service.dart';
import 'package:stopwatch_game/core/services/pointer_event_trust.dart';
import 'package:stopwatch_game/features/game/presentation/flame/stopwatch_flame_game.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/round_prepare_phase.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/round_prepare_status_banner.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/stopwatch_3d_stage.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/timer_display.dart';

class RoundPlayPanel extends StatefulWidget {
  const RoundPlayPanel({
    required this.targetTimeLabel,
    required this.currentTimeLabel,
    required this.elapsed,
    required this.targetTime,
    required this.isRunning,
    required this.isBusy,
    required this.isLoadingTarget,
    required this.preparePhase,
    this.roundErrorMessage,
    required this.isSoundEnabled,
    required this.startButtonVisualOffset,
    required this.startButtonHitboxOffset,
    required this.onReset,
    required this.onTryAgain,
    required this.canTryAgain,
    required this.onToggleSound,
    required this.onStartControlPointerDown,
    required this.onStartControlPointerMove,
    required this.onStartControlPointerUp,
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
  final bool isLoadingTarget;
  final RoundPreparePhase preparePhase;
  final String? roundErrorMessage;
  final bool isSoundEnabled;
  final Offset startButtonVisualOffset;
  final Offset startButtonHitboxOffset;
  final VoidCallback onReset;
  final VoidCallback onTryAgain;
  final bool canTryAgain;
  final VoidCallback onToggleSound;
  final void Function(Offset position, {bool? isTrusted})
  onStartControlPointerDown;
  final ValueChanged<Offset> onStartControlPointerMove;
  final void Function(Offset position, {bool? isTrusted}) onStartControlPointerUp;
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
  double? _lastGameDiameter;
  bool? _lastGameIsRunning;

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
    final isTightMobile = screenWidth < 430;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.roundErrorMessage != null) ...[
          _RoundErrorBanner(message: widget.roundErrorMessage!),
          const SizedBox(height: 10),
        ],
        RoundPrepareStatusBanner(phase: widget.preparePhase),
        if (widget.canTryAgain) ...[
          SizedBox(
            width: double.infinity,
            height: GameConstants.minTouchTargetSize + 4,
            child: ElevatedButton.icon(
              onPressed: widget.isBusy ? null : widget.onTryAgain,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              icon: const Icon(Icons.replay_rounded),
              label: Text(RoundBillingCopy.tryAgainButtonLabel),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallMobile ? 10 : 16,
                  vertical: isSmallMobile ? 6 : 8,
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
                                onPressed: widget.onToggleSound,
                                icon: Icon(
                                  widget.isSoundEnabled
                                      ? Icons.volume_up_outlined
                                      : Icons.volume_off_outlined,
                                ),
                                tooltip: widget.isSoundEnabled
                                    ? 'Disable sounds'
                                    : 'Enable sounds',
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints.tightFor(
                                  width: 36,
                                  height: 36,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          PlaySurface3DTilt(
                            child: _TargetTimeBadge(
                              targetTimeLabel: widget.targetTimeLabel,
                              isLoading: widget.isLoadingTarget,
                            ),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        PlaySurface3DTilt(
                          child: _TargetTimeBadge(
                            targetTimeLabel: widget.targetTimeLabel,
                            isLoading: widget.isLoadingTarget,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: widget.onToggleSound,
                          icon: Icon(
                            widget.isSoundEnabled
                                ? Icons.volume_up_outlined
                                : Icons.volume_off_outlined,
                          ),
                          tooltip: widget.isSoundEnabled
                              ? 'Disable sounds'
                              : 'Enable sounds',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints.tightFor(
                            width: 36,
                            height: 36,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallMobile ? 10 : 18,
                  vertical: isSmallMobile ? 6 : 10,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final compactPanel = maxWidth < 430;
                    final responsivePreferred = compactPanel
                        ? (maxWidth * 0.66)
                        : (maxWidth < 600
                              ? (maxWidth * 0.76)
                              : GameConstants.stopwatchCircleDesktopDiameter);
                    final maxAllowedDiameter = compactPanel
                        ? (maxWidth - 36).clamp(140.0, 260.0)
                        : (maxWidth - 20).clamp(140.0, 360.0);
                    final circleDiameter = responsivePreferred
                        .clamp(140.0, maxAllowedDiameter)
                        .toDouble();
                    final progressValue = widget.targetTime.inMilliseconds <= 0
                        ? 0.0
                        : (widget.elapsed.inMilliseconds /
                                  widget.targetTime.inMilliseconds)
                              .clamp(0.0, 1.0);
                    // Keep elapsed time clear of rotating progress cycles.
                    final timerFontSize = (circleDiameter * 0.19)
                        .clamp(compactPanel ? 22.0 : 24.0, compactPanel ? 38.0 : 44.0)
                        .toDouble();
                    final timerMaxWidth = (circleDiameter * 0.56)
                        .clamp(88.0, 180.0)
                        .toDouble();
                    if (_lastGameDiameter != circleDiameter ||
                        _lastGameIsRunning != widget.isRunning) {
                      _lastGameDiameter = circleDiameter;
                      _lastGameIsRunning = widget.isRunning;
                      _stopwatchGame.updateState(
                        isRunning: widget.isRunning,
                        diameter: circleDiameter,
                      );
                    }

                    return Column(
                      children: [
                        Center(
                          child: Stopwatch3DStage(
                            diameter: circleDiameter,
                            isRunning: widget.isRunning,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                RepaintBoundary(
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
                                  child: RepaintBoundary(
                                    child: SizedBox(
                                      width: circleDiameter,
                                      height: circleDiameter,
                                      child: AnimatedBuilder(
                                        animation: _ringRotationController ??
                                            const AlwaysStoppedAnimation<double>(
                                              0,
                                            ),
                                        builder: (context, _) {
                                          return CustomPaint(
                                            painter: _RoundProgressRingPainter(
                                              progress: progressValue,
                                              rotation:
                                                  _ringRotationController
                                                      ?.value ??
                                                  0,
                                              isRunning: widget.isRunning,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: compactPanel ? 10 : 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final compactStats = constraints.maxWidth < 420;
                            if (compactStats) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: PlaySurface3DTilt(
                                          child: _RoundStatCard(
                                            label: 'Target time',
                                            value: widget.targetTimeLabel,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: PlaySurface3DTilt(
                                          child: _RoundStatCard(
                                            label: 'Prize coins',
                                            value: '${widget.totalPrizeCoins}',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  PlaySurface3DTilt(
                                    child: _RoundStatCard(
                                      label: 'Perfect stops',
                                      value: '${widget.totalWins}',
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(
                                  child: PlaySurface3DTilt(
                                    child: _RoundStatCard(
                                      label: 'Target time',
                                      value: widget.targetTimeLabel,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: PlaySurface3DTilt(
                                    child: _RoundStatCard(
                                      label: 'Prize coins',
                                      value: '${widget.totalPrizeCoins}',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: PlaySurface3DTilt(
                                    child: _RoundStatCard(
                                      label: 'Perfect stops',
                                      value: '${widget.totalWins}',
                                    ),
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
        SizedBox(height: isTightMobile ? 8 : 12),
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
                icon: const Icon(Icons.close_rounded),
                label: const Text('Leave round'),
              ),
            );
            final startButton = SizedBox(
              height: GameConstants.minTouchTargetSize + 6,
              child: _OffsetAwareStartControl(
                isRunning: widget.isRunning,
                isDisabled: widget.isBusy,
                visualOffset: widget.startButtonVisualOffset,
                hitboxOffset: widget.startButtonHitboxOffset,
                onPointerDown: widget.onStartControlPointerDown,
                onPointerMove: widget.onStartControlPointerMove,
                onPointerUp: widget.onStartControlPointerUp,
                onTap: _handleStartOrStopTap,
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

  Future<void> _handleStartOrStopTap() async {
    if (widget.isBusy) return;
    if (widget.isRunning) {
      await GameFeedbackService.onRoundStop();
    } else {
      await GameFeedbackService.onRoundStart();
    }
    await widget.onStartOrStopRound();
  }
}

class _OffsetAwareStartControl extends StatelessWidget {
  const _OffsetAwareStartControl({
    required this.isRunning,
    required this.isDisabled,
    required this.visualOffset,
    required this.hitboxOffset,
    required this.onPointerDown,
    required this.onPointerMove,
    required this.onPointerUp,
    required this.onTap,
  });

  final bool isRunning;
  final bool isDisabled;
  final Offset visualOffset;
  final Offset hitboxOffset;
  final void Function(Offset position, {bool? isTrusted}) onPointerDown;
  final ValueChanged<Offset> onPointerMove;
  final void Function(Offset position, {bool? isTrusted}) onPointerUp;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final disabledStyle = ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent.withValues(alpha: 0.45),
      foregroundColor: AppColors.onAccent.withValues(alpha: 0.55),
      elevation: 0,
      shadowColor: Colors.transparent,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0008)
            ..rotateX(isRunning ? -0.03 : -0.05)
            ..translate(
              visualOffset.dx,
              visualOffset.dy,
              isRunning ? 4.0 : 0.0,
            ),
          child: IgnorePointer(
            child: SizedBox.expand(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 170),
                curve: Curves.easeOutCubic,
                scale: isRunning ? 1.02 : 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: isRunning ? 0.35 : 0.22,
                        ),
                        blurRadius: isRunning ? 16 : 10,
                        offset: Offset(0, isRunning ? 8 : 5),
                      ),
                      BoxShadow(
                        color: AppColors.accent.withValues(
                          alpha: isRunning ? 0.4 : 0.2,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                  onPressed: isBusy ? null : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.onAccent,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  icon: isBusy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                        ),
                  label: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Text(
                      isRunning ? 'Stop round' : 'Start round',
                      key: ValueKey<bool>(isRunning),
                    ),
                  ),
                ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(
              hitboxOffset.dx,
              hitboxOffset.dy,
              0,
            ),
            child: Listener(
              onPointerDown: (event) => onPointerDown(
                event.position,
                isTrusted: PointerEventTrust.currentIsTrusted(),
              ),
              onPointerMove: (event) => onPointerMove(event.position),
              onPointerUp: (event) => onPointerUp(
                event.position,
                isTrusted: PointerEventTrust.currentIsTrusted(),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: isBusy ? null : () => onTap(),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundErrorBanner extends StatelessWidget {
  const _RoundErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFFB91C1C),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TargetTimeBadge extends StatelessWidget {
  const _TargetTimeBadge({
    required this.targetTimeLabel,
    required this.isLoading,
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
            'TARGET TIME',
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
            AppColors.secondary.withValues(alpha: 0.14),
            AppColors.primary.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A00377D),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
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
