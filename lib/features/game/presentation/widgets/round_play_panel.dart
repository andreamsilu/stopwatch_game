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
                          const SizedBox(height: 2),
                          Text(
                            targetTimeLabel,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Text(
                          'Target time',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                letterSpacing: 0.2,
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
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final preferredDiameter = maxWidth < 600
                        ? GameConstants.stopwatchCircleMobileDiameter
                        : GameConstants.stopwatchCircleDesktopDiameter;
                    final maxAllowedDiameter = maxWidth > 220
                        ? maxWidth - 24
                        : GameConstants.stopwatchCircleMobileDiameter;
                    final circleDiameter = preferredDiameter
                        .clamp(180.0, maxAllowedDiameter)
                        .toDouble();
                    final circleRadius = circleDiameter / 2;
                    final timerFontSize = (circleDiameter * 0.22)
                        .clamp(38.0, 52.0)
                        .toDouble();

                    return Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          width: circleDiameter,
                          height: circleDiameter,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            border: Border.all(
                              color: isRunning
                                  ? AppColors.accent.withValues(alpha: 0.72)
                                  : AppColors.secondary.withValues(alpha: 0.32),
                              width: isRunning ? 6 : 5,
                            ),
                            borderRadius: BorderRadius.circular(circleRadius),
                            boxShadow: isRunning
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
                            child: TimerDisplay(
                              timeText: currentTimeLabel,
                              fontSize: timerFontSize,
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
                                  _RoundStatCard(
                                    label: 'Start Time',
                                    value: '00:00.000',
                                  ),
                                  const SizedBox(height: 10),
                                  _RoundStatCard(
                                    label: 'Your Target',
                                    value: targetTimeLabel,
                                  ),
                                ],
                              );
                            }
                            return Row(
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
                  elevation: isRunning ? 3 : 1,
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
                label: Text(isRunning ? 'Stop round' : 'Start round'),
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6DFEA)),
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
