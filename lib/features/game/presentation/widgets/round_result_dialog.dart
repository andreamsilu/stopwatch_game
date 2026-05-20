import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';

class RoundResultDialog extends StatefulWidget {
  const RoundResultDialog({
    required this.result,
    required this.onCancel,
    required this.onTryAgain,
    super.key,
  });

  final RoundResultData result;
  final VoidCallback onCancel;
  final Future<void> Function() onTryAgain;

  @override
  State<RoundResultDialog> createState() => _RoundResultDialogState();
}

class _RoundResultDialogState extends State<RoundResultDialog>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confettiController;
  late final AnimationController _emojiAnimationController;
  late final Animation<double> _winEmojiScale;
  late final Animation<Offset> _loseEmojiShake;
  bool _isTryingAgain = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 2400),
    );
    _emojiAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _winEmojiScale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(
        parent: _emojiAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );
    _loseEmojiShake =
        TweenSequence<Offset>([
          TweenSequenceItem(
            tween: Tween(begin: const Offset(-0.05, 0), end: const Offset(0.05, 0)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: const Offset(0.05, 0), end: const Offset(-0.05, 0)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: const Offset(-0.05, 0), end: const Offset(0, 0)),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _emojiAnimationController,
            curve: Curves.easeInOut,
          ),
        );
    if (widget.result.isPrizeAwarded) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _emojiAnimationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _handleTryAgain() async {
    if (_isTryingAgain) return;
    setState(() => _isTryingAgain = true);
    try {
      if (mounted) Navigator.of(context).pop();
      await widget.onTryAgain();
    } finally {
      if (mounted) setState(() => _isTryingAgain = false);
    }
  }

  void _handleCancel() {
    if (_isTryingAgain) return;
    Navigator.of(context).pop();
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        GameCopy.roundSummary,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _isTryingAgain ? null : _handleCancel,
                        icon: const Icon(Icons.close_rounded),
                        tooltip: GameCopy.closeResultDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: Tween<double>(begin: 0.9, end: 1).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Text(
                      widget.result.outcomeLabel,
                      key: ValueKey<String>(widget.result.outcomeLabel),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: widget.result.outcomeLabel == 'WIN'
                            ? const Color(0xFF0F7B3D)
                            : const Color(0xFFB91C1C),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.result.outcomeLabel != 'WIN') ...[
                    Text(
                      widget.result.deltaLabel,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 10),
                  ],
                  SizedBox(
                    height: 56,
                    child: Center(
                      child: widget.result.isPrizeAwarded
                          ? ScaleTransition(
                              scale: _winEmojiScale,
                              child: const Text(
                                '🎉😄',
                                style: TextStyle(fontSize: 42),
                              ),
                            )
                          : SlideTransition(
                              position: _loseEmojiShake,
                              child: const Text(
                                '😞',
                                style: TextStyle(fontSize: 42),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Text(
                      widget.result.finalTimeLabel,
                      key: ValueKey<String>(widget.result.finalTimeLabel),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ResultInfoCard(
                    label: GameCopy.timeDifference,
                    value: '${widget.result.differenceMs} ms',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isTryingAgain ? null : _handleCancel,
                            child: const Text(GameCopy.cancel),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isTryingAgain ? null : _handleTryAgain,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.onAccent,
                            ),
                            child: _isTryingAgain
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: AppColors.onAccent,
                                    ),
                                  )
                                : const Text(GameCopy.tryAgain),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.result.isPrizeAwarded)
              Positioned(
                top: 0,
                child: IgnorePointer(
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    emissionFrequency: 0.045,
                    numberOfParticles: 38,
                    gravity: 0.22,
                    minBlastForce: 10,
                    maxBlastForce: 22,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultInfoCard extends StatelessWidget {
  const _ResultInfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background,
            AppColors.accent.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
