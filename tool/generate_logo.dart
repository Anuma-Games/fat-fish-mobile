import 'dart:io';

import 'package:image/image.dart' as img;

/// Export the approved logo, native launch images and installation icons.
/// Run from the repository root with `dart run tool/generate_logo.dart`.
void main() {
  const size = 1024;
  final source = File('assets/icon/source/fat_fish_logo.png');
  final emblem = img.decodePng(source.readAsBytesSync())!;
  source.copySync('assets/images/fat_fish.png');
  write('docs/img/logo.png', resize(emblem, 512));
  source.copySync('assets/icon/icon_foreground.png');

  final icon = img.Image(width: size, height: size, numChannels: 3);
  img.fill(icon, color: img.ColorRgb8(0x0B, 0x14, 0x16));
  img.compositeImage(icon, resize(emblem, 924), center: true);
  write('assets/icon/icon.png', icon);

  for (final (density, pixels) in [
    ('mdpi', 120),
    ('hdpi', 180),
    ('xhdpi', 240),
    ('xxhdpi', 360),
    ('xxxhdpi', 480),
  ]) {
    write(
      'android/app/src/main/res/drawable-$density/launch_logo.png',
      resize(emblem, pixels),
    );
  }
  for (var scale = 1; scale <= 3; scale++) {
    final suffix = scale == 1 ? '' : '@${scale}x';
    write(
      'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage$suffix.png',
      resize(emblem, 160 * scale),
    );
  }

  // The AppIcon catalog already exists. Keep project settings intact: version
  // 0.14.4 of the icon generator also rewrites an unrelated asset-symbol flag.
  final project = File('ios/Runner.xcodeproj/project.pbxproj');
  final settings = project.readAsStringSync();
  try {
    final result = Process.runSync('dart', ['run', 'flutter_launcher_icons']);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    exitCode = result.exitCode;
  } finally {
    project.writeAsStringSync(settings);
  }
}

img.Image resize(img.Image image, int pixels) => img.copyResize(
  image,
  width: pixels,
  height: pixels,
  interpolation: img.Interpolation.nearest,
);

void write(String path, img.Image image) =>
    File(path).writeAsBytesSync(img.encodePng(image));
