import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Original Yas vector logo shared with the Next.js stopwatch.
class AppLogo extends StatelessWidget {
  const AppLogo({
    this.size = 64,
    super.key,
  });

  static const assetPath = 'assets/brand/yas-logo.svg';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Yas',
      image: true,
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    );
  }
}
