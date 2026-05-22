import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';

/// Brand mark from [images/logo.png].
class AppLogo extends StatelessWidget {
  const AppLogo({
    this.size = 64,
    super.key,
  });

  static const assetPath = 'images/logo.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: GameCopy.appName,
      image: true,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
