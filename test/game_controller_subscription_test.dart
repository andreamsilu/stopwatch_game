import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch_game/core/billing/round_billing_copy.dart';
import 'package:stopwatch_game/features/game/data/game_service.dart';
import 'package:stopwatch_game/features/game/data/models/billing_transaction_response.dart';
import 'package:stopwatch_game/features/game/data/models/subscription_status_response.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_notifier.dart';

class _BillingSpyGameService extends GameService {
  _BillingSpyGameService({this.subscribed = false});

  final bool subscribed;
  int enqueueCalls = 0;
  int subscriptionChecks = 0;

  @override
  Future<SubscriptionStatusResponse> getSubscriptionStatus({
    required String msisdn,
  }) async {
    subscriptionChecks++;
    return SubscriptionStatusResponse(
      msisdn: msisdn,
      status: subscribed ? 'active' : 'inactive',
      subscribed: subscribed,
    );
  }

  @override
  Future<BillingTransactionResponse> enqueueBilling({required String msisdn}) {
    enqueueCalls++;
    throw StateError('Billing must not run for an inactive subscription.');
  }
}

void main() {
  test('inactive subscription is rejected before billing', () async {
    final gameService = _BillingSpyGameService();
    final controller = GameController(
      msisdn: '255676589824',
      isSubscribed: true,
      gameService: gameService,
    );
    addTearDown(controller.dispose);

    await controller.openRoundBoard();

    expect(gameService.subscriptionChecks, 1);
    expect(gameService.enqueueCalls, 0);
    expect(
      controller.state.roundErrorMessage,
      RoundBillingCopy.registrationRequired,
    );
    expect(controller.state.isSubmitting, isFalse);
  });

  test('active subscription proceeds to billing', () async {
    final gameService = _BillingSpyGameService(subscribed: true);
    final controller = GameController(
      msisdn: '255676589824',
      isSubscribed: true,
      gameService: gameService,
    );
    addTearDown(controller.dispose);

    await controller.openRoundBoard();

    expect(gameService.subscriptionChecks, 1);
    expect(gameService.enqueueCalls, 1);
  });
}
