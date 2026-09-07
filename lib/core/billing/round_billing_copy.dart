import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/round_prepare_phase.dart';

/// Billing and round-payment copy.
class RoundBillingCopy {
  RoundBillingCopy._();

  static String get chargedEveryRound => AppLanguage.pick(
    'Gharama itatozwa kwenye namba yako ya simu.',
    'Charged to your mobile number.',
  );

  static String get preparingRoundCharge => AppLanguage.pick(
    'Inatoza raundi hii kwenye namba yako…',
    'Charging this round to your number…',
  );

  static String get checkingSubscription => AppLanguage.pick(
    'Inakagua hali ya usajili wako…',
    'Checking your subscription status…',
  );

  static String get registrationRequired => AppLanguage.pick(
    'Usajili wako haujawezeshwa. Tafadhali jisajili kwanza kabla ya kucheza.',
    'Your subscription is not active. Please register first before playing.',
  );

  static String get waitingForPayment => AppLanguage.pick(
    'Thibitisha malipo kwenye simu yako. Tutakujulisha kiotomatiki.',
    'Confirm the payment on your phone. We will update you automatically.',
  );

  static String get loadingTarget => AppLanguage.pick(
    'Malipo yamethibitishwa. Inaandaa raundi yako…',
    'Payment confirmed. Setting up your round…',
  );

  static String get playReadyHint => AppLanguage.pick(
    'Ukiwa tayari, gusa Anza raundi.',
    'When you are ready, tap Start round.',
  );

  static String get chargeRoundFirst => AppLanguage.pick(
    'Gusa Anza raundi tena malipo yakithibitishwa.',
    'Tap Start round again when payment is confirmed.',
  );

  static String get loginRequired =>
      AppLanguage.pick('Ingia ili kucheza raundi.', 'Log in to play a round.');

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
