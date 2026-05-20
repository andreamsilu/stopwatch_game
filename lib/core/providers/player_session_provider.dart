import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/features/auth/data/models/user_model.dart';

/// Logged-in player MSISDN used for game and billing API calls.
final playerMsisdnProvider = StateProvider<String>((ref) => '');

/// Logged-in user profile from `POST/GET /api/v1/users`.
final playerUserProvider = StateProvider<UserModel?>((ref) => null);

final playerUserIdProvider = Provider<int?>((ref) {
  return ref.watch(playerUserProvider)?.id;
});

/// Set when the player has completed login and can use the game.
final subscriptionActiveProvider = StateProvider<bool>((ref) => false);
