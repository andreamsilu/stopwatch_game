import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/providers/player_session_provider.dart';
import 'package:stopwatch_game/core/widgets/app_snackbar.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_provider.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';
import 'package:stopwatch_game/core/widgets/app_footer.dart';
import 'package:stopwatch_game/features/auth/presentation/widgets/login_form_card.dart';
import 'package:stopwatch_game/features/game/presentation/pages/game_page.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  Future<void> _completeAuth(BuildContext context, WidgetRef ref) async {
    final loginState = ref.read(loginProvider);
    final user = loginState.authenticatedUser!;
    ref.read(playerMsisdnProvider.notifier).state = user.msisdn;
    ref.read(playerUserProvider.notifier).state = user;
    ref.read(subscriptionActiveProvider.notifier).state = true;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const GamePage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);
    final loginNotifier = ref.read(loginProvider.notifier);
    final isOtpStep = loginState.step == LoginStep.otp;

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

    final headline =
        isOtpStep ? AuthCopy.verifyTitle : AuthCopy.welcomeTitle;
    final subtitle = isOtpStep
        ? AuthCopy.verifySubtitle(loginState.maskedPhone)
        : AuthCopy.welcomeSubtitle;

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
                final compact = constraints.maxHeight < 760;
                final horizontalPad = isMobile ? 18.0 : 28.0;
                final verticalPad = compact ? 12.0 : 22.0;

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
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Column(
                              children: [
                                _StopwatchMark(size: compact ? 80 : 96),
                                SizedBox(height: compact ? 12 : 18),
                                Text(
                                  headline,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontSize: isMobile ? 34 : 42,
                                        fontWeight: FontWeight.w800,
                                        height: 1.04,
                                        letterSpacing: -0.8,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  subtitle,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: AppColors.onBackground,
                                        fontSize: isMobile ? 16 : 18,
                                        height: 1.35,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                if (!isOtpStep) ...[
                                  SizedBox(height: compact ? 14 : 20),
                                  const _TargetTimeDisplay(),
                                  SizedBox(height: compact ? 12 : 16),
                                  Text(
                                    AuthCopy.welcomeSupport,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: const Color(0xFF52657A),
                                          height: 1.4,
                                        ),
                                  ),
                                ],
                                SizedBox(height: compact ? 16 : 22),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 440),
                                  child: LoginFormCard(
                                    step: loginState.step,
                                    phoneValue: loginState.phoneNumber,
                                    otpCode: loginState.otpCode,
                                    isSubmitting: loginState.isSubmitting,
                                    isResendingOtp: loginState.isResendingOtp,
                                    canSubmitPhone: loginState.canSubmitPhone,
                                    canVerifyOtp: loginState.canVerifyOtp,
                                    infoMessage: loginState.infoMessage,
                                    onPhoneChanged:
                                        loginNotifier.updatePhoneNumber,
                                    onOtpChanged: loginNotifier.updateOtpCode,
                                    onSubmitPhone: () async {
                                      final authenticated =
                                          await loginNotifier.submitPhone();
                                      if (!context.mounted) return;
                                      if (authenticated) {
                                        await _completeAuth(context, ref);
                                      }
                                    },
                                    onResendOtp: () async {
                                      final authenticated =
                                          await loginNotifier.resendOtp();
                                      if (!context.mounted) return;
                                      if (authenticated) {
                                        await _completeAuth(context, ref);
                                      }
                                    },
                                    onBackToPhone: loginNotifier.backToPhone,
                                    onVerifyOtp: () async {
                                      final isSuccess =
                                          await loginNotifier.verifyOtp();
                                      if (!context.mounted || !isSuccess) {
                                        return;
                                      }
                                      await _completeAuth(context, ref);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 22),
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
