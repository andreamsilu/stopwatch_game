import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
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
    final portalMessage = result.portalMessage?.trim();

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
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cards = [
                    _TimeCard(icon: Icons.flag_outlined, value: target),
                    _TimeCard(icon: Icons.timer_outlined, value: yourTime),
                  ];
                  if (constraints.maxWidth < 320 ||
                      MediaQuery.textScalerOf(context).scale(36) > 48) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        cards[0],
                        const SizedBox(height: 12),
                        cards[1],
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 12),
                      Expanded(child: cards[1]),
                    ],
                  );
                },
              ),
              if (portalMessage != null && portalMessage.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    portalMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontSize: 22,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await onPlayAgain();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.onAccent,
                  ),
                  child: const Icon(Icons.replay_rounded),
                ),
              ),
              const SizedBox(height: 8),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onViewHistory();
                },
                icon: const Icon(Icons.history_rounded),
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
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDCE5F0)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 30),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.primary,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
