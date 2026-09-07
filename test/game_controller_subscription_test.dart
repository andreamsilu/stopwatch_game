import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch_game/core/billing/round_billing_copy.dart';
import 'package:stopwatch_game/features/game/data/game_service.dart';
import 'package:stopwatch_game/features/game/data/models/billing_transaction_response.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_notifier.dart';

class _BillingSpyGameService extends GameService {
  int enqueueCalls = 0;

  @override
  Future<BillingTransactionResponse> enqueueBilling({required String msisdn}) {
    enqueueCalls++;
    throw StateError('Billing must not run for an inactive subscription.');
  }
}

void main() {
  test('inactive subscription is rejected before billing', () async {
    final gameService = _BillingSpyGameService();
    var subscriptionChecks = 0;
    final controller = GameController(
      msisdn: '255676589824',
      isSubscribed: true,
      subscriptionStatusChecker: () async {
        subscriptionChecks++;
        return false;
      },
      gameService: gameService,
    );
    addTearDown(controller.dispose);

    await controller.openRoundBoard();

    expect(subscriptionChecks, 1);
    expect(gameService.enqueueCalls, 0);
    expect(
      controller.state.roundErrorMessage,
      RoundBillingCopy.registrationRequired,
    );
    expect(controller.state.isSubmitting, isFalse);
  });
}
