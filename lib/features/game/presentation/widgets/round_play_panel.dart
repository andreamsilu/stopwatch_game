import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/timer_display.dart';

class RoundPlayPanel extends StatelessWidget {
  const RoundPlayPanel({
    required this.targetTimeLabel,
    required this.currentTimeLabel,
    required this.isRunning,
    required this.isBusy,
    required this.onReset,
    required this.onStartOrStopRound,
    super.key,
  });

  final String targetTimeLabel;
  final String currentTimeLabel;
  final bool isRunning;
  final bool isBusy;
  final VoidCallback onReset;
  final Future<void> Function() onStartOrStopRound;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Text(
                      'TARGET TIME',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      targetTimeLabel,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.volume_up_outlined),
                      tooltip: 'Sound settings',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 196,
                      height: 196,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.36),
                          width: 6,
                        ),
                        borderRadius: BorderRadius.circular(98),
                      ),
                      child: Center(
                        child: TimerDisplay(
                          timeText: currentTimeLabel,
                          fontSize: 44,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _RoundStatCard(
                            label: 'Start Time',
                            value: '00:00.000',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _RoundStatCard(
                            label: 'Your Target',
                            value: targetTimeLabel,
                          ),
                        ),
                      ],
                    ),
                  ],
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
                onPressed: isBusy ? null : onReset,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('RESET'),
              ),
            );
            final startButton = SizedBox(
              height: GameConstants.minTouchTargetSize + 6,
              child: ElevatedButton.icon(
                onPressed: isBusy
                    ? null
                    : () async {
                        await onStartOrStopRound();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.onAccent,
                ),
                icon: isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isRunning
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                      ),
                label: Text(isRunning ? 'STOP ROUND' : 'START ROUND'),
              ),
            );

            if (compact) {
              return Column(
                children: [
                  resetButton,
                  const SizedBox(height: 10),
                  startButton,
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

class _RoundStatCard extends StatelessWidget {
  const _RoundStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
