import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/features/auth/data/models/user_model.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';

/// Logged-in player MSISDN used for game and billing API calls.
final playerMsisdnProvider = StateProvider<String>((ref) {
  return LoginState.defaultPhoneNumber.startsWith('255')
      ? LoginState.defaultPhoneNumber
      : '255${LoginState.defaultPhoneNumber}';
});

/// Logged-in user profile from `POST/GET /api/v1/users`.
final playerUserProvider = StateProvider<UserModel?>((ref) => null);

final playerUserIdProvider = Provider<int?>((ref) {
  return ref.watch(playerUserProvider)?.id;
});

/// Set when the user completes registration/sign-in with subscription consent.
final subscriptionActiveProvider = StateProvider<bool>((ref) => false);
