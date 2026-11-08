import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// Design tokens, the colors of the kit in the design of the app ("Kit de la mesa").
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
  static const cream100 = Color(0xFFF2E8CC);
  static const fog400 = Color(0xFF9AA8A2);

  /// The only red: losses, defeats and danger. As text it only goes on paper;
  /// on a dark background it is a fill under cream text.
  static const red = Color(0xFFB3261E);

  /// Lines of the diamond background (patron-casino.svg).
  static const pattern = Color(0xFF163E2D);

  /// Sheet of the dossier: what the casino knows about you is written on paper.
  static const paper100 = Color(0xFFE6DCC3);

  /// Background of the mugshot on the sheet.
  static const paper200 = Color(0xFFCFC3A3);

  /// Tab of the sheet.
  static const paper300 = Color(0xFFD6C9A6);

  /// Ink on paper.
  static const ink900 = Color(0xFF231E17);

  /// Labels on paper.
  static const ink500 = Color(0xFF5E5546);

  /// Second place of the ranking, and the paper clip.
  static const silver = Color(0xFF8F989F);

  /// Third place of the ranking.
  static const bronze = Color(0xFF9A5B2C);
}

/// Font families declared in pubspec.yaml (files in assets/fonts).
abstract final class FatFishFonts {
  /// Titles and big numbers.
  static const display = 'Jersey10';

  /// Short pixel labels in uppercase; hard to read in long text.
  static const label = 'PressStart2P';

  /// Body text.
  static const body = 'Geist';

  /// Typewriter of the sheets on paper, regular and bold (700).
  static const paper = 'CourierPrime';
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
  /// Fields and labels.
  static const field = Radius.circular(2);

  /// Sheets of paper.
  static const sheet = Radius.circular(4);

  /// Cards and buttons.
  static const card = Radius.circular(6);
}

abstract final class FatFishShadows {
  /// Hard pixel shadow of the main button (4px 4px 0 #000).
  static const hard = [
    BoxShadow(color: Color(0xFF000000), offset: Offset(4, 4)),
  ];

  /// Deeper hard shadow of the dossier sheet, so it lifts over the table.
  static const sheet = [
    BoxShadow(color: Color(0xFF000000), offset: Offset(6, 6)),
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

/// Animation timings. Use them through `motionDuration` (core/presentation/motion.dart)
/// so the phone's "reduce motion" setting turns them off.
abstract final class FatFishMotion {
  /// Icons and small swaps.
  static const fast = Duration(milliseconds: 150);

  /// Content that enters, leaves or resizes.
  static const base = Duration(milliseconds: 250);

  /// Extra delay per row when a list appears, so rows enter one after another.
  static const stagger = Duration(milliseconds: 40);

  static const curve = Curves.easeOutCubic;
}
