import 'package:flutter/painting.dart';

/// Design tokens, same names and values as `src/styles/tokens.css` in the PWA.
/// Screens use these constants or the theme; they never write raw colors or sizes.
abstract final class FatFishColors {
  static const bg900 = Color(0xFF0B1416);
  static const bg800 = Color(0xFF11201C);
  static const bg700 = Color(0xFF172A25);
  static const felt800 = Color(0xFF0D3522);
  static const felt700 = Color(0xFF105030);
  static const line = Color(0xFF24493A);
  static const gold400 = Color(0xFFE8B850);
  static const gold600 = Color(0xFFC08828);
  static const ruby700 = Color(0xFF882020);
  static const ruby300 = Color(0xFFF08A7E);
  static const cream100 = Color(0xFFF2E8CC);
  static const fog400 = Color(0xFF9AA8A2);
  static const win300 = Color(0xFF6FD39A);

  /// Lines of the diamond background (patron-casino.svg).
  static const pattern = Color(0xFF163E2D);
}

/// Font families declared in pubspec.yaml (files in assets/fonts).
abstract final class FatFishFonts {
  /// Titles and big numbers.
  static const display = 'Jersey10';

  /// Short pixel labels in uppercase; hard to read in long text.
  static const label = 'PressStart2P';

  /// Body text.
  static const body = 'Geist';
}

abstract final class FatFishSpacing {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
}

abstract final class FatFishRadius {
  static const field = Radius.circular(2);
  static const card = Radius.circular(6);
}

abstract final class FatFishShadows {
  /// Hard pixel shadow of the main button (4px 4px 0 #000).
  static const hard = [
    BoxShadow(color: Color(0xFF000000), offset: Offset(4, 4)),
  ];
}

abstract final class FatFishInsets {
  /// Page content margins on a phone (.content): 24 top, 16 sides, 32 bottom.
  static const page = EdgeInsets.fromLTRB(
    FatFishSpacing.s4,
    FatFishSpacing.s6,
    FatFishSpacing.s4,
    FatFishSpacing.s8,
  );
}
