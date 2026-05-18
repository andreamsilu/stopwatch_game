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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);
    final loginNotifier = ref.read(loginProvider.notifier);
    final isConfirmStep = loginState.step == LoginStep.confirm;

    ref.listen<LoginState>(loginProvider, (previous, next) {
      if (!context.mounted) return;

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackBar.showError(context, next.errorMessage!);
      }

      if (previous?.isSubmitting == false &&
          next.isSubmitting &&
          next.step == LoginStep.phone) {
        AppSnackBar.showInfo(context, 'Checking your number…');
      }

      if (previous?.step == LoginStep.phone &&
          next.step == LoginStep.confirm &&
          next.errorMessage == null) {
        AppSnackBar.showSuccess(
          context,
          next.existingUser != null
              ? 'Welcome back! Confirm to continue.'
              : 'Almost there — confirm your number.',
        );
      }
    });

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
                          isConfirmStep ? 'Confirm your number' : 'Welcome',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontSize: isMobile ? 34 : 38,
                                height: 1.1,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isConfirmStep
                              ? 'Confirm your number to register or sign in.'
                              : 'Register to play Stopwatch Challenge.',
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
                              step: loginState.step,
                              phoneValue: loginState.phoneNumber,
                              maskedPhone: loginState.maskedPhone,
                              isSubmitting: loginState.isSubmitting,
                              canContinue: loginState.canContinue,
                              canConfirm: loginState.canConfirm,
                              isReturningUser: loginState.existingUser != null,
                              errorMessage: loginState.errorMessage,
                              onPhoneChanged: loginNotifier.updatePhoneNumber,
                              onContinue: loginNotifier.continueWithPhone,
                              onConfirm: () async {
                                AppSnackBar.showInfo(
                                  context,
                                  'Signing you in…',
                                );
                                final isSuccess = await loginNotifier.signIn();
                                if (!context.mounted || !isSuccess) return;
                                final user =
                                    ref.read(loginProvider).registeredUser!;
                                AppSnackBar.showSuccess(
                                  context,
                                  'Welcome! You are ready to play.',
                                );
                                ref.read(playerMsisdnProvider.notifier).state =
                                    user.msisdn;
                                ref.read(playerUserProvider.notifier).state =
                                    user;
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const GamePage(),
                                  ),
                                );
                              },
                              onBackToPhone: loginNotifier.backToPhone,
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
