import 'package:flutter/material.dart';

abstract final class XiaxiaColors {
  static const warmWhite = Color(0xFFF6F3EE);
  static const warmWhiteRaised = Color(0xFFFCFAF6);
  static const warmCharcoal = Color(0xFF2C2D29);
  static const mutedInk = Color(0xFF6B6B63);
  static const sage = Color(0xFF9DA68C);
  static const sageDeep = Color(0xFF69745E);
  static const sagePale = Color(0xFFE3E6DB);
  static const apricot = Color(0xFFE3BE99);
  static const clayPink = Color(0xFFD8B1A5);
  static const hairline = Color(0xFFE2DDD4);

  static const night = Color(0xFF20221F);
  static const nightRaised = Color(0xFF2A2D29);
  static const nightSage = Color(0xFF82907A);
  static const nightText = Color(0xFFF1EEE7);
  static const nightMuted = Color(0xFFB5B7AE);
  static const nightHairline = Color(0xFF3A3E38);
}

abstract final class XiaxiaSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class XiaxiaMotion {
  static const short = Duration(milliseconds: 160);
  static const gentle = Duration(milliseconds: 320);
}
