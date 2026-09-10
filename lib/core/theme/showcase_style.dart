import 'package:flutter/material.dart';

/// Logical-pixel equivalents of the Next.js showcase CSS tokens.
class ShowcaseStyle {
  ShowcaseStyle(BuildContext context) : size = MediaQuery.sizeOf(context);
  final Size size;
  double get vmin => size.shortestSide;
  bool get large => size.width >= 1280 && size.height >= 720;
  bool get tv => size.width >= 1920 && size.height >= 900;
  bool get wideTv => size.width >= 2560 && size.height >= 1080;
  double get gap => large
      ? (size.height * .0175).clamp(12.0, 20.0)
      : (size.height * .012).clamp(8.0, 16.0);
  double get title => wideTv
      ? (vmin * .04).clamp(40.0, 64.0)
      : large
      ? (vmin * .045).clamp(32.0, 56.0)
      : (size.width * .04).clamp(24.0, 36.0);
  double get label => wideTv
      ? (vmin * .018).clamp(18.0, 28.0)
      : large
      ? (vmin * .02).clamp(16.0, 24.0)
      : (size.height * .016).clamp(12.0, 15.0);
  double get target => tv
      ? (vmin * .09).clamp(56.0, 104.0)
      : large
      ? (vmin * .08).clamp(48.0, 88.0)
      : (size.height * .07).clamp(32.0, 52.0);
  double get buttonText => wideTv
      ? (vmin * .035).clamp(30.0, 48.0)
      : tv
      ? (vmin * .032).clamp(26.0, 44.0)
      : large
      ? (vmin * .028).clamp(22.0, 36.0)
      : (size.height * .02).clamp(15.0, 18.0);
  double get buttonHeight => wideTv
      ? (vmin * .12).clamp(96.0, 160.0)
      : tv
      ? (vmin * .11).clamp(88.0, 144.0)
      : large
      ? (vmin * .095).clamp(76.0, 120.0)
      : size.width >= 640
      ? (size.height * .065).clamp(48.0, 64.0)
      : (size.height * .07).clamp(44.0, 60.0);
  double get radius => (vmin * .015).clamp(14.0, 20.0);
  double get contentWidth => size.width >= 2560
      ? 1024
      : size.width >= 1920
      ? 896
      : large
      ? 768
      : size.width >= 1024
      ? 608
      : size.width >= 768
      ? 544
      : size.width >= 640
      ? 480
      : 384;
  TextStyle get actionStyle => TextStyle(
    fontSize: buttonText,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: buttonText * .06,
  );
}
