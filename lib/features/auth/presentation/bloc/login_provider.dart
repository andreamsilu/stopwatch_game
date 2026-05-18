import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/api/stopwatch_api_provider.dart';
import 'package:stopwatch_game/features/auth/data/auth_service.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_notifier.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final api = ref.watch(stopwatchApiProvider);
  return LoginNotifier(auth: AuthService.create(api: api));
});
