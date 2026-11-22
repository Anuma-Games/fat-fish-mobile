import 'package:fat_fish_mobile/features/expediente/domain/entities/played_match.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/widgets/match_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PlayedMatch match(int received, {int invested = 1000}) => PlayedMatch(
    id: 'match',
    // A victory can still have a negative net result from spins.
    result: MatchResult.victory,
    roundReached: 12,
    score: 99999,
    moneyInvested: invested,
    moneyWon: received,
    moneyLost: 450,
    durationSeconds: 600,
    playedAt: DateTime.utc(2026, 11, 22),
  );

  for (final (received, amount, label) in [
    (1450, r'+$450', r'Ganancia en jugadas: $450'),
    (550, '−\$450', r'Pérdida en jugadas: $450'),
    (1000, r'$0', 'Jugadas sin ganancia ni pérdida'),
  ]) {
    testWidgets('shows one net amount: $amount', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MatchRow(match(received)))),
      );

      expect(find.text(amount), findsOneWidget);
      expect(find.bySemanticsLabel(label), findsOneWidget);
      expect(find.text('99,999 pts'), findsOneWidget);
      final pointsRight = tester.getTopRight(find.text('99,999 pts')).dx;
      final rowRight = tester.getTopRight(find.byType(MatchRow)).dx;
      expect(pointsRight, closeTo(rowRight - 16, 1));
      expect(find.textContaining('1,000'), findsNothing);
      expect(find.textContaining('Invertido'), findsNothing);
      expect(find.text('Victoria'), findsOneWidget);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });
  }

  testWidgets('zero activity has no plus or minus sign', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: MatchRow(match(0, invested: 0)))),
    );
    expect(find.text(r'$0'), findsOneWidget);
  });

  testWidgets('long amounts fit a narrow phone with larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: MatchRow(match(1234567890)),
          ),
        ),
      ),
    );
    expect(find.text(r'+$1,234,566,890'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
