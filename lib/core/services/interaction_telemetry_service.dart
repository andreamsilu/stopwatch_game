import 'package:flutter/foundation.dart';
import 'package:stopwatch_game/core/api/stopwatch_api.dart';
import 'package:stopwatch_game/core/config/api_config.dart';
import 'package:stopwatch_game/core/config/env_config.dart';
import 'package:uuid/uuid.dart';

/// Sends privacy-safe product and game-integrity events to the backend.
///
/// Telemetry is best-effort: failures never interrupt authentication, billing,
/// or gameplay. The backend must derive the user identity from the JWT rather
/// than accepting an MSISDN or user id supplied by the client.
class InteractionTelemetryService {
  InteractionTelemetryService({StopwatchApi? api, bool? enabled})
    : _api = api ?? StopwatchApi.create(),
      _enabled = enabled ?? EnvConfig.telemetryEnabled;

  factory InteractionTelemetryService.create({StopwatchApi? api}) =>
      InteractionTelemetryService(api: api);

  static const _uuid = Uuid();
  static final _eventNamePattern = RegExp(r'^[a-z][a-z0-9_.-]{2,79}$');
  static const _sensitiveKeys = {
    'accesstoken',
    'authorization',
    'hmacsecret',
    'msisdn',
    'otp',
    'password',
    'secret',
    'signature',
    'token',
  };

  final StopwatchApi _api;
  final bool _enabled;

  Future<void> track(
    String eventName, {
    Map<String, dynamic> properties = const {},
  }) async {
    if (!_enabled) return;
    if (!_eventNamePattern.hasMatch(eventName)) {
      if (kDebugMode) {
        debugPrint('[Telemetry] Invalid event name ignored: $eventName');
      }
      return;
    }

    final event = <String, dynamic>{
      'eventId': _uuid.v4(),
      'eventName': eventName,
      'eventVersion': 1,
      'occurredAt': DateTime.now().toUtc().toIso8601String(),
      'channel': EnvConfig.gameChannel,
      'properties': sanitizeProperties(properties),
    };

    try {
      await _api.post(Uri.parse(ApiConfig.telemetryEvents), body: event);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[Telemetry] $eventName delivery failed: $error');
      }
    }
  }

  Future<void> submitRoundPayload(Map<String, dynamic> payload) =>
      track('game.interaction', properties: payload);

  @visibleForTesting
  static Map<String, dynamic> sanitizeProperties(
    Map<String, dynamic> properties,
  ) {
    return {
      for (final entry in properties.entries)
        if (!_sensitiveKeys.contains(_normalizeKey(entry.key)))
          entry.key: _sanitizeValue(entry.value),
    };
  }

  static Object? _sanitizeValue(Object? value) {
    if (value == null || value is bool || value is num || value is String) {
      return value;
    }
    if (value is DateTime) return value.toUtc().toIso8601String();
    if (value is Map) {
      return sanitizeProperties(
        value.map((key, item) => MapEntry(key.toString(), item)),
      );
    }
    if (value is Iterable) {
      return value.map(_sanitizeValue).toList(growable: false);
    }
    return value.toString();
  }

  static String _normalizeKey(String key) =>
      key.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
}
