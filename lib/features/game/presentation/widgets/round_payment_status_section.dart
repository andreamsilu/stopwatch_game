import 'package:flutter/material.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/round_prepare_phase.dart';

/// Reserves layout space while billing runs; copy is shown via snackbars only.
class RoundPaymentStatusSection extends StatelessWidget {
  const RoundPaymentStatusSection({
    required this.phase,
    super.key,
  });

  final RoundPreparePhase phase;

  /// Matches the former banner + divider height so the play card does not jump.
  static const double reservedHeight = 75;

  @override
  Widget build(BuildContext context) {
    if (phase == RoundPreparePhase.idle) {
      return const SizedBox.shrink();
    }

    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SizedBox(
        width: double.infinity,
        height: reservedHeight,
      ),
    );
  }
}
