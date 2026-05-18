import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';
import 'package:stopwatch_game/features/auth/presentation/widgets/otp_input_boxes.dart';
import 'package:stopwatch_game/features/auth/presentation/widgets/tanzania_phone_prefix.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    required this.step,
    required this.phoneValue,
    required this.otpCode,
    required this.maskedPhone,
    required this.isSubmitting,
    required this.isResendingOtp,
    required this.canSendOtp,
    required this.canVerifyOtp,
    required this.canConfirmRegistration,
    required this.requiresOtp,
    required this.isReturningUser,
    required this.errorMessage,
    required this.onPhoneChanged,
    required this.onOtpChanged,
    required this.onSendOtp,
    required this.onVerifyOtp,
    required this.onResendOtp,
    required this.onBackToDetails,
    super.key,
  });

  final LoginStep step;
  final String phoneValue;
  final String otpCode;
  final String maskedPhone;
  final bool isSubmitting;
  final bool isResendingOtp;
  final bool canSendOtp;
  final bool canVerifyOtp;
  final bool canConfirmRegistration;
  final bool requiresOtp;
  final bool isReturningUser;
  final String? errorMessage;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onOtpChanged;
  final Future<void> Function() onSendOtp;
  final Future<void> Function() onVerifyOtp;
  final Future<void> Function() onResendOtp;
  final VoidCallback onBackToDetails;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.98, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: step == LoginStep.details
            ? _DetailsStep(
                key: const ValueKey('details'),
                phoneValue: phoneValue,
                isSubmitting: isSubmitting,
                canSendOtp: canSendOtp,
                requiresOtp: requiresOtp,
                errorMessage: errorMessage,
                onPhoneChanged: onPhoneChanged,
                onSendOtp: onSendOtp,
              )
            : _OtpStep(
                key: const ValueKey('otp'),
                maskedPhone: maskedPhone,
                otpCode: otpCode,
                isSubmitting: isSubmitting,
                isResendingOtp: isResendingOtp,
                canVerifyOtp: canVerifyOtp,
                canConfirmRegistration: canConfirmRegistration,
                requiresOtp: requiresOtp,
                isReturningUser: isReturningUser,
                errorMessage: errorMessage,
                onOtpChanged: onOtpChanged,
                onVerifyOtp: onVerifyOtp,
                onResendOtp: onResendOtp,
                onBackToDetails: onBackToDetails,
              ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6DFEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFFB91C1C),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    required this.phoneValue,
    required this.isSubmitting,
    required this.canSendOtp,
    required this.requiresOtp,
    required this.errorMessage,
    required this.onPhoneChanged,
    required this.onSendOtp,
    super.key,
  });

  final String phoneValue;
  final bool isSubmitting;
  final bool canSendOtp;
  final bool requiresOtp;
  final String? errorMessage;
  final ValueChanged<String> onPhoneChanged;
  final Future<void> Function() onSendOtp;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create your account',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            requiresOtp
                ? 'Enter your phone number. We will send a 6-digit verification code.'
                : 'Enter your phone number to register or sign in.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onBackground.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Phone number',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: 'Phone number input',
            textField: true,
            child: TextFormField(
              initialValue: phoneValue,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              enabled: !isSubmitting,
              onChanged: onPhoneChanged,
              decoration: const InputDecoration(
                prefixIcon: TanzaniaPhonePrefix(style: 'flat', size: 24),
                hintText: '712 345 678',
              ),
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            _ErrorBanner(message: errorMessage!),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: GameConstants.minTouchTargetSize + 6,
            child: ElevatedButton.icon(
              onPressed: canSendOtp
                  ? () async {
                      await onSendOtp();
                    }
                  : null,
              iconAlignment: IconAlignment.end,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                elevation: canSendOtp ? 2 : 0,
              ),
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(requiresOtp ? Icons.sms_outlined : Icons.arrow_forward_rounded),
              label: Text(requiresOtp ? 'Send verification code' : 'Continue'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'By continuing, you agree to our Terms of Service and Privacy Policy.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onBackground.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpStep extends StatelessWidget {
  const _OtpStep({
    required this.maskedPhone,
    required this.otpCode,
    required this.isSubmitting,
    required this.isResendingOtp,
    required this.canVerifyOtp,
    required this.canConfirmRegistration,
    required this.requiresOtp,
    required this.isReturningUser,
    required this.errorMessage,
    required this.onOtpChanged,
    required this.onVerifyOtp,
    required this.onResendOtp,
    required this.onBackToDetails,
    super.key,
  });

  final String maskedPhone;
  final String otpCode;
  final bool isSubmitting;
  final bool isResendingOtp;
  final bool canVerifyOtp;
  final bool canConfirmRegistration;
  final bool requiresOtp;
  final bool isReturningUser;
  final String? errorMessage;
  final ValueChanged<String> onOtpChanged;
  final Future<void> Function() onVerifyOtp;
  final Future<void> Function() onResendOtp;
  final VoidCallback onBackToDetails;

  bool get _canSubmit =>
      requiresOtp ? canVerifyOtp : canConfirmRegistration;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: isSubmitting ? null : onBackToDetails,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            requiresOtp ? 'Enter verification code' : 'Confirm your number',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            requiresOtp
                ? 'We sent a 6-digit code to $maskedPhone'
                : isReturningUser
                ? 'Welcome back! Confirm to continue with $maskedPhone.'
                : 'Register with $maskedPhone to play.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onBackground.withValues(alpha: 0.72),
            ),
          ),
          if (requiresOtp) ...[
            const SizedBox(height: 24),
            OtpInputBoxes(
              value: otpCode,
              enabled: !isSubmitting,
              onChanged: onOtpChanged,
              onCompleted: _canSubmit
                  ? () async {
                      await onVerifyOtp();
                    }
                  : null,
            ),
          ] else
            const SizedBox(height: 28),
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            _ErrorBanner(message: errorMessage!),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: GameConstants.minTouchTargetSize + 6,
            child: ElevatedButton.icon(
              onPressed: _canSubmit
                  ? () async {
                      await onVerifyOtp();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                elevation: _canSubmit ? 2 : 0,
              ),
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.verified_outlined),
              label: Text(requiresOtp ? 'Verify & continue' : 'Continue'),
            ),
          ),
          if (requiresOtp) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: isSubmitting || isResendingOtp
                    ? null
                    : () async {
                        await onResendOtp();
                      },
                child: isResendingOtp
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Resend code'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
