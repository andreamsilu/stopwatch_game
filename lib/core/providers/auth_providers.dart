import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/api/stopwatch_api.dart';
import 'package:stopwatch_game/core/auth/auth_session_storage.dart';
import 'package:stopwatch_game/core/auth/auth_token_store.dart';
import 'package:stopwatch_game/features/auth/data/auth_service.dart';

final authSessionStorageProvider = Provider<AuthSessionStorage>((ref) {
  return AuthSessionStorage();
});

final authTokenStoreProvider = Provider<AuthTokenStore>((ref) {
  return AuthTokenStore();
});

final accessTokenProvider = StateProvider<String?>((ref) => null);

final stopwatchApiProvider = Provider<StopwatchApi>((ref) {
  final tokenStore = ref.watch(authTokenStoreProvider);
  final api = StopwatchApi(
    accessTokenProvider: () => tokenStore.accessToken,
  );
  ref.onDispose(api.close);
  return api;
});

final authServiceProvider = Provider<AuthService>((ref) {
  final tokenStore = ref.watch(authTokenStoreProvider);
  final storage = ref.watch(authSessionStorageProvider);
  return AuthService(
    api: ref.watch(stopwatchApiProvider),
    onSessionChanged: (session) {
      final token = session?.accessToken;
      tokenStore.setAccessToken(token);
      ref.read(accessTokenProvider.notifier).state = token;
      if (session == null) {
        unawaited(storage.clear());
      } else {
        unawaited(storage.save(session));
      }
    },
  );
});
