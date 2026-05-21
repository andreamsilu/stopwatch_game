import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/billing/round_billing_copy.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/round_prepare_phase.dart';

/// Subtle inline status while billing runs (not a full-width banner).
class RoundBillingHint extends StatelessWidget {
  const RoundBillingHint({
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

    final message = _resolveMessage();
    if (message.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _resolveMessage() {
    final custom = statusMessage?.trim();
    if (custom != null && custom.isNotEmpty) return custom;
    return RoundBillingCopy.messageForPhase(phase);
  }
}
