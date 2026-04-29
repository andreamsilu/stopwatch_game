import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/widgets/experience_background.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_provider.dart';
import 'package:stopwatch_game/features/auth/presentation/widgets/login_brand_header.dart';
import 'package:stopwatch_game/features/auth/presentation/widgets/login_footer.dart';
import 'package:stopwatch_game/features/auth/presentation/widgets/login_form_card.dart';
import 'package:stopwatch_game/features/auth/presentation/widgets/secure_access_card.dart';
import 'package:stopwatch_game/features/game/presentation/pages/game_page.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);
    final loginNotifier = ref.read(loginProvider.notifier);

    return Scaffold(
      body: ExperienceBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;
              final contentWidth = isMobile ? constraints.maxWidth : 560.0;

              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: isMobile ? 16 : 14,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: contentWidth,
                      minHeight: constraints.maxHeight - (isMobile ? 32 : 28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const LoginBrandHeader(),
                        SizedBox(height: isMobile ? 28 : 56),
                        Align(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, Color(0xFF174EA3)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x2600377D),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.timer,
                              color: AppColors.accent,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome Back',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontSize: isMobile ? 34 : 38,
                                height: 1.1,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Precision is everything. Enter your details to continue.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.onBackground.withValues(alpha: 0.74),
                            fontSize: isMobile ? 15 : 17,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Align(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 430),
                            child: LoginFormCard(
                              phoneValue: loginState.phoneNumber,
                              isSubmitting: loginState.isSubmitting,
                              canContinue: loginState.canContinue,
                              onPhoneChanged: loginNotifier.updatePhoneNumber,
                              onContinue: () async {
                                final isSuccess = await loginNotifier
                                    .submitLogin();
                                if (!context.mounted || !isSuccess) return;
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const GamePage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Align(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 430),
                            child: const SecureAccessCard(),
                          ),
                        ),
                        SizedBox(height: isMobile ? 36 : 56),
                        const LoginFooter(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
