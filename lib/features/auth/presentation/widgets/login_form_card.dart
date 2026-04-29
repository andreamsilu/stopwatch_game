import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/constants/game_constants.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    required this.phoneValue,
    required this.isSubmitting,
    required this.canContinue,
    required this.onPhoneChanged,
    required this.onContinue,
    super.key,
  });

  final String phoneValue;
  final bool isSubmitting;
  final bool canContinue;
  final ValueChanged<String> onPhoneChanged;
  final Future<void> Function() onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'PHONE NUMBER',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            Semantics(
              label: 'Phone number input',
              textField: true,
              child: TextFormField(
                initialValue: phoneValue,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                enabled: !isSubmitting,
                onChanged: onPhoneChanged,
                decoration: InputDecoration(
                  prefixIcon: SizedBox(
                    width: 90,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(width: 10),
                        Icon(Icons.flag, size: 14),
                        SizedBox(width: 6),
                        Text('+1'),
                        SizedBox(width: 2),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                      ],
                    ),
                  ),
                  hintText: '555 000 0000',
                  filled: true,
                  fillColor: AppColors.secondary.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: GameConstants.minTouchTargetSize + 6,
              child: Semantics(
                label: 'Continue with phone number',
                button: true,
                enabled: canContinue,
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
                    textStyle: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
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
            ),
            const SizedBox(height: 20),
            Divider(color: const Color(0xFFE5E7EB), height: 1),
            const SizedBox(height: 14),
            Text(
              'By continuing, you agree to our Terms of Service and Privacy Policy.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onBackground.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
