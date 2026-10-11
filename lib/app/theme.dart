import 'package:flutter/material.dart';

/// Colors from the Fat Fish style guide (same as the PWA).
abstract final class FatFishColors {
  static const background = Color(0xFF0B1416);
  static const card = Color(0xFF172A25);
  static const felt = Color(0xFF105030);
  static const feltDark = Color(0xFF0D3522);
  static const gold = Color(0xFFE8B850);
  static const cream = Color(0xFFF2E8CC);
  static const fog = Color(0xFF9AA8A2);
  static const ruby = Color(0xFFF08A7E);
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
      );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: FatFishColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: FatFishColors.feltDark,
      foregroundColor: FatFishColors.cream,
    ),
    cardTheme: const CardThemeData(color: FatFishColors.card),
  );
}
