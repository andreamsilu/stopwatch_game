import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/billing/round_billing_copy.dart';
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
    required this.canSubmitPhone,
    required this.canVerifyOtp,
    required this.subscriptionAccepted,
    required this.errorMessage,
    required this.infoMessage,
    required this.otpExpiryLabel,
    required this.onPhoneChanged,
    required this.onOtpChanged,
    required this.onSubscriptionAcceptedChanged,
    required this.onSubmitPhone,
    required this.onVerifyOtp,
    required this.onResendOtp,
    required this.onBackToPhone,
    super.key,
  });

  final LoginStep step;
  final String phoneValue;
  final String otpCode;
  final String maskedPhone;
  final bool isSubmitting;
  final bool isResendingOtp;
  final bool canSubmitPhone;
  final bool canVerifyOtp;
  final bool subscriptionAccepted;
  final String? errorMessage;
  final String? infoMessage;
  final String? otpExpiryLabel;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onOtpChanged;
  final ValueChanged<bool> onSubscriptionAcceptedChanged;
  final Future<void> Function() onSubmitPhone;
  final Future<void> Function() onVerifyOtp;
  final Future<void> Function() onResendOtp;
  final VoidCallback onBackToPhone;

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
        child: step == LoginStep.phone
            ? _PhoneStep(
                key: const ValueKey('phone'),
                phoneValue: phoneValue,
                isSubmitting: isSubmitting,
                canSubmitPhone: canSubmitPhone,
                subscriptionAccepted: subscriptionAccepted,
                errorMessage: errorMessage,
                infoMessage: infoMessage,
                onPhoneChanged: onPhoneChanged,
                onSubscriptionAcceptedChanged: onSubscriptionAcceptedChanged,
                onSubmitPhone: onSubmitPhone,
              )
            : _OtpStep(
                key: const ValueKey('otp'),
                maskedPhone: maskedPhone,
                otpCode: otpCode,
                isSubmitting: isSubmitting,
                isResendingOtp: isResendingOtp,
                canVerifyOtp: canVerifyOtp,
                errorMessage: errorMessage,
                infoMessage: infoMessage,
                otpExpiryLabel: otpExpiryLabel,
                onOtpChanged: onOtpChanged,
                onVerifyOtp: onVerifyOtp,
                onResendOtp: onResendOtp,
                onBackToPhone: onBackToPhone,
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
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: child,
      ),
    );
  }
}

class _AuthStepIndicator extends StatelessWidget {
  const _AuthStepIndicator({required this.step});

  final LoginStep step;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    );

    return Row(
      children: [
        _StepDot(
          label: '1',
          title: 'Phone',
          active: step == LoginStep.phone,
          completed: step == LoginStep.otp,
        ),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              color: step == LoginStep.otp
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
        ),
        _StepDot(
          label: '2',
          title: 'Code',
          active: step == LoginStep.otp,
          completed: false,
        ),
        const SizedBox(width: 4),
        Text(
          step == LoginStep.phone ? 'Phone number' : 'Verification',
          style: labelStyle?.copyWith(
            color: AppColors.primary.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.label,
    required this.title,
    required this.active,
    required this.completed,
  });

  final String label;
  final String title;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final fill = completed || active ? AppColors.primary : AppColors.background;
    final border = completed || active
        ? AppColors.primary
        : AppColors.primary.withValues(alpha: 0.35);
    final textColor = completed || active
        ? AppColors.onPrimary
        : AppColors.primary.withValues(alpha: 0.7);

    return Semantics(
      label: '$title step',
      selected: active,
      child: Tooltip(
        message: title,
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 1.5),
          ),
          child: completed
              ? Icon(Icons.check_rounded, size: 16, color: textColor)
              : Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _MessageBanner(
      message: message,
      icon: Icons.error_outline_rounded,
      backgroundColor: const Color(0xFFFFEBEE),
      borderColor: const Color(0xFFEF9A9A),
      textColor: const Color(0xFFB3261E),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _MessageBanner(
      message: message,
      icon: Icons.info_outline_rounded,
      backgroundColor: const Color(0xFFE8F4FD),
      borderColor: const Color(0xFF90CAF9),
      textColor: const Color(0xFF0D47A1),
    );
  }
}

class _PhoneStep extends StatelessWidget {
  const _PhoneStep({
    required this.phoneValue,
    required this.isSubmitting,
    required this.canSubmitPhone,
    required this.subscriptionAccepted,
    required this.errorMessage,
    required this.infoMessage,
    required this.onPhoneChanged,
    required this.onSubscriptionAcceptedChanged,
    required this.onSubmitPhone,
    super.key,
  });

  final String phoneValue;
  final bool isSubmitting;
  final bool canSubmitPhone;
  final bool subscriptionAccepted;
  final String? errorMessage;
  final String? infoMessage;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<bool> onSubscriptionAcceptedChanged;
  final Future<void> Function() onSubmitPhone;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _AuthStepIndicator(step: LoginStep.phone),
          const SizedBox(height: 20),
          Text(
            'Log in',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter your Tanzanian mobile number and tap Continue. '
            'We will send a verification code only if required.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onBackground.withValues(alpha: 0.72),
              height: 1.4,
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
              onFieldSubmitted: canSubmitPhone
                  ? (_) {
                      onSubmitPhone();
                    }
                  : null,
              decoration: const InputDecoration(
                prefixIcon: TanzaniaPhonePrefix(size: 24),
                hintText: '712 345 678',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            RoundBillingCopy.entryFeeLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: subscriptionAccepted,
            onChanged: isSubmitting
                ? null
                : (value) => onSubscriptionAcceptedChanged(value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              RoundBillingCopy.subscriptionConsent,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.4,
              ),
            ),
          ),
          if (infoMessage != null && infoMessage!.isNotEmpty) ...[
            const SizedBox(height: 14),
            _InfoBanner(message: infoMessage!),
          ],
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            _ErrorBanner(message: errorMessage!),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: GameConstants.minTouchTargetSize + 6,
            child: ElevatedButton.icon(
              onPressed: canSubmitPhone
                  ? () async {
                      await onSubmitPhone();
                    }
                  : null,
              iconAlignment: IconAlignment.end,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                elevation: canSubmitPhone ? 2 : 0,
              ),
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward_rounded),
              label: const Text('Continue'),
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
    required this.errorMessage,
    required this.infoMessage,
    required this.otpExpiryLabel,
    required this.onOtpChanged,
    required this.onVerifyOtp,
    required this.onResendOtp,
    required this.onBackToPhone,
    super.key,
  });

  final String maskedPhone;
  final String otpCode;
  final bool isSubmitting;
  final bool isResendingOtp;
  final bool canVerifyOtp;
  final String? errorMessage;
  final String? infoMessage;
  final String? otpExpiryLabel;
  final ValueChanged<String> onOtpChanged;
  final Future<void> Function() onVerifyOtp;
  final Future<void> Function() onResendOtp;
  final VoidCallback onBackToPhone;

  @override
  Widget build(BuildContext context) {
    final otpHint = infoMessage?.trim().isNotEmpty == true
        ? infoMessage!
        : 'A 6-digit code was sent to $maskedPhone';

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _AuthStepIndicator(step: LoginStep.otp),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: isSubmitting ? null : onBackToPhone,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Change number'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter verification code',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          _InfoBanner(message: otpHint),
          if (otpExpiryLabel != null) ...[
            const SizedBox(height: 8),
            Text(
              otpExpiryLabel!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onBackground.withValues(alpha: 0.65),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 22),
          OtpInputBoxes(
            value: otpCode,
            enabled: !isSubmitting,
            onChanged: onOtpChanged,
            onCompleted: canVerifyOtp
                ? () {
                    onVerifyOtp();
                  }
                : null,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            _ErrorBanner(message: errorMessage!),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: GameConstants.minTouchTargetSize + 6,
            child: ElevatedButton.icon(
              onPressed: canVerifyOtp
                  ? () async {
                      await onVerifyOtp();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                elevation: canVerifyOtp ? 2 : 0,
              ),
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login_rounded),
              label: const Text('Verify & continue'),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: isSubmitting || isResendingOtp
                  ? null
                  : () async {
                      await onResendOtp();
                    },
              icon: isResendingOtp
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded, size: 18),
              label: Text(isResendingOtp ? 'Sending…' : 'Resend code'),
            ),
          ),
        ],
      ),
    );
  }
}
