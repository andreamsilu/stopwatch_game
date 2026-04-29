import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_notifier.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier();
});
