import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch_game/core/billing/round_billing_copy.dart';
import 'package:stopwatch_game/features/game/data/game_service.dart';
import 'package:stopwatch_game/features/game/data/models/billing_transaction_response.dart';
import 'package:stopwatch_game/features/game/data/models/subscription_status_response.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_notifier.dart';

class _BillingSpyGameService extends GameService {
  _BillingSpyGameService({
    this.subscribed = false,
    this.status,
    this.activatesAfterRegistration = false,
    this.activation,
  });

  final bool subscribed;
  final String? status;
  final bool activatesAfterRegistration;
  final Completer<SubscriptionStatusResponse?>? activation;
  final calls = <String>[];
  int enqueueCalls = 0;
  int subscriptionChecks = 0;
  int registrationCalls = 0;
  int activationPolls = 0;

  @override
  Future<SubscriptionStatusResponse> getSubscriptionStatus({
    required String msisdn,
  }) async {
    subscriptionChecks++;
    calls.add('status');
    return SubscriptionStatusResponse(
      msisdn: msisdn,
      status: status ?? (subscribed ? 'active' : 'inactive'),
      subscribed: subscribed,
    );
  }

  @override
  Future<void> requestSubscriptionRegistration({required String msisdn}) async {
    registrationCalls++;
    calls.add('register');
  }

  @override
  Future<SubscriptionStatusResponse?> waitForSubscriptionActivation({
    required String msisdn,
    bool Function()? isCancelled,
    Duration? pollInterval,
    Duration? timeout,
  }) async {
    activationPolls++;
    calls.add('poll');
    if (activation != null) return activation!.future;
    if (!activatesAfterRegistration) return null;
    return SubscriptionStatusResponse(
      msisdn: msisdn,
      status: 'active',
      subscribed: true,
    );
  }

  @override
  Future<BillingTransactionResponse> enqueueBilling({required String msisdn}) {
    enqueueCalls++;
    calls.add('billing');
    throw StateError('Billing must not run for an inactive subscription.');
  }
}

void main() {
  test(
    'inactive status registers once and waits before billing, even on repeat taps',
    () async {
      final activation = Completer<SubscriptionStatusResponse?>();
      final gameService = _BillingSpyGameService(activation: activation);
      final controller = GameController(
        msisdn: '255676589824',
        gameService: gameService,
      );
      addTearDown(controller.dispose);

      final preparation = controller.openRoundBoard();
      await Future<void>.delayed(Duration.zero);
      expect(gameService.calls, ['status', 'register', 'poll']);
      expect(controller.state.isSubmitting, isTrue);
      expect(
        controller.state.statusMessage,
        RoundBillingCopy.awaitingSubscriptionConfirmation,
      );

      await controller.openRoundBoard();
      expect(gameService.registrationCalls, 1);
      expect(gameService.enqueueCalls, 0);

      activation.complete(
        const SubscriptionStatusResponse(
          msisdn: '255676589824',
          status: 'ACTIVE',
          subscribed: true,
        ),
      );
      await preparation;
      expect(gameService.calls, ['status', 'register', 'poll', 'billing']);
    },
  );

  test('INACTIVE status always calls registration before billing', () async {
    final gameService = _BillingSpyGameService(
      subscribed: true,
      status: 'INACTIVE',
    );
    final controller = GameController(
      msisdn: '255676589824',
      gameService: gameService,
    );
    addTearDown(controller.dispose);

    await controller.openRoundBoard();

    expect(gameService.subscriptionChecks, 1);
    expect(gameService.registrationCalls, 1);
    expect(gameService.activationPolls, 1);
    expect(gameService.enqueueCalls, 0);
    expect(
      controller.state.roundErrorMessage,
      RoundBillingCopy.subscriptionConfirmationTimedOut,
    );
    expect(controller.state.isSubmitting, isFalse);
  });

  test('active subscription proceeds to billing', () async {
    final gameService = _BillingSpyGameService(subscribed: true);
    final controller = GameController(
      msisdn: '255676589824',
      gameService: gameService,
    );
    addTearDown(controller.dispose);

    await controller.openRoundBoard();

    expect(gameService.subscriptionChecks, 1);
    expect(gameService.registrationCalls, 0);
    expect(gameService.activationPolls, 0);
    expect(gameService.enqueueCalls, 1);
  });

  test(
    'inactive subscriber is registered and billed after confirmation',
    () async {
      final gameService = _BillingSpyGameService(
        activatesAfterRegistration: true,
      );
      final controller = GameController(
        msisdn: '255676589824',
        gameService: gameService,
      );
      addTearDown(controller.dispose);

      await controller.openRoundBoard();

      expect(gameService.subscriptionChecks, 1);
      expect(gameService.registrationCalls, 1);
      expect(gameService.activationPolls, 1);
      expect(gameService.enqueueCalls, 1);
    },
  );
}
