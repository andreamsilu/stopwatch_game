import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/api/api_messages.dart';
import 'package:stopwatch_game/core/providers/auth_providers.dart';
import 'package:stopwatch_game/features/game/data/game_service.dart';
import 'package:stopwatch_game/features/game/data/models/game_history_play.dart';

const historyPageSize = 20;

class GameHistoryState {
  const GameHistoryState({
    this.plays = const [],
    this.isLoading = false,
    this.errorMessage,
    this.page = 0,
    this.hasNextPage = false,
  });

  final List<GameHistoryPlay> plays;
  final bool isLoading;
  final String? errorMessage;

  /// Zero-based page index (matches API `page` query).
  final int page;
  final bool hasNextPage;

  bool get hasPreviousPage => page > 0;

  int get displayPage => page + 1;

  GameHistoryState copyWith({
    List<GameHistoryPlay>? plays,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    int? page,
    bool? hasNextPage,
  }) {
    return GameHistoryState(
      plays: plays ?? this.plays,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      page: page ?? this.page,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}

class GameHistoryNotifier extends StateNotifier<GameHistoryState> {
  GameHistoryNotifier(this._gameService) : super(const GameHistoryState());

  final GameService _gameService;

  Future<void> load({bool refresh = false}) => goToPage(refresh ? 0 : state.page);

  Future<void> goToPage(int page) async {
    if (page < 0 || state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      page: page,
    );

    try {
      final response = await _gameService.fetchGameHistory(
        page: page,
        size: historyPageSize,
      );
      final batch = response.plays;
      state = state.copyWith(
        isLoading: false,
        plays: batch,
        page: page,
        hasNextPage: batch.length >= historyPageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: ApiMessages.fromError(e),
      );
    }
  }

  Future<void> nextPage() async {
    if (!state.hasNextPage) return;
    await goToPage(state.page + 1);
  }

  Future<void> previousPage() async {
    if (!state.hasPreviousPage) return;
    await goToPage(state.page - 1);
  }
}

final gameServiceProvider = Provider<GameService>((ref) {
  return GameService.create(api: ref.watch(stopwatchApiProvider));
});

final gameHistoryProvider =
    StateNotifierProvider<GameHistoryNotifier, GameHistoryState>((ref) {
      return GameHistoryNotifier(ref.watch(gameServiceProvider));
    });
