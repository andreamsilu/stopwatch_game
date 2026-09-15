import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';
import 'package:stopwatch_game/features/auth/presentation/widgets/tanzania_phone_prefix.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
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
    return _PhoneStep(
      phoneValue: phoneValue,
      isSubmitting: isSubmitting,
      canSubmitPhone: canSubmitPhone,
      infoMessage: infoMessage,
      onPhoneChanged: onPhoneChanged,
      onSubmitPhone: onSubmitPhone,
    );
  }
}

class _LoginCardSpacing {
  static const padding = EdgeInsets.fromLTRB(26, 28, 26, 26);
  static const section = 24.0;
  static const block = 16.0;
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1EAF3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1000377D),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(padding: _LoginCardSpacing.padding, child: child),
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
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: const Color(0xFFDCE4EE),
          disabledForegroundColor: const Color(0xFF7C8DA1),
          elevation: enabled ? 1 : 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.28),
          overlayColor: AppColors.accent.withValues(alpha: 0.22),
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(letterSpacing: 0.3),
            decoration: InputDecoration(
              prefixIcon: TanzaniaPhonePrefix(size: 24),
              hintText: AuthCopy.phoneHint,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AuthCopy.phoneReassurance,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              height: 1.35,
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
