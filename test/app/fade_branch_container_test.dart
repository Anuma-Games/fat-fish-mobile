import 'package:fat_fish_mobile/app/fade_branch_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Opacity actually painted for the tab that holds [text].
  double paintedOpacity(WidgetTester tester, String text) => tester
      .widget<FadeTransition>(
        find
            .ancestor(
              of: find.text(text),
              matching: find.byType(FadeTransition),
            )
            .first,
      )
      .opacity
      .value;

  Widget tabs(int currentIndex) => Directionality(
    textDirection: TextDirection.ltr,
    child: FadeBranchContainer(
      currentIndex: currentIndex,
      children: const [Text('Expediente'), Text('Mi jugador')],
    ),
  );

  testWidgets('fades the leaving tab all the way out', (tester) async {
    await tester.pumpWidget(tabs(1));
    expect(paintedOpacity(tester, 'Mi jugador'), 1);

    await tester.pumpWidget(tabs(0));
    await tester.pumpAndSettle();

    expect(paintedOpacity(tester, 'Mi jugador'), 0);
    expect(paintedOpacity(tester, 'Expediente'), 1);
  });

  testWidgets('switches at once when the phone reduces motion', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: tabs(1),
      ),
    );
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: tabs(0),
      ),
    );
    await tester.pump();

    expect(paintedOpacity(tester, 'Mi jugador'), 0);
  });

  testWidgets('a hidden tab drops its focus', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    Widget app(int index) => MaterialApp(
      home: Material(
        child: FadeBranchContainer(
          currentIndex: index,
          children: [
            const Text('Expediente'),
            TextField(focusNode: focus),
          ],
        ),
      ),
    );

    await tester.pumpWidget(app(1));
    focus.requestFocus();
    await tester.pump();
    expect(focus.hasFocus, isTrue);

    await tester.pumpWidget(app(0));
    await tester.pumpAndSettle();

    expect(focus.hasFocus, isFalse);
  });
}
