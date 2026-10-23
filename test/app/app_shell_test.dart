import 'package:fat_fish_mobile/app/app.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Finder tab(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  testWidgets('opens on the dossier and switches tabs', (tester) async {
    await tester.pumpWidget(const FatFishApp());
    await tester.pumpAndSettle();

    expect(find.text('Lo que el casino sabe de ti'), findsOneWidget);
    expect(find.byType(PixelIcon), findsNWidgets(3));

    await tester.tap(tab('Ranking'));
    await tester.pumpAndSettle();
    expect(find.text('Ranking mundial'), findsOneWidget);

    await tester.tap(tab('Mi jugador'));
    await tester.pumpAndSettle();
    expect(find.textContaining('buscar a otros'), findsOneWidget);
  });
}
