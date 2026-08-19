import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/core/services/pointer_event_trust.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/round_prepare_phase.dart';
import 'package:stopwatch_game/features/game/presentation/flame/stopwatch_flame_game.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/target_time_badge.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/timer_display.dart';

class RoundPlayPanel extends StatefulWidget {
  const RoundPlayPanel({
    required this.targetTimeLabel,
    required this.currentTimeLabel,
    required this.elapsed,
    required this.targetTime,
    required this.isRunning,
    required this.isBusy,
    required this.isSubmitting,
    required this.isLoadingTarget,
    required this.preparePhase,
    this.statusMessage,
    this.errorMessage,
    required this.isSoundEnabled,
    required this.startButtonVisualOffset,
    required this.startButtonHitboxOffset,
    required this.onReset,
    required this.onToggleSound,
    required this.onStartControlPointerDown,
    required this.onStartControlPointerMove,
    required this.onStartControlPointerUp,
    required this.hasBillingForRound,
    required this.onPlayRound,
    required this.onStartOrStopRound,
    required this.totalWins,
    super.key,
  });

  final String targetTimeLabel;
  final String currentTimeLabel;
  final Duration elapsed;
  final Duration targetTime;
  final bool isRunning;
  final bool isBusy;
  final bool isSubmitting;
  final bool isLoadingTarget;
  final RoundPreparePhase preparePhase;
  final String? statusMessage;
  final String? errorMessage;
  final bool isSoundEnabled;
  final Offset startButtonVisualOffset;
  final Offset startButtonHitboxOffset;
  final VoidCallback onReset;
  final VoidCallback onToggleSound;
  final void Function(Offset position, {bool? isTrusted})
  onStartControlPointerDown;
  final ValueChanged<Offset> onStartControlPointerMove;
  final void Function(Offset position, {bool? isTrusted})
  onStartControlPointerUp;
  final bool hasBillingForRound;
  final Future<void> Function() onPlayRound;
  final Future<void> Function() onStartOrStopRound;
  final int totalWins;

  @override
  State<RoundPlayPanel> createState() => _RoundPlayPanelState();
}

class _RoundPlayPanelState extends State<RoundPlayPanel> {
  late final StopwatchFlameGame _stopwatchGame;
  double? _lastDiameter;
  bool? _lastRunningState;

  @override
  void initState() {
    super.initState();
    _stopwatchGame = StopwatchFlameGame(
      isRunning: widget.isRunning,
      diameter: GameConstants.stopwatchCircleDesktopDiameter,
    );
  }

  @override
  void didUpdateWidget(covariant RoundPlayPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRunning != widget.isRunning) {
      _updateGame(
        _lastDiameter ?? GameConstants.stopwatchCircleDesktopDiameter,
      );
    }
  }

  void _updateGame(double diameter) {
    if (_lastDiameter == diameter && _lastRunningState == widget.isRunning) {
      return;
    }
    _lastDiameter = diameter;
    _lastRunningState = widget.isRunning;
    _stopwatchGame.updateState(isRunning: widget.isRunning, diameter: diameter);
  }

  @override
  Widget build(BuildContext context) {
    final isPreparing = widget.preparePhase != RoundPreparePhase.idle;
    final hasTarget =
        widget.hasBillingForRound &&
        !isPreparing &&
        widget.targetTime > Duration.zero;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final widthBasedDiameter = isMobile
                ? (constraints.maxWidth - 20).clamp(240.0, 360.0).toDouble()
                : constraints.maxWidth.clamp(380.0, 500.0).toDouble();
            final reservedHeight = widget.isRunning ? 150.0 : 245.0;
            final heightBasedDiameter = constraints.maxHeight.isFinite
                ? (constraints.maxHeight - reservedHeight)
                      .clamp(190.0, 500.0)
                      .toDouble()
                : 500.0;
            final diameter = widthBasedDiameter < heightBasedDiameter
                ? widthBasedDiameter
                : heightBasedDiameter;
            _updateGame(diameter);

            return Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: widget.onToggleSound,
                    tooltip: widget.isSoundEnabled ? 'Sound On' : 'Sound Off',
                    icon: Icon(
                      widget.isSoundEnabled
                          ? Icons.volume_up_outlined
                          : Icons.volume_off_outlined,
                    ),
                    color: AppColors.primary,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _StateHeader(
                    key: ValueKey<String>(_stateKey(isPreparing, hasTarget)),
                    isRunning: widget.isRunning,
                    isPreparing: isPreparing,
                    phase: widget.preparePhase,
                    hasTarget: hasTarget,
                    targetTimeLabel: widget.targetTimeLabel,
                    errorMessage: widget.errorMessage,
                  ),
                ),
                SizedBox(height: widget.isRunning ? 6 : 12),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: !widget.isRunning && !hasTarget ? 0.52 : 1,
                  child: SizedBox(
                    width: diameter,
                    height: diameter,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        RepaintBoundary(
                          child: GameWidget(
                            game: _stopwatchGame,
                            backgroundBuilder: (_) => const SizedBox.shrink(),
                          ),
                        ),
                        SizedBox(
                          width: diameter * 0.66,
                          child: TimerDisplay(
                            timeText: widget.currentTimeLabel,
                            fontSize: (diameter * 0.16).clamp(42.0, 68.0),
                          ),
                        ),
                        IgnorePointer(
                          child: CustomPaint(
                            size: Size.square(diameter),
                            painter: _FocusRingPainter(
                              isRunning: widget.isRunning,
                              progress: widget.targetTime.inMilliseconds == 0
                                  ? 0
                                  : (widget.elapsed.inMilliseconds /
                                            widget.targetTime.inMilliseconds)
                                        .clamp(0.0, 1.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 8 : 14),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.isRunning ? 420 : 520,
                  ),
                  child: _PrimaryRoundAction(
                    isRunning: widget.isRunning,
                    isPreparing: isPreparing,
                    hasTarget: hasTarget,
                    isBusy: widget.isBusy,
                    isRetry: widget.errorMessage?.isNotEmpty == true,
                    visualOffset: widget.startButtonVisualOffset,
                    hitboxOffset: widget.startButtonHitboxOffset,
                    onPay: widget.onPlayRound,
                    onStartOrStop: widget.onStartOrStopRound,
                    onPointerDown: widget.onStartControlPointerDown,
                    onPointerMove: widget.onStartControlPointerMove,
                    onPointerUp: widget.onStartControlPointerUp,
                  ),
                ),
                if (!widget.isRunning) ...[
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: widget.isBusy ? null : _handleLeaveRound,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text(GameCopy.leaveRound),
                  ),
                  if (widget.totalWins > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Perfect Stops: ${widget.totalWins}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _stateKey(bool isPreparing, bool hasTarget) {
    if (widget.isRunning) return 'running';
    if (isPreparing) return widget.preparePhase.name;
    if (hasTarget) return 'target';
    return 'unpaid';
  }

  Future<void> _handleLeaveRound() async {
    if (!widget.hasBillingForRound) {
      widget.onReset();
      return;
    }

    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave this round?'),
        content: const Text('Your current round will be lost if you leave.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CONTINUE PLAYING'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('LEAVE ROUND'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) widget.onReset();
  }
}

class _StateHeader extends StatelessWidget {
  const _StateHeader({
    super.key,
    required this.isRunning,
    required this.isPreparing,
    required this.phase,
    required this.hasTarget,
    required this.targetTimeLabel,
    this.errorMessage,
  });

  final bool isRunning;
  final bool isPreparing;
  final RoundPreparePhase phase;
  final bool hasTarget;
  final String targetTimeLabel;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (isRunning) return const SizedBox.shrink();

    if (isPreparing) {
      final awaiting = phase == RoundPreparePhase.awaitingPayment;
      return Column(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            awaiting ? 'Confirm payment on your phone' : 'Preparing your round',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            awaiting
                ? "We're waiting for your payment confirmation."
                : 'Please wait while we prepare your challenge.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    if (hasTarget) {
      return Column(
        children: [
          TargetTimeBadge(targetTimeLabel: targetTimeLabel),
          const SizedBox(height: 10),
          Text(
            'Stop the timer as close to '
            '${_secondsDisplay(targetTimeLabel)} seconds as you can.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Ready when you are.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    final error = errorMessage?.trim();
    return Column(
      children: [
        Text(
          error?.isNotEmpty == true
              ? 'Payment was not completed'
              : 'Ready for the challenge?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: error?.isNotEmpty == true
                ? Theme.of(context).colorScheme.error
                : AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          error?.isNotEmpty == true
              ? error!
              : 'Pay for a round to reveal your target and start playing.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  static String _secondsDisplay(String value) {
    final seconds = double.tryParse(value.split(':').last);
    return seconds?.toStringAsFixed(2) ?? value;
  }
}

class _PrimaryRoundAction extends StatelessWidget {
  const _PrimaryRoundAction({
    required this.isRunning,
    required this.isPreparing,
    required this.hasTarget,
    required this.isBusy,
    required this.isRetry,
    required this.visualOffset,
    required this.hitboxOffset,
    required this.onPay,
    required this.onStartOrStop,
    required this.onPointerDown,
    required this.onPointerMove,
    required this.onPointerUp,
  });

  final bool isRunning;
  final bool isPreparing;
  final bool hasTarget;
  final bool isBusy;
  final bool isRetry;
  final Offset visualOffset;
  final Offset hitboxOffset;
  final Future<void> Function() onPay;
  final Future<void> Function() onStartOrStop;
  final void Function(Offset position, {bool? isTrusted}) onPointerDown;
  final ValueChanged<Offset> onPointerMove;
  final void Function(Offset position, {bool? isTrusted}) onPointerUp;

  @override
  Widget build(BuildContext context) {
    if (!hasTarget && !isRunning) {
      return SizedBox(
        width: double.infinity,
        height: 62,
        child: ElevatedButton.icon(
          onPressed: isPreparing || isBusy ? null : onPay,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.onAccent,
          ),
          icon: isPreparing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                )
              : const Icon(Icons.play_arrow_rounded),
          label: Text(
            isPreparing
                ? 'PROCESSING PAYMENT'
                : (isRetry ? 'TRY AGAIN' : 'PAY FOR ROUND'),
          ),
        ),
      );
    }

    final label = isRunning ? 'STOP' : 'START ROUND';
    return SizedBox(
      width: double.infinity,
      height: isRunning ? 78 : 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: visualOffset,
            child: SizedBox.expand(
              child: ElevatedButton.icon(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: AppColors.accent,
                  disabledForegroundColor: AppColors.onAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(
                  isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  size: isRunning ? 32 : 24,
                ),
                label: Text(
                  label,
                  style: TextStyle(
                    fontSize: isRunning ? 25 : 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: isRunning ? 1.3 : 0.3,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: isBusy,
              child: Transform.translate(
                offset: hitboxOffset,
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
                    onTap: onStartOrStop,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusRingPainter extends CustomPainter {
  const _FocusRingPainter({required this.isRunning, required this.progress});

  final bool isRunning;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide / 2) - 7;
    final track = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    final active = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    if (isRunning) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.5708,
        6.28318530718 * progress,
        false,
        active,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FocusRingPainter oldDelegate) =>
      oldDelegate.isRunning != isRunning || oldDelegate.progress != progress;
}
