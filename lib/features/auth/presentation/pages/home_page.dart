import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/providers/auth_providers.dart';
import 'package:stopwatch_game/core/providers/player_session_provider.dart';
import 'package:stopwatch_game/core/widgets/app_snackbar.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_provider.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';
import 'package:stopwatch_game/core/widgets/app_footer.dart';
import 'package:stopwatch_game/features/auth/presentation/widgets/login_form_card.dart';
import 'package:stopwatch_game/features/game/presentation/pages/game_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _completeAuth(BuildContext context, WidgetRef ref) async {
    final loginState = ref.read(loginProvider);
    final user = loginState.authenticatedUser!;
    ref.read(playerMsisdnProvider.notifier).state = user.msisdn;
    ref.read(playerUserProvider.notifier).state = user;
    ref.read(subscriptionActiveProvider.notifier).state = true;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const GamePage()));
  }

  Future<void> _startOrResumeGame(BuildContext context, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    var session = authService.currentSession;
    session ??= await ref.read(authSessionStorageProvider).readValidSession();
    if (!context.mounted) return;

    if (session != null) {
      authService.restoreSession(session);
      ref.read(playerMsisdnProvider.notifier).state = session.user.msisdn;
      ref.read(playerUserProvider.notifier).state = session.user;
      ref.read(subscriptionActiveProvider.notifier).state = true;
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const GamePage()));
      return;
    }

    await _showLoginDialog(context, ref);
  }

  Future<void> _showLoginDialog(
    BuildContext pageContext,
    WidgetRef pageRef,
  ) async {
    Future<void> finishAuth(BuildContext dialogContext) async {
      if (!dialogContext.mounted || !pageContext.mounted) return;
      Navigator.of(dialogContext).pop();
      await _completeAuth(pageContext, pageRef);
    }

    await showDialog<void>(
      context: pageContext,
      barrierColor: AppColors.primary.withValues(alpha: 0.58),
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final loginState = ref.watch(loginProvider);
          final loginNotifier = ref.read(loginProvider.notifier);
          final isOtpStep = loginState.step == LoginStep.otp;

          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              backgroundColor: const Color(0xFFF3F8FD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const _StopwatchMark(size: 48),
                          const Spacer(),
                          IconButton(
                            onPressed: loginState.isSubmitting
                                ? null
                                : () => Navigator.of(dialogContext).pop(),
                            tooltip: 'Close login',
                            icon: const Icon(Icons.close_rounded),
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isOtpStep ? AuthCopy.verifyTitle : 'Ready to play?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isOtpStep
                            ? AuthCopy.verifySubtitle(loginState.maskedPhone)
                            : 'Enter your mobile number to continue.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF52657A),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      LoginFormCard(
                        step: loginState.step,
                        phoneValue: loginState.phoneNumber,
                        otpCode: loginState.otpCode,
                        isSubmitting: loginState.isSubmitting,
                        isResendingOtp: loginState.isResendingOtp,
                        canSubmitPhone: loginState.canSubmitPhone,
                        canVerifyOtp: loginState.canVerifyOtp,
                        infoMessage: loginState.infoMessage,
                        onPhoneChanged: loginNotifier.updatePhoneNumber,
                        onOtpChanged: loginNotifier.updateOtpCode,
                        onSubmitPhone: () async {
                          final authenticated = await loginNotifier
                              .submitPhone();
                          if (authenticated && dialogContext.mounted) {
                            await finishAuth(dialogContext);
                          }
                        },
                        onResendOtp: () async {
                          final authenticated = await loginNotifier.resendOtp();
                          if (authenticated && dialogContext.mounted) {
                            await finishAuth(dialogContext);
                          }
                        },
                        onBackToPhone: loginNotifier.backToPhone,
                        onVerifyOtp: () async {
                          final authenticated = await loginNotifier.verifyOtp();
                          if (authenticated && dialogContext.mounted) {
                            await finishAuth(dialogContext);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<LoginState>(loginProvider, (previous, next) {
      if (!context.mounted) return;

      if (next.errorMessage != null &&
          next.errorMessage!.isNotEmpty &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackBar.showError(context, next.errorMessage!);
      }

      if (next.infoMessage != null &&
          next.infoMessage!.isNotEmpty &&
          next.infoMessage != previous?.infoMessage &&
          next.step == LoginStep.otp) {
        AppSnackBar.showInfo(context, next.infoMessage!);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FD),
      body: Stack(
        children: [
          const Positioned(
            top: 112,
            left: 0,
            child: _SpeedLines(color: Color(0x1A00377D)),
          ),
          const Positioned(
            top: 220,
            right: 0,
            child: _SpeedLines(color: Color(0x2BFFD100), mirror: true),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;
                final horizontalPad = isMobile ? 18.0 : 28.0;
                final verticalPad = constraints.maxHeight < 720 ? 12.0 : 20.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPad,
                    vertical: verticalPad,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (verticalPad * 2),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1040),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Column(
                              children: [
                                _TopNavigation(
                                  onLogin: () =>
                                      _startOrResumeGame(context, ref),
                                ),
                                SizedBox(height: isMobile ? 42 : 70),
                                _HomepageHero(
                                  isMobile: isMobile,
                                  onStart: () =>
                                      _startOrResumeGame(context, ref),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 42),
                              child: AppFooter(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TopNavigation extends StatelessWidget {
  const _TopNavigation({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _StopwatchMark(size: 44),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Stopwatch Challenge',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: onLogin,
          icon: const Icon(Icons.person_outline_rounded, size: 18),
          label: const Text('LOGIN'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            overlayColor: AppColors.accent.withValues(alpha: 0.22),
            minimumSize: const Size(104, 46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomepageHero extends StatelessWidget {
  const _HomepageHero({required this.isMobile, required this.onStart});

  final bool isMobile;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final copy = Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (isMobile) ...[
          const _StopwatchMark(size: 96),
          const SizedBox(height: 22),
        ],
        Text(
          'FAST  ·  FUN  ·  SIMPLE  ·  PRECISE',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          AuthCopy.welcomeTitle,
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppColors.primary,
            fontSize: isMobile ? 42 : 54,
            fontWeight: FontWeight.w800,
            height: 1.02,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AuthCopy.welcomeSubtitle,
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.onBackground,
            fontSize: isMobile ? 19 : 23,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AuthCopy.welcomeSupport,
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF52657A),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Closest time wins.',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 26),
        SizedBox(
          width: isMobile ? double.infinity : 220,
          height: 54,
          child: FilledButton(
            onPressed: onStart,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              overlayColor: AppColors.accent.withValues(alpha: 0.22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'START PLAYING  →',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        children: [
          copy,
          const SizedBox(height: 30),
          const _TargetTimeDisplay(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 6, child: copy),
        const SizedBox(width: 64),
        const Expanded(flex: 4, child: _ChallengeVisual()),
      ],
    );
  }
}

class _ChallengeVisual extends StatelessWidget {
  const _ChallengeVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE1EAF3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1000377D),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StopwatchMark(size: 118),
          SizedBox(height: 26),
          _TargetTimeDisplay(),
        ],
      ),
    );
  }
}

class _StopwatchMark extends StatelessWidget {
  const _StopwatchMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Stopwatch Challenge logo',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size * 0.86,
              height: size * 0.86,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 4),
              ),
            ),
            Icon(
              Icons.timer_outlined,
              size: size * 0.68,
              color: AppColors.primary,
            ),
            Positioned(
              right: size * 0.08,
              bottom: size * 0.1,
              child: Container(
                width: size * 0.25,
                height: size * 0.25,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  size: size * 0.17,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetTimeDisplay extends StatelessWidget {
  const _TargetTimeDisplay();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Your target time is 10.00 seconds',
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 11),
        decoration: BoxDecoration(
          color: const Color(0xFFE7F2FC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC9DEEF)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                7,
                (index) => Container(
                  width: index == 3 ? 3 : 2,
                  height: index == 3 ? 8 : 5,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: index == 3
                        ? AppColors.accent
                        : AppColors.primary.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const Text(
              '10.00',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 34,
                height: 1.05,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'YOUR TARGET TIME',
              style: TextStyle(
                color: Color(0xFF52657A),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedLines extends StatelessWidget {
  const _SpeedLines({required this.color, this.mirror = false});

  final Color color;
  final bool mirror;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.flip(
        flipX: mirror,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 74, height: 3, color: color),
            const SizedBox(height: 9),
            Container(width: 45, height: 3, color: color),
            const SizedBox(height: 9),
            Container(width: 60, height: 3, color: color),
          ],
        ),
      ),
    );
  }
}
