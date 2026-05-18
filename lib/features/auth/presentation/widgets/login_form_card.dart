import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';
import 'package:stopwatch_game/features/auth/presentation/widgets/tanzania_phone_prefix.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    required this.step,
    required this.phoneValue,
    required this.maskedPhone,
    required this.isSubmitting,
    required this.canContinue,
    required this.canConfirm,
    required this.isReturningUser,
    required this.errorMessage,
    required this.onPhoneChanged,
    required this.onContinue,
    required this.onConfirm,
    required this.onBackToPhone,
    super.key,
  });

  final LoginStep step;
  final String phoneValue;
  final String maskedPhone;
  final bool isSubmitting;
  final bool canContinue;
  final bool canConfirm;
  final bool isReturningUser;
  final String? errorMessage;
  final ValueChanged<String> onPhoneChanged;
  final Future<void> Function() onContinue;
  final Future<void> Function() onConfirm;
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
                canContinue: canContinue,
                errorMessage: errorMessage,
                onPhoneChanged: onPhoneChanged,
                onContinue: onContinue,
              )
            : _ConfirmStep(
                key: const ValueKey('confirm'),
                maskedPhone: maskedPhone,
                isSubmitting: isSubmitting,
                canConfirm: canConfirm,
                isReturningUser: isReturningUser,
                errorMessage: errorMessage,
                onConfirm: onConfirm,
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
    required this.phoneValue,
    required this.isSubmitting,
    required this.canContinue,
    required this.errorMessage,
    required this.onPhoneChanged,
    required this.onContinue,
    super.key,
  });

  final String phoneValue;
  final bool isSubmitting;
  final bool canContinue;
  final String? errorMessage;
  final ValueChanged<String> onPhoneChanged;
  final Future<void> Function() onContinue;

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
            'Enter your phone number to register or sign in.',
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
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            _ErrorBanner(message: errorMessage!),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: GameConstants.minTouchTargetSize + 6,
            child: ElevatedButton.icon(
              onPressed: canContinue
                  ? () async {
                      await onContinue();
                    }
                  : null,
              iconAlignment: IconAlignment.end,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                elevation: canContinue ? 2 : 0,
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

class _ConfirmStep extends StatelessWidget {
  const _ConfirmStep({
    required this.maskedPhone,
    required this.isSubmitting,
    required this.canConfirm,
    required this.isReturningUser,
    required this.errorMessage,
    required this.onConfirm,
    required this.onBackToPhone,
    super.key,
  });

  final String maskedPhone;
  final bool isSubmitting;
  final bool canConfirm;
  final bool isReturningUser;
  final String? errorMessage;
  final Future<void> Function() onConfirm;
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
              label: const Text('Back'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Confirm your number',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isReturningUser
                ? 'Welcome back! Confirm to continue with $maskedPhone.'
                : 'Register with $maskedPhone to play.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onBackground.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 28),
          if (errorMessage != null) ...[
            _ErrorBanner(message: errorMessage!),
            const SizedBox(height: 20),
          ],
          SizedBox(
            height: GameConstants.minTouchTargetSize + 6,
            child: ElevatedButton.icon(
              onPressed: canConfirm
                  ? () async {
                      await onConfirm();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                elevation: canConfirm ? 2 : 0,
              ),
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.verified_outlined),
              label: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
