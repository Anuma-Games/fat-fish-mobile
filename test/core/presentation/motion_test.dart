import 'package:fat_fish_mobile/core/presentation/motion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // testWidgets runs on a fake clock that pump moves forward.
  testWidgets('a quick answer waits for the minimum', (tester) async {
    int? value;
    atLeast(
      Future.value(7),
      const Duration(milliseconds: 600),
    ).then((v) => value = v);

    await tester.pump(const Duration(milliseconds: 599));
    expect(value, isNull);
    await tester.pump(const Duration(milliseconds: 1));
    expect(value, 7);
  });

  testWidgets('a quick error also waits for the minimum', (tester) async {
    Object? error;
    atLeast<int>(
      Future.error('sin red'),
      const Duration(milliseconds: 600),
    ).catchError((Object e) {
      error = e;
      return 0;
    });

    await tester.pump(const Duration(milliseconds: 599));
    expect(error, isNull);
    await tester.pump(const Duration(milliseconds: 1));
    expect(error, 'sin red');
  });
}
