import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/api/api_messages.dart';
import 'package:stopwatch_game/core/services/interaction_telemetry_service.dart';
import 'package:stopwatch_game/features/auth/data/auth_service.dart';
import 'package:stopwatch_game/features/auth/data/models/auth_login_result.dart';
import 'package:stopwatch_game/features/auth/presentation/bloc/login_state.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier({AuthService? auth, InteractionTelemetryService? telemetry})
    : _auth = auth ?? AuthService.create(),
      _telemetry = telemetry ?? InteractionTelemetryService(enabled: false),
      super(const LoginState.initial());

  final AuthService _auth;
  final InteractionTelemetryService _telemetry;

  void updatePhoneNumber(String value) {
    state = state.copyWith(phoneNumber: value, clearError: true);
  }

  /// Clears auth form state after sign-out from the game.
  void reset() {
    state = const LoginState.initial();
  }

  /// `POST /auth/login`.
  ///
  /// Returns `true` when the user is authenticated without an OTP step.
  Future<bool> submitPhone() async {
    if (!state.canSubmitPhone) return false;

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearInfo: true,
    );
    try {
      final result = await _auth.login(msisdn: state.normalizedMsisdn);
      final authenticated = _applyLoginResult(result);
      if (authenticated) _trackLoginSuccess('direct');
      return authenticated;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('submitPhone failed: $e\n$stack');
      }
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: ApiMessages.fromError(e),
      );
      return false;
    }
  }

  bool _applyLoginResult(AuthLoginResult result) {
    switch (result) {
      case AuthLoginCompleted(:final user):
        state = state.copyWith(
          isSubmitting: false,
          authenticatedUser: user,
          infoMessage: user.status.isNotEmpty ? user.status : null,
          clearInfo: user.status.isEmpty,
        );
        return true;
      case AuthLoginMessage(:final text):
        state = state.copyWith(
          isSubmitting: false,
          infoMessage: text.isNotEmpty ? text : null,
          clearInfo: text.isEmpty,
        );
        return false;
    }
  }

  void _trackLoginSuccess(String method) {
    unawaited(
      _telemetry.track('auth.login_succeeded', properties: {'method': method}),
    );
  }
}
