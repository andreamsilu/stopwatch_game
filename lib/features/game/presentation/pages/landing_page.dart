import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/providers/auth_providers.dart';
import 'package:stopwatch_game/core/providers/player_session_provider.dart';
import 'package:stopwatch_game/features/game/presentation/pages/game_page.dart';

final landingSessionRestoreProvider = FutureProvider<void>((ref) async {
  final authService = ref.read(authServiceProvider);
  final session =
      authService.currentSession ??
      await ref.read(authSessionStorageProvider).readValidSession();
  if (session == null) return;

  authService.restoreSession(session);
  ref.read(playerMsisdnProvider.notifier).state = session.user.msisdn;
  ref.read(playerUserProvider.notifier).state = session.user;
  ref.read(subscriptionActiveProvider.notifier).state = true;
});

/// Root experience: the game board is the landing page.
class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restoration = ref.watch(landingSessionRestoreProvider);
    return restoration.when(
      data: (_) => const GamePage(),
      error: (_, _) => const GamePage(),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
