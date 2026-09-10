import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';

class LoginBrandHeader extends StatelessWidget {
  const LoginBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'ChronoPrecision',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const Spacer(),
        Semantics(
          label: AppLanguage.pick('Maelezo ya msaada', 'Help information'),
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
              tooltip: AppLanguage.pick('Msaada', 'Help'),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
