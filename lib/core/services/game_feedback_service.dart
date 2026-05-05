import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

/// Handles lightweight, platform-safe tactile and click feedback.
///
/// Keep this service side-effect only so UI widgets can trigger consistent
/// feedback without owning platform-specific branching logic.
class GameFeedbackService {
  const GameFeedbackService._();

  static final AudioPlayer _tickPlayer = AudioPlayer();
  static final AudioPlayer _fxPlayer = AudioPlayer();
  static Timer? _tickLoop;
  static bool _audioPrepared = false;
  static Uint8List? _tickWav;
  static Uint8List? _clapWav;
  static Uint8List? _sadWav;

  static Future<void> onRoundStart() async {
    await _prepareAudio();
    await _playTick();
    await _safeHaptic(HapticFeedback.selectionClick);
    _startTickLoop();
  }

  static Future<void> onRoundStop() async {
    _stopTickLoop();
    await _playTick();
    await _safeHaptic(HapticFeedback.mediumImpact);
  }

  static Future<void> onRoundReset() async {
    _stopTickLoop();
    await _playTick();
    await _safeHaptic(HapticFeedback.lightImpact);
  }

  static Future<void> onWin() async {
    _stopTickLoop();
    await _playCelebrationClaps();
    await _safeHaptic(HapticFeedback.heavyImpact);
  }

  static Future<void> onLose() async {
    _stopTickLoop();
    await _playSadCue();
    await _safeHaptic(HapticFeedback.selectionClick);
  }

  static Future<void> _prepareAudio() async {
    if (_audioPrepared) return;
    try {
      await _tickPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _fxPlayer.setPlayerMode(PlayerMode.lowLatency);
      _tickWav = _buildToneWav(
        frequencyHz: 1620,
        durationMs: 55,
        volume: 0.18,
        decay: true,
      );
      _clapWav = _buildToneWav(
        frequencyHz: 1200,
        durationMs: 180,
        volume: 0.68,
        decay: true,
        withNoise: true,
      );
      _sadWav = _buildToneWav(
        frequencyHz: 520,
        durationMs: 320,
        volume: 0.62,
        decay: true,
        withNoise: true,
      );
      _audioPrepared = true;
    } catch (_) {
      _audioPrepared = false;
    }
  }

  static Future<void> _playTick() async {
    await _prepareAudio();
    try {
      final source = _tickWav;
      if (source == null) {
        await _playClick();
        return;
      }
      await _tickPlayer.stop();
      await _tickPlayer.play(BytesSource(source));
    } catch (_) {
      await _playClick();
    }
  }

  static Future<void> _playClick() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {
      // Intentionally ignored: feedback should never block gameplay flow.
    }
  }

  static Future<void> _playAlert() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {
      // Intentionally ignored: feedback should never block gameplay flow.
    }
  }

  static void _startTickLoop() {
    _tickLoop?.cancel();
    // Keep audio rhythm aligned with the stopwatch second cadence.
    _tickLoop = Timer.periodic(const Duration(seconds: 1), (_) async {
      await _playTick();
    });
  }

  static void _stopTickLoop() {
    _tickLoop?.cancel();
    _tickLoop = null;
  }

  static Future<void> _playCelebrationClaps() async {
    await _prepareAudio();
    final source = _clapWav;
    if (source == null) {
      for (var i = 0; i < 5; i++) {
        await _playClick();
        await Future<void>.delayed(const Duration(milliseconds: 85));
      }
      return;
    }
    await _playAlert();
    for (var i = 0; i < 5; i++) {
      try {
        await _fxPlayer.stop();
        await _fxPlayer.play(BytesSource(source));
      } catch (_) {
        await _playClick();
      }
      await Future<void>.delayed(const Duration(milliseconds: 110));
    }
  }

  static Future<void> _playSadCue() async {
    await _prepareAudio();
    final source = _sadWav;
    if (source == null) {
      await _playAlert();
      await Future<void>.delayed(const Duration(milliseconds: 190));
      await _playClick();
      await Future<void>.delayed(const Duration(milliseconds: 180));
      await _playAlert();
      return;
    }
    for (var i = 0; i < 2; i++) {
      try {
        await _fxPlayer.stop();
        await _fxPlayer.play(BytesSource(source));
      } catch (_) {
        await _playAlert();
      }
      await Future<void>.delayed(const Duration(milliseconds: 240));
    }
    await _playAlert();
  }

  static Future<void> _safeHaptic(Future<void> Function() effect) async {
    if (kIsWeb) return;
    try {
      await effect();
    } catch (_) {
      // Intentionally ignored: device/platform support can vary.
    }
  }

  static Uint8List _buildToneWav({
    required double frequencyHz,
    required int durationMs,
    required double volume,
    required bool decay,
    bool withNoise = false,
  }) {
    const sampleRate = 22050;
    final sampleCount = (sampleRate * durationMs / 1000).round();
    final samples = Int16List(sampleCount);
    final random = Random(7);

    for (var i = 0; i < sampleCount; i++) {
      final t = i / sampleRate;
      final envelope = decay ? (1 - (i / sampleCount)).clamp(0.0, 1.0) : 1.0;
      var sampleValue =
          sin(2 * pi * frequencyHz * t) * envelope * volume;
      if (withNoise) {
        sampleValue += ((random.nextDouble() * 2) - 1) * 0.08 * envelope;
      }
      final clipped = (sampleValue * 32767).clamp(-32768, 32767).toInt();
      samples[i] = clipped;
    }

    final byteRate = sampleRate * 2;
    final dataLength = samples.length * 2;
    final totalLength = 44 + dataLength;
    final bytes = ByteData(totalLength);

    void writeAscii(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        bytes.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    writeAscii(0, 'RIFF');
    bytes.setUint32(4, totalLength - 8, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 1, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, byteRate, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    writeAscii(36, 'data');
    bytes.setUint32(40, dataLength, Endian.little);

    for (var i = 0; i < samples.length; i++) {
      bytes.setInt16(44 + (i * 2), samples[i], Endian.little);
    }

    return bytes.buffer.asUint8List();
  }
}
