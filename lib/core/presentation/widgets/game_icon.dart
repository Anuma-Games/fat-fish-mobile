import 'package:flutter/widgets.dart';

/// The round game icon, pixel art kept sharp and lit a little, as under the lamp.
class GameIcon extends StatelessWidget {
  const GameIcon({super.key, this.brightness = 1.35});

  /// Multiplies the color of every pixel; 1 leaves the image as it is.
  final double brightness;

  @override
  Widget build(BuildContext context) {
    final b = brightness;
    return ColorFiltered(
      colorFilter: ColorFilter.matrix([
        b, 0, 0, 0, 0, //
        0, b, 0, 0, 0, //
        0, 0, b, 0, 0, //
        0, 0, 0, 1, 0, //
      ]),
      child: Image.asset(
        'assets/images/fat_fish.png',
        filterQuality: FilterQuality.none,
        excludeFromSemantics: true,
      ),
    );
  }
}
