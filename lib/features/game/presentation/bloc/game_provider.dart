import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/providers/auth_providers.dart';
import 'package:stopwatch_game/core/providers/player_session_provider.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_notifier.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';

/// Game session controller for the current [GamePage] visit.
///
/// Uses [ref.read] for player session fields so logout clearing MSISDN does not
/// dispose the controller while billing HTTP is still in flight.
final gameControllerProvider = StateNotifierProvider<GameController, GameState>(
  (ref) {
    final msisdn = ref.read(playerMsisdnProvider);
    final isSubscribed = ref.read(subscriptionActiveProvider);
    final api = ref.watch(stopwatchApiProvider);
    return GameController(
      msisdn: msisdn,
      isSubscribed: isSubscribed,
      subscriptionStatusChecker: () async {
        final currentUser = ref.read(playerUserProvider);
        if (currentUser == null) return false;

        final refreshedUser = await ref
            .read(authServiceProvider)
            .getUserById(id: currentUser.id);
        ref.read(playerUserProvider.notifier).state = refreshedUser;

        final isActive = refreshedUser.status.trim().toLowerCase() == 'active';
        ref.read(subscriptionActiveProvider.notifier).state = isActive;
        return isActive;
      },
      api: api,
      telemetryService: ref.watch(interactionTelemetryProvider),
    );
  },
);
