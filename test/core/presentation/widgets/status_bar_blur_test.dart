import 'package:fat_fish_mobile/core/presentation/widgets/status_bar_blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpBlur(WidgetTester tester, {required double top}) =>
      tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.only(top: top)),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topCenter,
              child: StatusBarBlur(),
            ),
          ),
        ),
      );

  testWidgets('covers the status bar and fades below it', (tester) async {
    await pumpBlur(tester, top: 54);

    // The status bar plus two fading bands of 8 px.
    expect(tester.getSize(find.byType(StatusBarBlur)).height, 54 + 16);
    expect(find.byType(BackdropFilter), findsNWidgets(3));
  });

  testWidgets('draws nothing on a screen without a status bar on top', (
    tester,
  ) async {
    await pumpBlur(tester, top: 0);

    expect(find.byType(BackdropFilter), findsNothing);
  });
}
