import 'package:stopwatch_game/core/config/env_config.dart';

/// User-facing copy for per-round billing (subscription consent is at registration).
class RoundBillingCopy {
  RoundBillingCopy._();

  static String get entryFeeLabel {
    final fee = EnvConfig.gameEntryFee;
    final formatted = fee == fee.roundToDouble()
        ? fee.toStringAsFixed(0)
        : fee.toStringAsFixed(2);
    return '$formatted TZS per round';
  }

  static const subscriptionConsent =
      'I agree to subscribe to Stopwatch Challenge. I understand that each round '
      'will be charged to my mobile number as part of my subscription.';

  static const chargedEveryRound =
      'Each new round charges your mobile number.';

  static const tryAgainCharges =
      'Try again charges your number for a new round.';

  static String get tryAgainButtonLabel => 'Try again ($entryFeeLabel)';

  static const preparingRoundCharge = 'Charging this round to your number…';

  static const waitingForPayment =
      'Complete the payment on your phone. We will confirm it automatically.';

  static const loadingTarget = 'Payment received. Loading your target time…';

  static const playReadyHint = 'Tap Start round when you are ready.';

  static const tryAgainSnack = tryAgainCharges;

  static const notSubscribed =
      'Complete registration with subscription to play rounds.';
}
