import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';

class LoginBrandHeader extends StatelessWidget {
  const LoginBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'ChronoPrecision',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 30,
            letterSpacing: 0.2,
          ),
        ),
        const Spacer(),
        Semantics(
          label: 'Help information',
          button: true,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD6DFEA)),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.help_outline_rounded, size: 20),
              color: AppColors.primary,
              tooltip: 'Help',
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
