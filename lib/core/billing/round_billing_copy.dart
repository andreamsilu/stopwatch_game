import 'package:stopwatch_game/features/game/presentation/bloc/round_prepare_phase.dart';

/// Billing and round-payment copy.
class RoundBillingCopy {
  RoundBillingCopy._();

  static const chargedEveryRound = 'Charged to your mobile number.';

  static const preparingRoundCharge = 'Charging this round to your number…';

  static const waitingForPayment =
      'Confirm the payment on your phone. We will update you automatically.';

  static const loadingTarget = 'Payment confirmed. Setting up your round…';

  static const playReadyHint = 'When you are ready, tap Start round.';

  static const chargeRoundFirst =
      'Tap Start round again when payment is confirmed.';

  static const loginRequired = 'Log in to play a round.';

  static String messageForPhase(RoundPreparePhase phase) {
    switch (phase) {
      case RoundPreparePhase.charging:
        return preparingRoundCharge;
      case RoundPreparePhase.awaitingPayment:
        return waitingForPayment;
      case RoundPreparePhase.loadingTarget:
        return loadingTarget;
      case RoundPreparePhase.idle:
        return '';
    }
  }
}
