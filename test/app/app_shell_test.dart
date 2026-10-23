import 'package:fat_fish_mobile/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens on the dossier and switches tabs', (tester) async {
    await tester.pumpWidget(const FatFishApp());
    await tester.pumpAndSettle();

    expect(find.text('Lo que el casino sabe de ti'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.leaderboard_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Ranking mundial'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    expect(find.textContaining('buscar a otros'), findsOneWidget);
  });
}
