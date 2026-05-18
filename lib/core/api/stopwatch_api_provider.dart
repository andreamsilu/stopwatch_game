import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/api/stopwatch_api.dart';

final stopwatchApiProvider = Provider<StopwatchApi>((ref) {
  final api = StopwatchApi.create();
  ref.onDispose(api.close);
  return api;
});
