import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';

class RoundResultModal extends StatelessWidget {
  const RoundResultModal({
    required this.result,
    required this.onClose,
    required this.onPlayAgain,
    required this.onViewHistory,
    super.key,
  });

  final RoundResultData result;
  final VoidCallback onClose;
  final Future<void> Function() onPlayAgain;
  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) {
    final yourTime = _formatTime(result.finalTimeLabel);
    final target = _formatTime(result.targetTimeLabel);
    final difference = _formatDifference(result.differenceMs);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onClose();
                  },
                  tooltip: GameCopy.closeResultDialog,
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
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
                  fontSize: 58,
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
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await onPlayAgain();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.onAccent,
                  ),
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(GameCopy.playAgain),
                ),
              ),
              const SizedBox(height: 8),
              Text(GameCopy.paidRoundHint),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onViewHistory();
                },
                child: Text(GameCopy.viewHistory),
              ),
            ],
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
