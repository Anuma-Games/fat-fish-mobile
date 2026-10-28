import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final icon in PixelIcons.values) {
    test('${icon.name} is a 12 × 12 grid of # and .', () {
      expect(icon.rows.length, lessThanOrEqualTo(12));
      for (final row in icon.rows) {
        expect(row.length, lessThanOrEqualTo(12));
        expect(row, matches(RegExp(r'^[#.]*$')));
      }
    });
  }

  testWidgets('takes its size and color from IconTheme', (tester) async {
    await tester.pumpWidget(
      const IconTheme(
        data: IconThemeData(size: 36, color: Colors.amber),
        child: Center(child: PixelIcon(PixelIcons.check)),
      ),
    );

    expect(tester.getSize(find.byType(PixelIcon)), const Size(36, 36));
  });
}
