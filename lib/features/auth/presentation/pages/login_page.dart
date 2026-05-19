import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/providers/player_session_provider.dart';
import 'package:stopwatch_game/core/widgets/app_snackbar.dart';
import 'package:stopwatch_game/core/widgets/experience_background.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_provider.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';
import 'package:stopwatch_game/features/auth/presentation/widgets/login_footer.dart';
import 'package:stopwatch_game/features/auth/presentation/widgets/login_form_card.dart';
import 'package:stopwatch_game/features/game/presentation/pages/game_page.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  Future<void> _completeAuth(BuildContext context, WidgetRef ref) async {
    final user = ref.read(loginProvider).authenticatedUser!;
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
          next.errorMessage != previous?.errorMessage) {
        AppSnackBar.showError(context, next.errorMessage!);
      }

      if (previous?.isSubmitting == false &&
          next.isSubmitting &&
          next.step == LoginStep.phone) {
        AppSnackBar.showInfo(context, 'Sending verification code…');
      }

      if (previous?.step == LoginStep.phone &&
          next.step == LoginStep.otp &&
          next.errorMessage == null) {
        AppSnackBar.showSuccess(
          context,
          'Code sent to ${next.maskedPhone}.',
        );
      }

      if (previous?.isResendingOtp == true &&
          !next.isResendingOtp &&
          next.errorMessage == null) {
        AppSnackBar.showInfo(context, 'A new code has been sent.');
      }
    });

    final headline = isOtpStep
        ? 'Verify your number'
        : loginState.isLogin
        ? 'Welcome back'
        : 'Welcome';

    final subtitle = isOtpStep
        ? 'Enter the 6-digit code we sent to your phone.'
        : loginState.isLogin
        ? 'Sign in with your phone number.'
        : 'Register to play Stopwatch Challenge.';

    return Scaffold(
      body: ExperienceBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;
              final contentWidth = isMobile ? constraints.maxWidth : 560.0;

              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: isMobile ? 16 : 14,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: contentWidth,
                      minHeight: constraints.maxHeight - (isMobile ? 32 : 28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: isMobile ? 10 : 20),
                        Align(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, Color(0xFF174EA3)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x2600377D),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.timer,
                              color: AppColors.accent,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          headline,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontSize: isMobile ? 34 : 38,
                                height: 1.1,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.onBackground.withValues(alpha: 0.74),
                            fontSize: isMobile ? 15 : 17,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Align(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 430),
                            child: LoginFormCard(
                              intent: loginState.intent,
                              step: loginState.step,
                              phoneValue: loginState.phoneNumber,
                              otpCode: loginState.otpCode,
                              maskedPhone: loginState.maskedPhone,
                              isSubmitting: loginState.isSubmitting,
                              isResendingOtp: loginState.isResendingOtp,
                              canSendOtp: loginState.canSendOtp,
                              canVerifyOtp: loginState.canVerifyOtp,
                              subscriptionAccepted:
                                  loginState.subscriptionAccepted,
                              errorMessage: loginState.errorMessage,
                              onIntentChanged: loginNotifier.setAuthIntent,
                              onPhoneChanged: loginNotifier.updatePhoneNumber,
                              onOtpChanged: loginNotifier.updateOtpCode,
                              onSubscriptionAcceptedChanged:
                                  loginNotifier.setSubscriptionAccepted,
                              onSendOtp: loginNotifier.sendOtp,
                              onResendOtp: loginNotifier.resendOtp,
                              onBackToPhone: loginNotifier.backToPhone,
                              onVerifyOtp: () async {
                                final isLogin = loginState.isLogin;
                                AppSnackBar.showInfo(
                                  context,
                                  isLogin ? 'Signing you in…' : 'Creating your account…',
                                );
                                final isSuccess = await loginNotifier.verifyOtp();
                                if (!context.mounted || !isSuccess) return;
                                AppSnackBar.showSuccess(
                                  context,
                                  isLogin
                                      ? 'Welcome back! You are ready to play.'
                                      : 'Account created. You are ready to play.',
                                );
                                await _completeAuth(context, ref);
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 30 : 46),
                        const LoginFooter(),
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
