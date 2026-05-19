import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/providers/auth_providers.dart';
import 'package:stopwatch_game/core/providers/player_session_provider.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_notifier.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';

final gameControllerProvider = StateNotifierProvider<GameController, GameState>(
  (ref) {
    final msisdn = ref.watch(playerMsisdnProvider);
    final isSubscribed = ref.watch(subscriptionActiveProvider);
    final api = ref.watch(stopwatchApiProvider);
    return GameController(
      msisdn: msisdn,
      isSubscribed: isSubscribed,
      api: api,
    );
  },
);
