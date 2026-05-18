import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/billing/round_billing_copy.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/round_prepare_phase.dart';

/// Inline status while a subscribed player opens a paid round (no extra consent).
class RoundPrepareStatusBanner extends StatelessWidget {
  const RoundPrepareStatusBanner({required this.phase, super.key});

  final RoundPreparePhase phase;

  @override
  Widget build(BuildContext context) {
    if (phase == RoundPreparePhase.idle) return const SizedBox.shrink();

    final (message, icon) = switch (phase) {
      RoundPreparePhase.charging => (
        RoundBillingCopy.preparingRoundCharge,
        Icons.payments_outlined,
      ),
      RoundPreparePhase.loadingTarget => (
        RoundBillingCopy.loadingTarget,
        Icons.timer_outlined,
      ),
      RoundPreparePhase.idle => ('', Icons.info_outline),
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: phase == RoundPreparePhase.charging
                ? const CircularProgressIndicator(strokeWidth: 2.2)
                : Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
