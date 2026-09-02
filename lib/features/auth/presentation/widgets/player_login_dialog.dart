import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/core/providers/player_session_provider.dart';
import 'package:stopwatch_game/core/widgets/app_logo.dart';
import 'package:stopwatch_game/core/widgets/app_snackbar.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_provider.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';
import 'package:stopwatch_game/features/auth/presentation/widgets/login_form_card.dart';

/// Opens the shared player sign-in flow and returns whether authentication
/// completed successfully.
Future<bool> showPlayerLoginDialog(
  BuildContext pageContext,
  WidgetRef pageRef,
) async {
  Future<void> finishAuth(BuildContext dialogContext) async {
    final user = pageRef.read(loginProvider).authenticatedUser;
    if (user == null || !dialogContext.mounted || !pageContext.mounted) return;

    pageRef.read(playerMsisdnProvider.notifier).state = user.msisdn;
    pageRef.read(playerUserProvider.notifier).state = user;
    pageRef.read(subscriptionActiveProvider.notifier).state = true;
    Navigator.of(dialogContext).pop(true);
  }

  final authenticated = await showDialog<bool>(
    context: pageContext,
    barrierColor: AppColors.primary.withValues(alpha: 0.58),
    builder: (dialogContext) => Consumer(
      builder: (context, ref, _) {
        final loginState = ref.watch(loginProvider);
        final loginNotifier = ref.read(loginProvider.notifier);
        final isOtpStep = loginState.step == LoginStep.otp;

        ref.listen<LoginState>(loginProvider, (previous, next) {
          if (!dialogContext.mounted) return;
          if (next.errorMessage != null &&
              next.errorMessage!.isNotEmpty &&
              next.errorMessage != previous?.errorMessage) {
            AppSnackBar.showError(dialogContext, next.errorMessage!);
          }
          if (next.infoMessage != null &&
              next.infoMessage!.isNotEmpty &&
              next.infoMessage != previous?.infoMessage &&
              next.step == LoginStep.otp) {
            AppSnackBar.showInfo(dialogContext, next.infoMessage!);
          }
        });

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
                        const AppLogo(size: 42),
                        const Spacer(),
                        IconButton(
                          onPressed: loginState.isSubmitting
                              ? null
                              : () => Navigator.of(dialogContext).pop(false),
                          tooltip: AuthCopy.closeLogin,
                          icon: const Icon(Icons.close_rounded),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isOtpStep ? AuthCopy.verifyTitle : AuthCopy.readyToPlay,
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
                          : AuthCopy.enterMobileNumber,
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
                        if (await loginNotifier.submitPhone() &&
                            dialogContext.mounted) {
                          await finishAuth(dialogContext);
                        }
                      },
                      onResendOtp: () async {
                        if (await loginNotifier.resendOtp() &&
                            dialogContext.mounted) {
                          await finishAuth(dialogContext);
                        }
                      },
                      onBackToPhone: loginNotifier.backToPhone,
                      onVerifyOtp: () async {
                        if (await loginNotifier.verifyOtp() &&
                            dialogContext.mounted) {
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

  return authenticated ?? false;
}
