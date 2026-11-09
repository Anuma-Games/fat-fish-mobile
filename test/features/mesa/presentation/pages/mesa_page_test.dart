import 'dart:math' as math;

import 'package:fat_fish_mobile/core/audio/table_sound.dart';
import 'package:fat_fish_mobile/features/mesa/domain/roulette.dart';
import 'package:fat_fish_mobile/features/mesa/presentation/pages/mesa_page.dart';
import 'package:fat_fish_mobile/features/mesa/presentation/widgets/roulette_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Writes down what the table plays.
class _RecordingSound extends SilentTableSound {
  int clicks = 0;
  final tones = <double>[];
  int falls = 0;
  final rolls = <double>[];
  int stops = 0;

  @override
  void click(double strength, {double tone = 3000}) {
    clicks++;
    tones.add(tone);
  }

  @override
  void roll(double speed, double amongFrets) => rolls.add(speed);

  @override
  void stopRoll() => stops++;

  @override
  void fall() => falls++;
}

void main() {
  late _RecordingSound sound;

  setUp(() => sound = _RecordingSound());
  tearDown(
    () => TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher
        .clearAccessibilityFeaturesTestValue(),
  );

  /// The number the seeded wheel picks on its first spin.
  int firstNumber(int seed) => Roulette.order[Roulette.pick(math.Random(seed))];

  Future<void> pumpMesa(WidgetTester tester, {bool still = false}) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: still);
    await tester.pumpWidget(
      RepositoryProvider<TableSound>.value(
        value: sound,
        child: MaterialApp(home: MesaPage(random: math.Random(7))),
      ),
    );
    await tester.pump();
  }

  /// Leaves the page, so its clock and the croupier's timers stop.
  Future<void> leave(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox.shrink());

  testWidgets('spinning shows the number and color, and sounds the ball', (
    tester,
  ) async {
    await pumpMesa(tester);
    expect(find.text('Toca la ruleta\npara girarla...'), findsOneWidget);
    expect(
      find.text(
        'Esta ruleta es solo para divertirte,\nno cambia tu expediente.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.bySemanticsLabel('Girar la ruleta'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('La bola corre…'), findsOneWidget);

    // Frame by frame, so the clicks follow the ball.
    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    final number = firstNumber(7);
    final color = Roulette.colorOf(number).name;
    final label = switch (color) {
      'red' => 'ROJO',
      'black' => 'NEGRO',
      _ => 'VERDE',
    };
    expect(find.text('$number'), findsOneWidget);
    expect(find.text(label), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(sound.clicks, greaterThan(20));
    // High on the track, deeper among the pockets, and knocks on the bounces.
    expect(sound.tones.first, 3600);
    expect(sound.tones.where((t) => t < 3000 && t > 2700), isNotEmpty);
    expect(sound.tones, contains(1700));
    expect(sound.rolls, isNotEmpty);
    expect(sound.rolls.first, greaterThan(sound.rolls.last));
    expect(sound.stops, greaterThanOrEqualTo(1));
    expect(sound.falls, 1);

    // The ball rides the head: it rests in its pocket wherever the head left it, not
    // always at the top.
    final wheel = tester.widget<RouletteWheel>(find.byType(RouletteWheel));
    final pocket = Roulette.order.indexOf(number);
    final pocketAt = wheel.head + pocket * Roulette.step + Roulette.step / 2;
    final ballOff = wheel.ball - pocketAt;
    expect((ballOff - ballOff.roundToDouble()).abs(), lessThan(1e-6));
    expect((wheel.ball % 1 - 0).abs(), greaterThan(0.01));

    await leave(tester);
  });

  testWidgets('a second spin moves the first number to the last ones', (
    tester,
  ) async {
    await pumpMesa(tester, still: true);
    final random = math.Random(7);
    final first = Roulette.order[Roulette.pick(random)];

    await tester.tap(find.bySemanticsLabel('Girar la ruleta'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Girar la ruleta'));
    await tester.pump();

    expect(
      find.bySemanticsLabel(RegExp('^Últimos giros: $first, ')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('2 giros')), findsOneWidget);

    await leave(tester);
  });

  testWidgets(
    'with reduced motion the result shows at once, without the roll',
    (tester) async {
      await pumpMesa(tester, still: true);

      await tester.tap(find.bySemanticsLabel('Girar la ruleta'));
      await tester.pump();

      expect(find.text('La bola corre…'), findsNothing);
      expect(find.text('${firstNumber(7)}'), findsOneWidget);
      expect(sound.clicks, 0);
      expect(sound.rolls, isEmpty);
      expect(sound.falls, 1);

      await leave(tester);
    },
  );

  testWidgets('counts the time of the visit', (tester) async {
    await pumpMesa(tester, still: true);

    await tester.pump(const Duration(seconds: 65));

    expect(find.text('1:05'), findsOneWidget);
    await leave(tester);
  });
}
