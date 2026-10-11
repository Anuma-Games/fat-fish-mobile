import 'package:fat_fish_mobile/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the dossier title on the home screen', (tester) async {
    await tester.pumpWidget(const FatFishApp());

    expect(find.text('Fat Fish'), findsOneWidget);
    expect(find.text('Lo que el casino sabe de ti'), findsOneWidget);
  });
}
