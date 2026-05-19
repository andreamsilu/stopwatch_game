import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/billing/round_billing_copy.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';
import 'package:stopwatch_game/features/auth/presentation/widgets/otp_input_boxes.dart';
import 'package:stopwatch_game/features/auth/presentation/widgets/tanzania_phone_prefix.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    required this.intent,
    required this.step,
    required this.phoneValue,
    required this.otpCode,
    required this.maskedPhone,
    required this.isSubmitting,
    required this.isResendingOtp,
    required this.canSendOtp,
    required this.canVerifyOtp,
    required this.subscriptionAccepted,
    required this.errorMessage,
    required this.onIntentChanged,
    required this.onPhoneChanged,
    required this.onOtpChanged,
    required this.onSubscriptionAcceptedChanged,
    required this.onSendOtp,
    required this.onVerifyOtp,
    required this.onResendOtp,
    required this.onBackToPhone,
    super.key,
  });

  final AuthIntent intent;
  final LoginStep step;
  final String phoneValue;
  final String otpCode;
  final String maskedPhone;
  final bool isSubmitting;
  final bool isResendingOtp;
  final bool canSendOtp;
  final bool canVerifyOtp;
  final bool subscriptionAccepted;
  final String? errorMessage;
  final ValueChanged<AuthIntent> onIntentChanged;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onOtpChanged;
  final ValueChanged<bool> onSubscriptionAcceptedChanged;
  final Future<void> Function() onSendOtp;
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
                intent: intent,
                phoneValue: phoneValue,
                isSubmitting: isSubmitting,
                canSendOtp: canSendOtp,
                subscriptionAccepted: subscriptionAccepted,
                errorMessage: errorMessage,
                onIntentChanged: onIntentChanged,
                onPhoneChanged: onPhoneChanged,
                onSubscriptionAcceptedChanged: onSubscriptionAcceptedChanged,
                onSendOtp: onSendOtp,
              )
            : _OtpStep(
                key: const ValueKey('otp'),
                intent: intent,
                maskedPhone: maskedPhone,
                otpCode: otpCode,
                isSubmitting: isSubmitting,
                isResendingOtp: isResendingOtp,
                canVerifyOtp: canVerifyOtp,
                errorMessage: errorMessage,
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

class _AuthIntentToggle extends StatelessWidget {
  const _AuthIntentToggle({
    required this.intent,
    required this.enabled,
    required this.onChanged,
  });

  final AuthIntent intent;
  final bool enabled;
  final ValueChanged<AuthIntent> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AuthIntent>(
      segments: const [
        ButtonSegment(
          value: AuthIntent.register,
          label: Text('Register'),
          icon: Icon(Icons.person_add_outlined, size: 18),
        ),
        ButtonSegment(
          value: AuthIntent.login,
          label: Text('Sign in'),
          icon: Icon(Icons.login_rounded, size: 18),
        ),
      ],
      selected: {intent},
      onSelectionChanged: enabled
          ? (selection) => onChanged(selection.first)
          : null,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFFB3261E),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PhoneStep extends StatelessWidget {
  const _PhoneStep({
    required this.intent,
    required this.phoneValue,
    required this.isSubmitting,
    required this.canSendOtp,
    required this.subscriptionAccepted,
    required this.errorMessage,
    required this.onIntentChanged,
    required this.onPhoneChanged,
    required this.onSubscriptionAcceptedChanged,
    required this.onSendOtp,
    super.key,
  });

  final AuthIntent intent;
  final String phoneValue;
  final bool isSubmitting;
  final bool canSendOtp;
  final bool subscriptionAccepted;
  final String? errorMessage;
  final ValueChanged<AuthIntent> onIntentChanged;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<bool> onSubscriptionAcceptedChanged;
  final Future<void> Function() onSendOtp;

  bool get _isRegister => intent == AuthIntent.register;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AuthIntentToggle(
            intent: intent,
            enabled: !isSubmitting,
            onChanged: onIntentChanged,
          ),
          const SizedBox(height: 20),
          Text(
            _isRegister ? 'Create your account' : 'Sign in',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isRegister
                ? 'Enter your phone number. We will send a 6-digit verification code.'
                : 'Enter the phone number linked to your account.',
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
                prefixIcon: TanzaniaPhonePrefix(size: 24),
                hintText: '712 345 678',
              ),
            ),
          ),
          if (_isRegister) ...[
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
          ],
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
                  : const Icon(Icons.sms_outlined),
              label: const Text('Send verification code'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpStep extends StatelessWidget {
  const _OtpStep({
    required this.intent,
    required this.maskedPhone,
    required this.otpCode,
    required this.isSubmitting,
    required this.isResendingOtp,
    required this.canVerifyOtp,
    required this.errorMessage,
    required this.onOtpChanged,
    required this.onVerifyOtp,
    required this.onResendOtp,
    required this.onBackToPhone,
    super.key,
  });

  final AuthIntent intent;
  final String maskedPhone;
  final String otpCode;
  final bool isSubmitting;
  final bool isResendingOtp;
  final bool canVerifyOtp;
  final String? errorMessage;
  final ValueChanged<String> onOtpChanged;
  final Future<void> Function() onVerifyOtp;
  final Future<void> Function() onResendOtp;
  final VoidCallback onBackToPhone;

  bool get _isRegister => intent == AuthIntent.register;

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
              label: const Text('Back'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter verification code',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'We sent a 6-digit code to $maskedPhone',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onBackground.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 24),
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
                  : Icon(_isRegister ? Icons.verified_outlined : Icons.login_rounded),
              label: Text(_isRegister ? 'Verify & register' : 'Verify & sign in'),
            ),
          ),
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
      ),
    );
  }
}
