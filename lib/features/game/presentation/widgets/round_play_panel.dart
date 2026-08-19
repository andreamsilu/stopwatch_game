import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/core/services/pointer_event_trust.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/round_prepare_phase.dart';
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
    required this.result,
    required this.onPlayAgain,
    required this.onViewHistory,
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
  final RoundResultData? result;
  final Future<void> Function() onPlayAgain;
  final VoidCallback onViewHistory;

  @override
  State<RoundPlayPanel> createState() => _RoundPlayPanelState();
}

class _RoundPlayPanelState extends State<RoundPlayPanel> {
  @override
  Widget build(BuildContext context) {
    final isPreparing = widget.preparePhase != RoundPreparePhase.idle;
    final hasTarget = !isPreparing && widget.targetTime > Duration.zero;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final widthBasedDiameter = isMobile
                ? (constraints.maxWidth - 20).clamp(230.0, 340.0).toDouble()
                : constraints.maxWidth.clamp(320.0, 380.0).toDouble();
            final reservedHeight = widget.isRunning ? 215.0 : 265.0;
            final heightBasedDiameter = constraints.maxHeight.isFinite
                ? (constraints.maxHeight - reservedHeight)
                      .clamp(190.0, 380.0)
                      .toDouble()
                : 380.0;
            final diameter = widthBasedDiameter < heightBasedDiameter
                ? widthBasedDiameter
                : heightBasedDiameter;
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
                  ),
                ),
                SizedBox(height: widget.isRunning ? 6 : 12),
                _MinimalStopwatch(
                  diameter: diameter,
                  timeText: widget.currentTimeLabel,
                  isRunning: widget.isRunning,
                  isInactive: !widget.isRunning && !hasTarget,
                  progress: widget.targetTime.inMilliseconds == 0
                      ? 0
                      : (widget.elapsed.inMilliseconds /
                                widget.targetTime.inMilliseconds)
                            .clamp(0.0, 1.0),
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
  });

  final bool isRunning;
  final bool isPreparing;
  final RoundPreparePhase phase;
  final bool hasTarget;
  final String targetTimeLabel;

  @override
  Widget build(BuildContext context) {
    if (isRunning) {
      return TargetTimeBadge(targetTimeLabel: targetTimeLabel);
    }

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

    return Column(
      children: [
        Text(
          'Ready for the challenge?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pay for a round to activate the target and start playing.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        const TargetTimeBadge(targetTimeLabel: '00:10.000'),
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

class _MinimalStopwatch extends StatelessWidget {
  const _MinimalStopwatch({
    required this.diameter,
    required this.timeText,
    required this.isRunning,
    required this.isInactive,
    required this.progress,
  });

  final double diameter;
  final String timeText;
  final bool isRunning;
  final bool isInactive;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(diameter),
            painter: _StopwatchPainter(
              isRunning: isRunning,
              progress: progress,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: diameter * 0.07),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isInactive ? 0.76 : 1,
              child: SizedBox(
                width: diameter * 0.68,
                child: TimerDisplay(
                  timeText: timeText,
                  fontSize: (diameter * 0.15).clamp(38.0, 58.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StopwatchPainter extends CustomPainter {
  const _StopwatchPainter({required this.isRunning, required this.progress});

  final bool isRunning;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, (size.height / 2) + 9);
    final radius = (size.shortestSide / 2) - 22;

    canvas.drawCircle(
      center + const Offset(0, 5),
      radius,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.11)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFF7FBFF));

    final outline = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, outline);

    final crownWidth = radius * 0.34;
    final crownRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - radius - 8),
        width: crownWidth,
        height: 18,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(crownRect, Paint()..color = AppColors.primary);

    final accentRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.72, center.dy - radius * 0.66),
        width: 24,
        height: 11,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(accentRect, Paint()..color = AppColors.accent);

    final tickPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.58)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < 12; index++) {
      final angle = (index * 0.5235987756) - 1.5708;
      final outer = Offset(
        center.dx + (radius - 13) * math.cos(angle),
        center.dy + (radius - 13) * math.sin(angle),
      );
      final inset = index % 3 == 0 ? 27.0 : 21.0;
      final inner = Offset(
        center.dx + (radius - inset) * math.cos(angle),
        center.dy + (radius - inset) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    final active = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
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
  bool shouldRepaint(covariant _StopwatchPainter oldDelegate) =>
      oldDelegate.isRunning != isRunning || oldDelegate.progress != progress;
}

class InlineRoundResult extends StatelessWidget {
  const InlineRoundResult({
    required this.result,
    required this.onPlayAgain,
    required this.onViewHistory,
    super.key,
  });

  final RoundResultData result;
  final Future<void> Function() onPlayAgain;
  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) {
    final yourTime = _formatTime(result.finalTimeLabel);
    final target = _formatTime(result.targetTimeLabel);
    final difference = _formatDifference(result.differenceMs);

    return Card(
      margin: EdgeInsets.zero,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'YOUR TIME',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  yourTime,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.primary,
                    fontSize: 62,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 28,
                  runSpacing: 12,
                  children: [
                    _ResultMetric(label: 'TARGET', value: target),
                    _ResultMetric(label: 'DIFFERENCE', value: difference),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  _feedback(result.differenceMs),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: onPlayAgain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.onAccent,
                    ),
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text(GameCopy.playAgain),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Play Again starts a new paid round.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                TextButton(
                  onPressed: onViewHistory,
                  child: const Text(GameCopy.viewHistory),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatTime(String value) {
    final seconds = double.tryParse(value.split(':').last);
    return seconds?.toStringAsFixed(3) ?? value;
  }

  static String _formatDifference(int milliseconds) {
    final seconds = milliseconds / 1000;
    final sign = seconds >= 0 ? '+' : '';
    return '$sign${seconds.toStringAsFixed(3)} sec';
  }

  static String _feedback(int milliseconds) {
    final distance = milliseconds.abs();
    if (distance <= 5) return 'PERFECT! 🎯';
    if (distance <= 20) return 'Incredible! Only 0.01s away.';
    if (distance <= 75) return 'So close!';
    return 'Nice try!';
  }
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
