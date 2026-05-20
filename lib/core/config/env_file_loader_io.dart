import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// In debug, prefer the project-root `.env` over the bundled asset (stale after edits).
Future<void> loadEnvFromDiskIfPresent() async {
  if (!kDebugMode) return;

  try {
    final file = File('.env');
    if (!file.existsSync()) return;

    dotenv.testLoad(fileInput: await file.readAsString());
    debugPrint('[EnvConfig] Loaded .env from disk (${file.absolute.path})');
  } catch (e) {
    debugPrint('[EnvConfig] Disk .env override skipped: $e');
  }
}
