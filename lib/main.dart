import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/theme/app_theme.dart';
import 'package:stopwatch_game/features/auth/presentation/pages/login_page.dart';

void main() {
  if (kIsWeb) {
    BrowserContextMenu.disableContextMenu();
  }
  runApp(const StopwatchChallengeRoot());
}

class StopwatchChallengeRoot extends StatefulWidget {
  const StopwatchChallengeRoot({super.key});

  @override
  State<StopwatchChallengeRoot> createState() => _StopwatchChallengeRootState();
}

class _StopwatchChallengeRootState extends State<StopwatchChallengeRoot> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      HardwareKeyboard.instance.addHandler(_blockInspectionShortcuts);
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      HardwareKeyboard.instance.removeHandler(_blockInspectionShortcuts);
    }
    super.dispose();
  }

  bool _blockInspectionShortcuts(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final keyboard = HardwareKeyboard.instance;
    final key = event.logicalKey;
    final ctrlOrCmd = keyboard.isControlPressed || keyboard.isMetaPressed;

    final isBlockedCombo = key == LogicalKeyboardKey.f12 ||
        (ctrlOrCmd &&
            keyboard.isShiftPressed &&
            (key == LogicalKeyboardKey.keyI ||
                key == LogicalKeyboardKey.keyJ ||
                key == LogicalKeyboardKey.keyC)) ||
        (ctrlOrCmd && key == LogicalKeyboardKey.keyU);

    return isBlockedCombo;
  }

  @override
  Widget build(BuildContext context) {
    return const StopwatchChallengeApp();
  }
}

class StopwatchChallengeApp extends StatelessWidget {
  const StopwatchChallengeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Stopwatch Challenge',
        theme: AppTheme.lightTheme,
        home: const LoginPage(),
      ),
    );
  }
}
