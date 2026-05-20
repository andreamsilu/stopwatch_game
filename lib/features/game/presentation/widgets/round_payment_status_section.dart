import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/billing/round_billing_copy.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/round_prepare_phase.dart';

/// Payment progress on the play screen while billing is charged and confirmed.
class RoundPaymentStatusSection extends StatelessWidget {
  const RoundPaymentStatusSection({
    required this.phase,
    this.statusMessage,
    super.key,
  });

  final RoundPreparePhase phase;
  final String? statusMessage;

  @override
  Widget build(BuildContext context) {
    if (phase == RoundPreparePhase.idle) {
      return const SizedBox.shrink();
    }

    final message = _resolveStatusMessage(phase, statusMessage);
    final showMessage = message.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.14),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: showMessage
                      ? Text(
                          message,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

String _resolveStatusMessage(RoundPreparePhase phase, String? statusMessage) {
  final trimmed = statusMessage?.trim();
  if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  return RoundBillingCopy.messageForPhase(phase);
}
