import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/features/mesa/domain/roulette.dart';
import 'package:flutter/painting.dart';

/// Fill and name of each color of the wheel.
extension PocketColorStyle on PocketColor {
  /// Color of the pocket on the head of the wheel.
  Color get pocket => switch (this) {
    PocketColor.green => FatFishColors.felt700,
    PocketColor.red => FatFishColors.red,
    PocketColor.black => FatFishColors.bg900,
  };

  /// Fill of a result box: black reads blacker off the wheel.
  Color get box => switch (this) {
    PocketColor.black => const Color(0xFF000000),
    _ => pocket,
  };

  String get label => switch (this) {
    PocketColor.green => 'verde',
    PocketColor.red => 'rojo',
    PocketColor.black => 'negro',
  };
}
