import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stopwatch_game/core/billing/round_billing_copy.dart';
import 'package:stopwatch_game/features/game/data/game_service.dart';
import 'package:stopwatch_game/features/game/data/models/billing_transaction_response.dart';
import 'package:stopwatch_game/features/game/data/models/subscription_status_response.dart';
import 'package:stopwatch_game/features/game/data/models/target_time_response.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_notifier.dart';

class _BillingSpyGameService extends GameService {
  _BillingSpyGameService({
    this.subscribed = false,
    this.status,
    this.activatesAfterRegistration = false,
    this.activation,
  });

  bool subscribed;
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

class _SuccessfulRoundService extends _BillingSpyGameService {
  BillingTransactionResponse transaction(String requestId) =>
      BillingTransactionResponse(
        id: enqueueCalls,
        msisdn: '255676589824',
        requestId: requestId,
        billingType: 'play',
        amount: 100,
        status: 'success',
      );

  @override
  Future<BillingTransactionResponse> enqueueBilling({
    required String msisdn,
  }) async {
    enqueueCalls++;
    return transaction('round-$enqueueCalls');
  }

  @override
  Future<BillingTransactionResponse> waitForBillingSuccess({
    required String requestId,
    bool Function()? isCancelled,
  }) async => transaction(requestId);

  @override
  Future<TargetTimeResponse> fetchTargetTime({required String msisdn}) async =>
      TargetTimeResponse(msisdn: msisdn, targetTimeMs: 10000);
}

void main() {
  test(
    'registered user is billed separately for every subsequent active round',
    () async {
      final service = _SuccessfulRoundService();
      final controller = GameController(
        msisdn: '255676589824',
        gameService: service,
      );
      addTearDown(controller.dispose);

      await controller.onPlayRoundPressed();
      expect(service.registrationCalls, 1);
      expect(service.enqueueCalls, 0);

      // The backend reports activation after the subscriber confirms the SMS.
      service.subscribed = true;
      await controller.onPlayRoundPressed();
      expect(controller.state.billingRequestId, 'round-1');
      expect(controller.state.canStartRound, isTrue);

      // Repeated Play on an already paid round must not charge twice.
      await controller.onPlayRoundPressed();
      expect(service.enqueueCalls, 1);

      await controller.openRoundBoard();
      expect(controller.state.billingRequestId, 'round-2');
      await controller.openRoundBoard();
      expect(controller.state.billingRequestId, 'round-3');
      expect(service.enqueueCalls, 3);
      expect(service.subscriptionChecks, 4);
      expect(service.registrationCalls, 1);
      expect(service.activationPolls, 0);
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
    expect(gameService.activationPolls, 0);
    expect(gameService.enqueueCalls, 0);
    expect(
      controller.state.statusMessage,
      RoundBillingCopy.registrationRequested,
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
    'inactive subscriber registers once without polling or billing',
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
      expect(gameService.activationPolls, 0);
      expect(gameService.enqueueCalls, 0);
    },
  );
}
