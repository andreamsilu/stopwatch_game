import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/theme/app_theme.dart';
import 'package:stopwatch_game/features/auth/presentation/pages/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    BrowserContextMenu.disableContextMenu();
  }
  runApp(const StopwatchChallengeApp());
}

class StopwatchChallengeApp extends StatelessWidget {
  const StopwatchChallengeApp({super.key});

  KeyEventResult _handleWebShortcutBlock(FocusNode node, KeyEvent event) {
    if (!kIsWeb || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

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

    return isBlockedCombo ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Stopwatch Challenge',
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          return Focus(
            onKeyEvent: _handleWebShortcutBlock,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onSecondaryTapDown: kIsWeb ? (_) {} : null,
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
        home: const LoginPage(),
      ),
    );
  }
}
