import 'package:flutter/material.dart';

import 'package:fat_fish_mobile/core/theme/tokens.dart';

/// Material theme with the PWA style guide applied to each component,
/// so screens use plain Material widgets (Card, FilledButton, TextField) and get the casino look.
ThemeData buildFatFishTheme() {
  const scheme = ColorScheme.dark(
    primary: FatFishColors.felt700,
    onPrimary: FatFishColors.cream100,
    secondary: FatFishColors.gold400,
    onSecondary: FatFishColors.bg900,
    surface: FatFishColors.bg900,
    onSurface: FatFishColors.cream100,
    onSurfaceVariant: FatFishColors.fog400,
    surfaceContainer: FatFishColors.bg700,
    error: FatFishColors.ruby300,
    onError: FatFishColors.bg900,
    outline: FatFishColors.line,
    outlineVariant: FatFishColors.line,
  );

  final textTheme = _textTheme();

  return ThemeData(
    colorScheme: scheme,
    fontFamily: FatFishFonts.body,
    textTheme: textTheme,
    scaffoldBackgroundColor: FatFishColors.bg900,
    dividerTheme: const DividerThemeData(color: FatFishColors.line),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: FatFishColors.gold400,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: FatFishColors.felt800,
      foregroundColor: FatFishColors.cream100,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      // Left aligned on every platform, like the PWA top bar (iOS centers it by default).
      centerTitle: false,
      titleSpacing: FatFishSpacing.s4,
      titleTextStyle: textTheme.titleLarge,
      shape: const Border(
        bottom: BorderSide(color: FatFishColors.gold600, width: 2),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: FatFishColors.felt800,
      surfaceTintColor: Colors.transparent,
      indicatorColor: FatFishColors.felt700,
      indicatorShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(FatFishRadius.field),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? FatFishColors.gold400
              : FatFishColors.fog400,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        // .nav a: Press Start 2P 10 px; AppShell writes the labels in uppercase.
        (states) => textTheme.labelSmall?.copyWith(
          fontSize: 10,
          letterSpacing: 0,
          color: states.contains(WidgetState.selected)
              ? FatFishColors.cream100
              : FatFishColors.fog400,
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      color: FatFishColors.bg700,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(FatFishRadius.card),
        side: BorderSide(color: FatFishColors.line),
      ),
    ),
    // Main button (.btn). The hard shadow needs a wrapper with FatFishShadows.hard.
    // Disabled buttons keep their colors at 50 %, like `opacity: 0.5` in the PWA.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: FatFishColors.felt700,
        foregroundColor: FatFishColors.cream100,
        disabledBackgroundColor: _half(FatFishColors.felt700),
        disabledForegroundColor: _half(FatFishColors.cream100),
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: FatFishSpacing.s4),
        textStyle: textTheme.labelLarge,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(FatFishRadius.card),
        ),
      ).copyWith(side: _borderByState(FatFishColors.gold400)),
    ),
    // Secondary button (.btn.ghost).
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: FatFishColors.bg800,
        foregroundColor: FatFishColors.cream100,
        disabledBackgroundColor: _half(FatFishColors.bg800),
        disabledForegroundColor: _half(FatFishColors.cream100),
        minimumSize: const Size(44, 44),
        textStyle: const TextStyle(fontFamily: FatFishFonts.body, fontSize: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(FatFishRadius.card),
        ),
      ).copyWith(side: _borderByState(FatFishColors.line)),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: FatFishColors.bg800,
      hintStyle: TextStyle(color: FatFishColors.fog400),
      contentPadding: EdgeInsets.symmetric(
        horizontal: FatFishSpacing.s3,
        vertical: FatFishSpacing.s2,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(FatFishRadius.field),
        borderSide: BorderSide(color: FatFishColors.line, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(FatFishRadius.field),
        borderSide: BorderSide(color: FatFishColors.line, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(FatFishRadius.field),
        borderSide: BorderSide(color: FatFishColors.gold400, width: 2),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: FatFishColors.bg700,
      contentTextStyle: TextStyle(color: FatFishColors.cream100),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(FatFishRadius.card),
        side: BorderSide(color: FatFishColors.line),
      ),
    ),
  );
}

/// Type scale of the PWA (base.css): Jersey 10 for titles and numbers,
/// Press Start 2P for labels and Geist (15 px, line height 1.5) for text.
TextTheme _textTheme() {
  const display = TextStyle(
    fontFamily: FatFishFonts.display,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.1,
    color: FatFishColors.cream100,
  );
  const body = TextStyle(
    fontFamily: FatFishFonts.body,
    height: 1.5,
    color: FatFishColors.cream100,
  );
  const label = TextStyle(
    fontFamily: FatFishFonts.label,
    fontSize: 9,
    letterSpacing: 1,
    color: FatFishColors.fog400,
  );

  return TextTheme(
    displaySmall: display.copyWith(fontSize: 40), // stat values
    headlineLarge: display.copyWith(fontSize: 40), // h1
    headlineMedium: display.copyWith(fontSize: 30), // h2
    headlineSmall: display.copyWith(fontSize: 24), // h3
    titleLarge: display.copyWith(fontSize: 26), // app bar (.topbar-title)
    labelLarge: display.copyWith(fontSize: 22, height: 1), // buttons
    bodyLarge: body.copyWith(fontSize: 16),
    bodyMedium: body.copyWith(fontSize: 15),
    bodySmall: body.copyWith(fontSize: 13, color: FatFishColors.fog400),
    labelSmall: label, // write the text in uppercase, like .label in the PWA
  );
}

Color _half(Color color) => color.withValues(alpha: 0.5);

/// 2 px button border that fades with the rest of the button when disabled.
WidgetStateProperty<BorderSide> _borderByState(Color color) =>
    WidgetStateProperty.resolveWith(
      (states) => BorderSide(
        color: states.contains(WidgetState.disabled) ? _half(color) : color,
        width: 2,
      ),
    );
