import 'package:flutter/material.dart';

/// Colors from the Fat Fish style guide (same as the PWA).
abstract final class FatFishColors {
  static const background = Color(0xFF0B1416);
  static const card = Color(0xFF172A25);
  static const felt = Color(0xFF105030);
  static const feltDark = Color(0xFF0D3522);
  static const line = Color(0xFF24493A);
  static const gold = Color(0xFFE8B850);
  static const cream = Color(0xFFF2E8CC);
  static const fog = Color(0xFF9AA8A2);
  static const ruby = Color(0xFFF08A7E);
  static const win = Color(0xFF6FD39A);
}

/// Font families declared in pubspec.yaml (files in assets/fonts).
abstract final class FatFishFonts {
  /// Titles and big numbers.
  static const display = 'Jersey10';

  /// Short pixel labels; hard to read in long text.
  static const label = 'PressStart2P';

  /// Body text.
  static const body = 'Geist';
}

ThemeData buildFatFishTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: FatFishColors.felt,
        brightness: Brightness.dark,
      ).copyWith(
        primary: FatFishColors.felt,
        onPrimary: FatFishColors.cream,
        secondary: FatFishColors.gold,
        surface: FatFishColors.background,
        onSurface: FatFishColors.cream,
        error: FatFishColors.ruby,
        outline: FatFishColors.line,
      );

  final base = ThemeData(
    colorScheme: scheme,
    fontFamily: FatFishFonts.body,
  ).textTheme;

  TextStyle? display(TextStyle? style) =>
      style?.copyWith(fontFamily: FatFishFonts.display);

  final textTheme = base.copyWith(
    displayLarge: display(base.displayLarge),
    displayMedium: display(base.displayMedium),
    displaySmall: display(base.displaySmall),
    headlineLarge: display(base.headlineLarge),
    headlineMedium: display(base.headlineMedium),
    headlineSmall: display(base.headlineSmall),
    titleLarge: display(base.titleLarge),
  );

  return ThemeData(
    colorScheme: scheme,
    fontFamily: FatFishFonts.body,
    textTheme: textTheme,
    scaffoldBackgroundColor: FatFishColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: FatFishColors.feltDark,
      foregroundColor: FatFishColors.cream,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: FatFishColors.cream,
        fontSize: 28,
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: FatFishColors.feltDark,
      indicatorColor: FatFishColors.felt,
    ),
    cardTheme: const CardThemeData(color: FatFishColors.card),
  );
}
