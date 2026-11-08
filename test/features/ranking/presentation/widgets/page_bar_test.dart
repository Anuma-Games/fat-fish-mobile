import 'package:fat_fish_mobile/features/ranking/presentation/widgets/page_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpBar(WidgetTester tester, {required double width}) =>
      tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: width,
              child: PageBar(current: 0, total: 5, onPage: (_) {}),
            ),
          ),
        ),
      );

  testWidgets('shows the arrows when they fit', (tester) async {
    await pumpBar(tester, width: 358);

    expect(find.byTooltip('Página anterior'), findsOneWidget);
    expect(find.byTooltip('Página siguiente'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('drops the arrows on a 320 px phone and keeps the numbers', (
    tester,
  ) async {
    // 320 wide minus the 16 px margins.
    await pumpBar(tester, width: 288);

    expect(find.byTooltip('Página anterior'), findsNothing);
    expect(find.text('5'), findsOneWidget);
    expect(tester.getSize(find.byType(OutlinedButton).first).height, 44);
    expect(tester.takeException(), isNull);
  });
}
