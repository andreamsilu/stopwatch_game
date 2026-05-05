import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/core/services/game_feedback_service.dart';
import 'package:stopwatch_game/core/widgets/experience_background.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_controller.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_state.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/game_top_navigation.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/history_panel.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/help_support_panel.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/home_overview_panel.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/round_play_panel.dart';
import 'package:stopwatch_game/features/game/presentation/widgets/round_result_dialog.dart';

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
      if (result.isPrizeAwarded) {
        await GameFeedbackService.onWin();
      } else {
        await GameFeedbackService.onLose();
      }
      await showDialog<void>(
        context: context,
        builder: (_) => RoundResultDialog(
          result: result,
          onPlayAgain: controller.onResetPressed,
          onCancel: controller.onResetPressed,
        ),
      );
      controller.dismissResultDialog();
    });

    return Scaffold(
      endDrawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Navigation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                GameTopNavigation(
                  activeTab: gameState.selectedTab,
                  onTabSelected: (tab) {
                    controller.selectTab(tab);
                    Navigator.of(context).maybePop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: ExperienceBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isMobile = width < GameConstants.mobileBreakpoint;
              final isTablet =
                  width >= GameConstants.mobileBreakpoint &&
                  width < GameConstants.tabletBreakpoint;
              final isLargeDesktop = width >= 1400;
              final isWindows = defaultTargetPlatform == TargetPlatform.windows;
              final isVerySmallMobile = width < 380;
              final horizontalPadding = isMobile
                  ? (isVerySmallMobile ? 8.0 : 12.0)
                  : (isWindows
                        ? 12.0
                        : (isTablet ? 22.0 : (isLargeDesktop ? 40.0 : 32.0)));
              final verticalPadding = isMobile ? (isVerySmallMobile ? 6.0 : 8.0) : 20.0;
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
                        _GameHeaderBar(activeTab: gameState.selectedTab),
                        const SizedBox(height: 6),
                        Builder(
                          builder: (context) => Align(
                            alignment: Alignment.centerRight,
                            child: IconButton.filledTonal(
                              onPressed: () => Scaffold.of(context).openEndDrawer(),
                              tooltip: 'Open navigation menu',
                              icon: const Icon(Icons.menu_rounded),
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: controller.onPullToRefresh,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
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
                                    child: _GamePanelShell(
                                      child: _GameBody(
                                        key: ValueKey<GameTab>(gameState.selectedTab),
                                        state: gameState,
                                        onPlayPressed: controller.openRoundBoard,
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

class _GameHeaderBar extends StatelessWidget {
  const _GameHeaderBar({required this.activeTab});

  final GameTab activeTab;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _titleForTab(activeTab),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  String _titleForTab(GameTab tab) {
    switch (tab) {
      case GameTab.home:
        return 'Home';
      case GameTab.play:
        return 'Play';
      case GameTab.history:
        return 'History';
      case GameTab.support:
        return 'Support';
    }
  }
}

class _GamePanelShell extends StatelessWidget {
  const _GamePanelShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 420;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background.withValues(alpha: 0.96),
            AppColors.secondary.withValues(alpha: 0.08),
            AppColors.background.withValues(alpha: 0.96),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.all(isSmallMobile ? 2 : 8),
      child: child,
    );
  }
}

class _GameBody extends StatelessWidget {
  const _GameBody({
    super.key,
    required this.state,
    required this.onPlayPressed,
    required this.onOpenHistory,
    required this.onResetRound,
    required this.onStartOrStopRound,
  });

  final GameState state;
  final VoidCallback onPlayPressed;
  final VoidCallback onOpenHistory;
  final VoidCallback onResetRound;
  final Future<void> Function() onStartOrStopRound;

  @override
  Widget build(BuildContext context) {
    switch (state.selectedTab) {
      case GameTab.home:
        return HomeOverviewPanel(
          onPlayPressed: onPlayPressed,
          onOpenHistory: onOpenHistory,
        );
      case GameTab.play:
        return RoundPlayPanel(
          targetTimeLabel: state.targetTimeLabel,
          currentTimeLabel: state.elapsedTimeLabel,
          elapsed: state.elapsed,
          targetTime: state.targetTime,
          isRunning: state.isRunning,
          isBusy: state.isSubmitting,
          onReset: onResetRound,
          onStartOrStopRound: onStartOrStopRound,
          totalWins: state.totalWins,
          totalPrizeCoins: state.totalPrizeCoins,
        );
      case GameTab.history:
        return HistoryPanel(history: state.history);
      case GameTab.support:
        return const HelpSupportPanel();
    }
  }
}
