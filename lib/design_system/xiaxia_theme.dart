import 'package:flutter/material.dart';
import 'xiaxia_tokens.dart';

abstract final class XiaxiaTheme {
  static ThemeData light() => _theme(Brightness.light);
  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final background = dark ? XiaxiaColors.night : XiaxiaColors.warmWhite;
    final surface = dark ? XiaxiaColors.nightRaised : XiaxiaColors.warmWhiteRaised;
    final text = dark ? XiaxiaColors.nightText : XiaxiaColors.warmCharcoal;
    final muted = dark ? XiaxiaColors.nightMuted : XiaxiaColors.mutedInk;
    final primary = dark ? XiaxiaColors.nightSage : XiaxiaColors.sageDeep;
    final hairline = dark ? XiaxiaColors.nightHairline : XiaxiaColors.hairline;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: dark ? XiaxiaColors.night : Colors.white,
      secondary: XiaxiaColors.apricot,
      onSecondary: XiaxiaColors.warmCharcoal,
      error: const Color(0xFF9A5D55),
      onError: Colors.white,
      surface: surface,
      onSurface: text,
    );

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      dividerColor: hairline,
      fontFamilyFallback: const [
        'Noto Sans CJK SC',
        'Source Han Sans SC',
        'PingFang SC',
        'sans-serif',
      ],
      textTheme: TextTheme(
        displaySmall: TextStyle(
          color: text,
          fontSize: 30,
          height: 1.25,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
          color: text,
          fontSize: 22,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: text,
          fontSize: 16,
          height: 1.45,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: text, fontSize: 16, height: 1.65),
        bodyMedium: TextStyle(color: text, fontSize: 14, height: 1.6),
        bodySmall: TextStyle(color: muted, fontSize: 12, height: 1.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 66,
        backgroundColor: surface,
        indicatorColor: dark ? const Color(0xFF3B4238) : XiaxiaColors.sagePale,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: primary),
        ),
      ),
    );
  }
}
