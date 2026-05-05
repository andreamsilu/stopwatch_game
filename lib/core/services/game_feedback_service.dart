import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Handles lightweight, platform-safe tactile and click feedback.
///
/// Keep this service side-effect only so UI widgets can trigger consistent
/// feedback without owning platform-specific branching logic.
class GameFeedbackService {
  const GameFeedbackService._();

  static Future<void> onRoundStart() async {
    await _playClick();
    await _safeHaptic(HapticFeedback.selectionClick);
  }

  static Future<void> onRoundStop() async {
    await _playClick();
    await _safeHaptic(HapticFeedback.mediumImpact);
  }

  static Future<void> onRoundReset() async {
    await _playClick();
    await _safeHaptic(HapticFeedback.lightImpact);
  }

  static Future<void> onWin() async {
    await _playClick();
    await _safeHaptic(HapticFeedback.heavyImpact);
  }

  static Future<void> onLose() async {
    await _playClick();
    await _safeHaptic(HapticFeedback.selectionClick);
  }

  static Future<void> _playClick() async {
    if (kIsWeb) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {
      // Intentionally ignored: feedback should never block gameplay flow.
    }
  }

  static Future<void> _safeHaptic(Future<void> Function() effect) async {
    if (kIsWeb) return;
    try {
      await effect();
    } catch (_) {
      // Intentionally ignored: device/platform support can vary.
    }
  }
}
