import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_notifier.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';

final gameControllerProvider = StateNotifierProvider<GameController, GameState>(
  (ref) {
    return GameController();
  },
);
