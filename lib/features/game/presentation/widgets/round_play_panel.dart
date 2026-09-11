import 'dart:math' as math;
import 'package:stopwatch_game/core/theme/showcase_style.dart';
import 'package:stopwatch_game/core/widgets/app_logo.dart';

import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/billing/round_billing_copy.dart';
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

    final style = ShowcaseStyle(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : math.max(440.0, style.size.height - 220);
        return SizedBox(
          height: available,
          child: Column(
            children: [
              SizedBox(height: style.gap),
              AppLogo(size: (style.size.height * .06).clamp(36.0, 48.0)),
              SizedBox(height: style.gap),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: AppLanguage.pick('Je, unaweza? ', 'Can you? '),
                    ),
                    TextSpan(
                      text: AppLanguage.pick(
                        'Simama sahihi!',
                        'Stop precisely!',
                      ),
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: style.title,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  height: 1.15,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: style.gap),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(style.radius),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: .08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: .12),
                            blurRadius: 48,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 54,
                                ),
                                child: TargetTimeBadge(
                                  targetTimeLabel: hasTarget
                                      ? widget.targetTimeLabel
                                      : '00:00.000',
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: OutlinedButton(
                                  onPressed: widget.onToggleSound,
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(48, 44),
                                    padding: const EdgeInsets.all(6),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        widget.isSoundEnabled
                                            ? Icons.volume_up_outlined
                                            : Icons.volume_off_outlined,
                                        size: 20,
                                      ),
                                      Text(
                                        AppLanguage.pick('Sauti', 'Sound'),
                                        style: TextStyle(
                                          fontSize: (style.size.height * .014)
                                              .clamp(10.0, 12.0),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 1, color: Color(0xFFD0D7E2)),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, ringConstraints) {
                                final diameter = math.min(
                                  ringConstraints.maxWidth,
                                  ringConstraints.maxHeight,
                                );
                                return Center(
                                  child: _MinimalStopwatch(
                                    diameter: diameter,
                                    timeText: widget.currentTimeLabel,
                                    progress:
                                        (widget.elapsed.inMilliseconds %
                                            60000) /
                                        60000,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isPreparing)
                      Positioned.fill(
                        child: _PaymentLoadingOverlay(
                          onCancel: widget.onReset,
                          phase: widget.preparePhase,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: style.gap),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: style.buttonHeight,
                      child: OutlinedButton.icon(
                        onPressed: widget.isBusy ? null : _handleLeaveRound,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          textStyle: style.actionStyle,
                        ),
                        icon: const Icon(Icons.restart_alt),
                        label: Text(AppLanguage.pick('ANZISHA UPYA', 'RESET')),
                      ),
                    ),
                  ),
                  SizedBox(width: style.gap),
                  Expanded(
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
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLeaveRound() async {
    if (!widget.hasBillingForRound) {
      widget.onReset();
      return;
    }

    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(GameCopy.leaveConfirmTitle),
        content: Text(GameCopy.leaveConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(GameCopy.continuePlaying),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(GameCopy.leaveRoundAction),
          ),
        ],
      ),
    );
    if (leave == true && mounted) widget.onReset();
  }
}

class _PaymentLoadingOverlay extends StatelessWidget {
  const _PaymentLoadingOverlay({required this.onCancel, required this.phase});

  final VoidCallback onCancel;
  final RoundPreparePhase phase;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: RoundBillingCopy.messageForPhase(phase),
      child: Material(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: AppColors.primary,
                      backgroundColor: Color(0xFFDCEBFA),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    RoundBillingCopy.messageForPhase(phase),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (phase == RoundPreparePhase.awaitingPayment)
                    Text(
                      GameCopy.waitingForPaymentEllipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF475569),
                      ),
                    ),
                  const SizedBox(height: 20),

                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close_rounded, size: 20),
                    label: Text(GameCopy.cancelWaiting),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
        height: ShowcaseStyle(context).buttonHeight,
        child: ElevatedButton.icon(
          onPressed: isPreparing || isBusy ? null : onPay,
          style: ElevatedButton.styleFrom(
            textStyle: ShowcaseStyle(context).actionStyle,
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.primary,
          ),
          icon: const Icon(Icons.play_arrow_rounded),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isRetry ? GameCopy.tryAgainUpper : GameCopy.payForRoundUpper,
            ),
          ),
        ),
      );
    }

    final label = isRunning
        ? AppLanguage.pick('SIMAMA', 'STOP')
        : AppLanguage.pick('ANZA', 'START');
    return SizedBox(
      width: double.infinity,
      height: ShowcaseStyle(context).buttonHeight,
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
                  disabledForegroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: Icon(
                  isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  size: 20,
                ),
                label: Text(label, style: ShowcaseStyle(context).actionStyle),
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
    required this.progress,
  });
  final double diameter;
  final String timeText;
  final double progress;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: diameter,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size.square(diameter),
          painter: _StopwatchPainter(progress),
        ),
        SizedBox(
          width: diameter * .68,
          child: TimerDisplay(
            timeText: timeText,
            fontSize: diameter * .68 / 6.4,
          ),
        ),
      ],
    ),
  );
}

class _StopwatchPainter extends CustomPainter {
  const _StopwatchPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .44;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * .06;
    canvas.drawCircle(center, radius, paint..color = const Color(0xFFD0D7E2));
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        progress * math.pi * 2,
        false,
        paint
          ..color = const Color(0xFF1C57CF)
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StopwatchPainter oldDelegate) =>
      oldDelegate.progress != progress;
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
                Text(
                  GameCopy.yourTimeUpper,
                  style: const TextStyle(
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
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 28,
                  runSpacing: 12,
                  children: [
                    _ResultMetric(label: GameCopy.targetUpper, value: target),
                    _ResultMetric(
                      label: GameCopy.differenceUpper,
                      value: difference,
                    ),
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
                      textStyle: ShowcaseStyle(context).actionStyle,
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primary,
                    ),
                    icon: const Icon(Icons.replay_rounded),
                    label: Text(GameCopy.playAgain),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  GameCopy.paidRoundHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                TextButton(
                  onPressed: onViewHistory,
                  child: Text(GameCopy.viewHistory),
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
    return GameCopy.differenceSeconds(seconds, sign);
  }

  static String _feedback(int milliseconds) {
    return GameCopy.feedback(milliseconds);
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
