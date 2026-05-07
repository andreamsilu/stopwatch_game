import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/core/services/game_feedback_service.dart';
import 'package:stopwatch_game/core/widgets/experience_background.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_controller.dart';
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
    final useDrawerNav =
        MediaQuery.of(context).size.width < GameConstants.mobileBreakpoint;
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
      appBar: useDrawerNav
          ? AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                Builder(
                  builder: (context) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton.filledTonal(
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      tooltip: 'Open navigation menu',
                      icon: const Icon(Icons.menu_rounded),
                    ),
                  ),
                ),
              ],
            )
          : null,
      endDrawer: useDrawerNav
          ? Drawer(
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
                      Expanded(
                        child: ListView(
                          children: [
                            _DrawerNavTile(
                              label: 'Home',
                              icon: Icons.home_outlined,
                              isActive: gameState.selectedTab == GameTab.home,
                              onTap: () {
                                controller.selectTab(GameTab.home);
                                Navigator.of(context).maybePop();
                              },
                            ),
                            _DrawerNavTile(
                              label: 'Play',
                              icon: Icons.play_arrow_rounded,
                              isActive: gameState.selectedTab == GameTab.play,
                              onTap: () {
                                controller.selectTab(GameTab.play);
                                Navigator.of(context).maybePop();
                              },
                            ),
                            _DrawerNavTile(
                              label: 'History',
                              icon: Icons.history,
                              isActive: gameState.selectedTab == GameTab.history,
                              onTap: () {
                                controller.selectTab(GameTab.history);
                                Navigator.of(context).maybePop();
                              },
                            ),
                            _DrawerNavTile(
                              label: 'Support',
                              icon: Icons.support_agent_outlined,
                              isActive: gameState.selectedTab == GameTab.support,
                              onTap: () {
                                controller.selectTab(GameTab.support);
                                Navigator.of(context).maybePop();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
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
                        if (!useDrawerNav) ...[
                          GameTopNavigation(
                            activeTab: gameState.selectedTab,
                            onTabSelected: controller.selectTab,
                          ),
                          const SizedBox(height: 6),
                        ],
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
                                      onToggleSound: controller.toggleSoundEnabled,
                                      onStartControlPointerDown:
                                          controller.onStartControlPointerDown,
                                      onStartControlPointerMove:
                                          controller.onStartControlPointerMove,
                                      onStartControlPointerUp:
                                          controller.onStartControlPointerUp,
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

class _DrawerNavTile extends StatelessWidget {
  const _DrawerNavTile({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(label),
        selected: isActive,
        selectedTileColor: AppColors.secondary.withValues(alpha: 0.16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
    required this.onToggleSound,
    required this.onStartControlPointerDown,
    required this.onStartControlPointerMove,
    required this.onStartControlPointerUp,
    required this.onStartOrStopRound,
  });

  final GameState state;
  final VoidCallback onPlayPressed;
  final VoidCallback onOpenHistory;
  final VoidCallback onResetRound;
  final VoidCallback onToggleSound;
  final void Function(Offset position, {bool? isTrusted}) onStartControlPointerDown;
  final ValueChanged<Offset> onStartControlPointerMove;
  final void Function(Offset position, {bool? isTrusted}) onStartControlPointerUp;
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
          isSoundEnabled: state.isSoundEnabled,
          startButtonVisualOffset: state.startButtonVisualOffset,
          startButtonHitboxOffset: state.startButtonHitboxOffset,
          onReset: onResetRound,
          onToggleSound: onToggleSound,
          onStartControlPointerDown: onStartControlPointerDown,
          onStartControlPointerMove: onStartControlPointerMove,
          onStartControlPointerUp: onStartControlPointerUp,
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
