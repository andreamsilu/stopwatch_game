import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
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
    required this.isSubmitting,
    required this.isResendingOtp,
    required this.canSubmitPhone,
    required this.canVerifyOtp,
    required this.infoMessage,
    required this.onPhoneChanged,
    required this.onOtpChanged,
    required this.onSubmitPhone,
    required this.onVerifyOtp,
    required this.onResendOtp,
    required this.onBackToPhone,
    super.key,
  });

  final LoginStep step;
  final String phoneValue;
  final String otpCode;
  final bool isSubmitting;
  final bool isResendingOtp;
  final bool canSubmitPhone;
  final bool canVerifyOtp;
  final String? infoMessage;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onOtpChanged;
  final Future<void> Function() onSubmitPhone;
  final Future<void> Function() onVerifyOtp;
  final Future<void> Function() onResendOtp;
  final VoidCallback onBackToPhone;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: step == LoginStep.phone
          ? _PhoneStep(
              key: const ValueKey('phone'),
              phoneValue: phoneValue,
              isSubmitting: isSubmitting,
              canSubmitPhone: canSubmitPhone,
              infoMessage: infoMessage,
              onPhoneChanged: onPhoneChanged,
              onSubmitPhone: onSubmitPhone,
            )
          : _OtpStep(
              key: const ValueKey('otp'),
              otpCode: otpCode,
              isSubmitting: isSubmitting,
              isResendingOtp: isResendingOtp,
              canVerifyOtp: canVerifyOtp,
              onOtpChanged: onOtpChanged,
              onVerifyOtp: onVerifyOtp,
              onResendOtp: onResendOtp,
              onBackToPhone: onBackToPhone,
            ),
    );
  }
}

class _LoginCardSpacing {
  static const padding = EdgeInsets.fromLTRB(24, 28, 24, 28);
  static const section = 24.0;
  static const block = 16.0;
  static const tight = 12.0;
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6DFEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1400377D),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: _LoginCardSpacing.padding,
        child: child,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: GameConstants.minTouchTargetSize + 4,
      width: double.infinity,
      child: FilledButton(
        onPressed: enabled && !loading ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          disabledForegroundColor: const Color(0xFF94A3B8),
          elevation: enabled ? 1 : 0,
          shadowColor: AppColors.accent.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}

class _PhoneStep extends StatelessWidget {
  const _PhoneStep({
    required this.phoneValue,
    required this.isSubmitting,
    required this.canSubmitPhone,
    required this.infoMessage,
    required this.onPhoneChanged,
    required this.onSubmitPhone,
    super.key,
  });

  final String phoneValue;
  final bool isSubmitting;
  final bool canSubmitPhone;
  final String? infoMessage;
  final ValueChanged<String> onPhoneChanged;
  final Future<void> Function() onSubmitPhone;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: phoneValue,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            enabled: !isSubmitting,
            onChanged: onPhoneChanged,
            onFieldSubmitted: canSubmitPhone ? (_) => onSubmitPhone() : null,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              letterSpacing: 0.3,
            ),
            decoration: const InputDecoration(
              labelText: AuthCopy.phoneLabel,
              prefixIcon: TanzaniaPhonePrefix(size: 24),
              hintText: AuthCopy.phoneHint,
            ),
          ),
          if (infoMessage != null && infoMessage!.isNotEmpty) ...[
            const SizedBox(height: _LoginCardSpacing.block),
            Text(
              infoMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: _LoginCardSpacing.section),
          _PrimaryButton(
            label: AuthCopy.continueButton,
            enabled: canSubmitPhone,
            loading: isSubmitting,
            onPressed: () => onSubmitPhone(),
          ),
        ],
      ),
    );
  }
}

class _OtpStep extends StatelessWidget {
  const _OtpStep({
    required this.otpCode,
    required this.isSubmitting,
    required this.isResendingOtp,
    required this.canVerifyOtp,
    required this.onOtpChanged,
    required this.onVerifyOtp,
    required this.onResendOtp,
    required this.onBackToPhone,
    super.key,
  });

  final String otpCode;
  final bool isSubmitting;
  final bool isResendingOtp;
  final bool canVerifyOtp;
  final ValueChanged<String> onOtpChanged;
  final Future<void> Function() onVerifyOtp;
  final Future<void> Function() onResendOtp;
  final VoidCallback onBackToPhone;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: isSubmitting ? null : onBackToPhone,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text(AuthCopy.changeNumber),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          const SizedBox(height: _LoginCardSpacing.tight),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: OtpInputBoxes(
              value: otpCode,
              enabled: !isSubmitting,
              onChanged: onOtpChanged,
              onCompleted: canVerifyOtp ? () => onVerifyOtp() : null,
            ),
          ),
          const SizedBox(height: _LoginCardSpacing.section + 4),
          _PrimaryButton(
            label: AuthCopy.continueButton,
            enabled: canVerifyOtp,
            loading: isSubmitting,
            onPressed: () => onVerifyOtp(),
          ),
          const SizedBox(height: _LoginCardSpacing.tight),
          Center(
            child: TextButton(
              onPressed: isSubmitting || isResendingOtp
                  ? null
                  : () => onResendOtp(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: isResendingOtp
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(AuthCopy.resendCode),
            ),
          ),
        ],
      ),
    );
  }
}
