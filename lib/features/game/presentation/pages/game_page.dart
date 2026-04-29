import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_controller.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/game_top_navigation.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/history_panel.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/home_overview_panel.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/leaderboard_panel.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/round_play_panel.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/round_result_dialog.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/settings_panel.dart';

class GamePage extends ConsumerWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    ref.listen<GameState>(gameControllerProvider, (previous, next) async {
      final hadDialog = previous?.latestResult != null;
      final shouldShowDialog = next.latestResult != null && !hadDialog;
      if (!shouldShowDialog || !context.mounted) return;
      final result = next.latestResult!;
      await showDialog<void>(
        context: context,
        builder: (_) => RoundResultDialog(
          result: result,
          onPlayAgain: controller.onResetPressed,
        ),
      );
      controller.dismissResultDialog();
    });

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0F5FF), Color(0xFFF8FAFD)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isMobile = width < GameConstants.mobileBreakpoint;
              final isTablet =
                  width >= GameConstants.mobileBreakpoint &&
                  width < GameConstants.tabletBreakpoint;
              final isLargeDesktop = width >= 1400;
              final horizontalPadding = isMobile
                  ? 14.0
                  : (isTablet ? 22.0 : (isLargeDesktop ? 40.0 : 32.0));
              final verticalPadding = isMobile ? 16.0 : 24.0;
              final maxContentWidth = isMobile
                  ? width
                  : (isTablet ? 980.0 : (isLargeDesktop ? 1280.0 : 1120.0));

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GameTopNavigation(
                          activeTab: gameState.selectedTab,
                          onTabSelected: controller.selectTab,
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isLargeDesktop ? 1100 : double.infinity,
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.02),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _GameBody(
                                    key: ValueKey<GameTab>(gameState.selectedTab),
                                    state: gameState,
                                    onPlayPressed: controller.openRoundBoard,
                                    onOpenLeaderboard: () =>
                                        controller.selectTab(GameTab.leaderboard),
                                    onOpenHistory: () =>
                                        controller.selectTab(GameTab.history),
                                    onResetRound: controller.onResetPressed,
                                    onStartOrStopRound: () async {
                                      if (gameState.isRunning) {
                                        await controller.onStopPressed();
                                      } else {
                                        await controller.onStartPressed();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GameBody extends StatelessWidget {
  const _GameBody({
    super.key,
    required this.state,
    required this.onPlayPressed,
    required this.onOpenLeaderboard,
    required this.onOpenHistory,
    required this.onResetRound,
    required this.onStartOrStopRound,
  });

  final GameState state;
  final VoidCallback onPlayPressed;
  final VoidCallback onOpenLeaderboard;
  final VoidCallback onOpenHistory;
  final VoidCallback onResetRound;
  final Future<void> Function() onStartOrStopRound;

  @override
  Widget build(BuildContext context) {
    switch (state.selectedTab) {
      case GameTab.home:
        if (!state.showRoundBoard) {
          return HomeOverviewPanel(
            onPlayPressed: onPlayPressed,
            onOpenLeaderboard: onOpenLeaderboard,
            onOpenHistory: onOpenHistory,
          );
        }
        return RoundPlayPanel(
          targetTimeLabel: state.targetTimeLabel,
          currentTimeLabel: state.elapsedTimeLabel,
          isRunning: state.isRunning,
          isBusy: state.isSubmitting,
          onReset: onResetRound,
          onStartOrStopRound: onStartOrStopRound,
        );
      case GameTab.leaderboard:
        return LeaderboardPanel(entries: state.leaderboard);
      case GameTab.history:
        return HistoryPanel(history: state.history);
      case GameTab.settings:
        return const SettingsPanel();
    }
  }
}
