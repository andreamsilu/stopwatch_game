import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/config/env_config.dart';
import 'package:stopwatch_game/core/theme/app_theme.dart';
import 'package:stopwatch_game/features/auth/presentation/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();

  if (kIsWeb) {
    BrowserContextMenu.disableContextMenu();
    HardwareKeyboard.instance.addHandler(_blockInspectionShortcuts);
  }
  runApp(const StopwatchChallengeApp());
}

bool _blockInspectionShortcuts(KeyEvent event) {
  if (!kIsWeb || event is! KeyDownEvent) return false;

  final keyboard = HardwareKeyboard.instance;
  final key = event.logicalKey;
  final ctrlOrCmd = keyboard.isControlPressed || keyboard.isMetaPressed;

  // Block devtools / source view shortcuts.
  final isDevToolsCombo =
      key == LogicalKeyboardKey.f12 ||
      (ctrlOrCmd &&
          keyboard.isShiftPressed &&
          (key == LogicalKeyboardKey.keyI ||
              key == LogicalKeyboardKey.keyJ ||
              key == LogicalKeyboardKey.keyC)) ||
      (ctrlOrCmd && key == LogicalKeyboardKey.keyU);

  // Block common navigation shortcuts (reload / close tab) while game is active.
  final isNavigationCombo = ctrlOrCmd &&
      (key == LogicalKeyboardKey.keyR || // reload
          key == LogicalKeyboardKey.keyW); // close tab

  return isDevToolsCombo || isNavigationCombo;
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
