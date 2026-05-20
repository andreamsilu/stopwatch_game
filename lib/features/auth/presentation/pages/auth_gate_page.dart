import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/providers/auth_providers.dart';
import 'package:stopwatch_game/core/providers/player_session_provider.dart';
import 'package:stopwatch_game/features/auth/presentation/pages/login_page.dart';
import 'package:stopwatch_game/features/game/presentation/pages/game_page.dart';

/// Restores a persisted JWT session or shows [LoginPage].
class AuthGatePage extends ConsumerStatefulWidget {
  const AuthGatePage({super.key});

  @override
  ConsumerState<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends ConsumerState<AuthGatePage> {
  bool _checking = true;
  bool _hasSession = false;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final session = await ref.read(authSessionStorageProvider).readValidSession();
    if (!mounted) return;

    if (session != null) {
      ref.read(authServiceProvider).restoreSession(session);
      ref.read(playerMsisdnProvider.notifier).state = session.user.msisdn;
      ref.read(playerUserProvider.notifier).state = session.user;
      ref.read(subscriptionActiveProvider.notifier).state = true;
    }

    setState(() {
      _checking = false;
      _hasSession = session != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return _hasSession ? const GamePage() : const LoginPage();
  }
}
