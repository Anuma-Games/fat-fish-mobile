import 'dart:io';

import 'package:drift/native.dart';
import 'package:fat_fish_mobile/app/app.dart';
import 'package:fat_fish_mobile/app/app_providers.dart';
import 'package:fat_fish_mobile/app/nav_bar.dart';
import 'package:fat_fish_mobile/core/network/api_client.dart';
import 'package:fat_fish_mobile/core/audio/table_sound.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/status_bar_blur.dart';
import 'package:fat_fish_mobile/core/storage/app_database.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/pages/ajustes_page.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/pages/expediente_page.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/pages/historial_page.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/pages/jugador_page.dart';
import 'package:fat_fish_mobile/features/ranking/presentation/pages/ranking_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// One of the two pages of a ranking of 20 players.
http.Response rankingPage(int page) {
  final entries = [
    for (var i = page * 10 + 1; i <= page * 10 + 10; i++)
      '{"posicion":$i,"jugadorId":"$i","alias":"jugador_$i",'
          '"puntaje":${2000 - i},"logradoEn":"2026-10-01T12:00:00Z"}',
  ];
  return http.Response(
    '{"pagina":{"contenido":[${entries.join(',')}],'
    '"pagina":$page,"totalPaginas":2},"miPosicion":null}',
    200,
  );
}

/// Answers of the API the app needs to open each tab.
http.Response answer(http.Request request) => switch (request.url.path) {
  '/api/pwa/perfil' => http.Response(
    '{"jugadorId":"70","alias":"Don Ramon",'
    '"creadoEn":"2026-10-02T12:00:00Z","ultimaActividad":null,'
    '"estadisticas":{"partidasTotales":1,"partidasGanadas":0,'
    '"totalInvertido":500,"totalPerdido":500,'
    '"rachaDerrotasMax":1,"tiempoJugadoSeg":600},'
    '"generadoEn":"2026-11-07T12:00:00Z"}',
    200,
  ),
  '/api/pwa/partidas' => http.Response(
    '{"contenido":[{"id":"p1","resultado":"DERROTA",'
    '"rondaAlcanzada":2,"puntaje":144,"dineroInvertido":500,'
    '"dineroGanado":0,"dineroPerdido":500,"duracionSeg":600,'
    '"creadaEn":"2026-11-01T12:00:00Z"}],'
    '"pagina":0,"totalElementos":1,"ultima":true}',
    200,
  ),
  '/api/pwa/ranking' => rankingPage(
    int.parse(request.url.queryParameters['pagina'] ?? '0'),
  ),
  '/api/pwa/jugadores' => http.Response(
    '[{"jugadorId":"70","alias":"Don Ramon","ultimaActividad":null}]',
    200,
  ),
  _ => http.Response('', 404),
};

class _RecordingSound extends SilentTableSound {
  int chips = 0;
  @override
  void navigationChip() => chips++;
}

void main() {
  // The welcome screen animates its lamp without end; with "reduce motion" it stays
  // still, so pumpAndSettle can finish.
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
  });
  tearDown(
    () => TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher
        .clearAccessibilityFeaturesTestValue(),
  );

  Finder tab(String label) => find.descendant(
    of: find.byType(FatFishNavBar),
    matching: find.bySemanticsLabel(label),
  );

  Future<AppDatabase> pumpApp(
    WidgetTester tester, {
    bool player = false,
    AppDatabase? database,
    TableSound tableSound = const SilentTableSound(),
  }) async {
    final db = database ?? AppDatabase(NativeDatabase.memory());
    if (player) {
      await db
          .into(db.myPlayers)
          .insert(
            MyPlayersCompanion.insert(playerId: '70', alias: 'Don Ramon'),
          );
    }
    await tester.pumpWidget(
      AppProviders(
        apiClient: ApiClient(
          baseUrl: 'https://api.test',
          httpClient: MockClient((request) async => answer(request)),
        ),
        database: db,
        tableSound: tableSound,
        child: const FatFishApp(),
      ),
    );
    await tester.pumpAndSettle();
    return db;
  }

  testWidgets('without a player it opens the welcome, not the dossier', (
    tester,
  ) async {
    final sound = _RecordingSound();
    await pumpApp(tester, tableSound: sound);

    expect(find.bySemanticsLabel('Fat Fish'), findsOneWidget);
    expect(find.byType(FatFishNavBar), findsNothing);

    await tester.ensureVisible(find.text('Ver el ranking mundial'));
    await tester.tap(find.text('Ver el ranking mundial'));
    await tester.pumpAndSettle();
    expect(find.text('Las mejores partidas'), findsOneWidget);

    // The dossier needs a player: its tab leads back to the welcome.
    await tester.tap(tab('Expediente'));
    await tester.pumpAndSettle();
    expect(find.text('Buscar mi jugador'), findsOneWidget);
    expect(
      sound.chips,
      1,
    ); // The dossier redirect still confirms one bar selection.
  });

  testWidgets('choosing a player opens the dossier', (tester) async {
    final db = await pumpApp(tester);

    await tester.ensureVisible(find.text('Buscar mi jugador'));
    await tester.tap(find.text('Buscar mi jugador'));
    await tester.pumpAndSettle();
    expect(find.text('¿Quién eres en la mesa?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'don');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Don Ramon'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('EXPEDIENTE N.º 70'), findsOneWidget);
    expect(
      tester.widget<FatFishNavBar>(find.byType(FatFishNavBar)).currentIndex,
      0,
    );
    expect((await db.select(db.myPlayers).getSingle()).playerId, '70');
  });

  testWidgets('"Cambiar" opens the search over the dossier and back returns', (
    tester,
  ) async {
    await pumpApp(tester, player: true);

    await tester.tap(find.text('Cambiar'));
    await tester.pumpAndSettle();
    expect(find.text('¿Quién eres en la mesa?'), findsOneWidget);
    expect(find.byType(FatFishNavBar), findsNothing);

    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    expect(find.text('EXPEDIENTE N.º 70'), findsOneWidget);
  });

  testWidgets('one chip per confirmed section change by tap or drag', (
    tester,
  ) async {
    final sound = _RecordingSound();
    await pumpApp(tester, player: true, tableSound: sound);
    expect(sound.chips, 0); // Opening the app is not a section change.
    int open() =>
        tester.widget<FatFishNavBar>(find.byType(FatFishNavBar)).currentIndex;

    await tester.tap(tab('Mesa'));
    await tester.pumpAndSettle();
    expect(open(), 1);
    expect(sound.chips, 1);
    await tester.tap(tab('Mesa'));
    await tester.tap(tab('Mesa'));
    await tester.pumpAndSettle();
    expect(sound.chips, 1); // Retapping the active chip is silent.
    expect(find.text('Toca la ruleta\npara girarla...'), findsOneWidget);

    // Slide from the table to the ranking and lift the finger there.
    final from = tester.getCenter(tab('Mesa'));
    final to = tester.getCenter(tab('Ranking'));
    final gesture = await tester.startGesture(from);
    await gesture.moveTo(to);
    await tester.pump();
    expect(open(), 1);
    expect(sound.chips, 1); // Previewing another tab is silent.
    await gesture.up();
    await tester.pumpAndSettle();
    expect(open(), 2);
    expect(sound.chips, 2);
    expect(find.text('Las mejores partidas'), findsOneWidget);
  });

  testWidgets('tapping the open tab returns to its first screen silently', (
    tester,
  ) async {
    final sound = _RecordingSound();
    await pumpApp(tester, player: true, tableSound: sound);
    await tester.scrollUntilVisible(find.text('Ver la partida'), 200);
    await tester.tap(find.text('Ver la partida'));
    await tester.pumpAndSettle();
    expect(find.text('Cada partida, anotada'), findsOneWidget);

    await tester.tap(tab('Expediente'));
    await tester.pumpAndSettle();
    expect(find.text('Cada partida, anotada'), findsNothing);
    expect(find.text('EXPEDIENTE N.º 70'), findsOneWidget);
    expect(sound.chips, 0);
  });

  testWidgets(
    'rapid repeated taps emit one chip and an active-tab drag stays silent',
    (tester) async {
      final sound = _RecordingSound();
      await pumpApp(tester, player: true, tableSound: sound);
      await tester.tap(tab('Mesa'));
      await tester.tap(tab('Mesa'));
      await tester.pumpAndSettle();
      expect(sound.chips, 1);

      final from = tester.getCenter(tab('Mesa'));
      final to = tester.getCenter(tab('Ranking'));
      final cancelled = await tester.startGesture(from);
      await cancelled.moveTo(to);
      await tester.pump();
      await cancelled.cancel();
      await tester.pumpAndSettle();
      expect(sound.chips, 1);
      expect(
        tester.widget<FatFishNavBar>(find.byType(FatFishNavBar)).currentIndex,
        1,
      );

      final returned = await tester.startGesture(from);
      await returned.moveTo(to);
      await returned.moveTo(from);
      await returned.up();
      await tester.pumpAndSettle();
      expect(sound.chips, 1);
      expect(
        tester.widget<FatFishNavBar>(find.byType(FatFishNavBar)).currentIndex,
        1,
      );
    },
  );

  testWidgets('the speaker and the gear of the top bar, remembered on reopen', (
    tester,
  ) async {
    // On a file: closing the app closes its database.
    final folder = Directory.systemTemp.createTempSync('fat_fish_');
    addTearDown(() => folder.deleteSync(recursive: true));
    final file = File('${folder.path}/app.sqlite');
    await pumpApp(
      tester,
      player: true,
      database: AppDatabase(NativeDatabase(file)),
    );
    expect(find.byTooltip('Encender el ambiente de fondo'), findsOneWidget);

    await tester.tap(find.byTooltip('Encender el ambiente de fondo'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Apagar el ambiente de fondo'), findsOneWidget);

    // A quick double tap opens Ajustes once.
    await tester.tap(find.byTooltip('Ajustes'));
    await tester.tap(find.byTooltip('Ajustes'));
    await tester.pumpAndSettle();
    expect(find.text('Sonidos de la mesa'), findsOneWidget);
    // Ajustes has no gear of its own.
    expect(find.byTooltip('Ajustes'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Sonidos de la mesa'));
    await tester.tap(find.bySemanticsLabel('Vibración'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    expect(find.text('EXPEDIENTE N.º 70'), findsOneWidget);

    // Opening the app again keeps both choices.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    final db = await pumpApp(
      tester,
      database: AppDatabase(NativeDatabase(file)),
    );
    expect(find.byTooltip('Apagar el ambiente de fondo'), findsOneWidget);
    final row = await tester.runAsync(
      () => db.select(db.appSettings).getSingle(),
    );
    expect(row!.ambienceOn, isTrue);
    expect(row.tableSoundsOn, isTrue);
    expect(row.vibration, isFalse);
  });

  testWidgets('the bars hide while scrolling down and return when going up', (
    tester,
  ) async {
    await pumpApp(tester, player: true);
    await tester.tap(tab('Ranking'));
    await tester.pumpAndSettle();
    Offset barOffset() => tester
        .widget<AnimatedSlide>(
          find
              .ancestor(
                of: find.byType(FatFishNavBar),
                matching: find.byType(AnimatedSlide),
              )
              .first,
        )
        .offset;

    double blurOpacity() => tester
        .widget<AnimatedOpacity>(
          find
              .ancestor(
                of: find.byType(StatusBarBlur),
                matching: find.byType(AnimatedOpacity),
              )
              .first,
        )
        .opacity;
    expect(blurOpacity(), 0);

    await tester.drag(find.text('Las mejores partidas'), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(barOffset(), const Offset(0, 1));
    // The blur takes the place of the top bar behind the status bar.
    expect(blurOpacity(), 1);

    await tester.drag(find.byType(Scrollable).last, const Offset(0, 100));
    await tester.pumpAndSettle();
    expect(barOffset(), Offset.zero);
    expect(blurOpacity(), 0);
  });

  testWidgets('a new page of the ranking opens at the top with its bars', (
    tester,
  ) async {
    await pumpApp(tester, player: true);
    await tester.tap(tab('Ranking'));
    await tester.pumpAndSettle();
    Offset barOffset() => tester
        .widget<AnimatedSlide>(
          find
              .ancestor(
                of: find.byType(FatFishNavBar),
                matching: find.byType(AnimatedSlide),
              )
              .first,
        )
        .offset;

    // Scrolling down to the page numbers hides the bars.
    final pageTwo = find.widgetWithText(OutlinedButton, '2');
    await tester.dragUntilVisible(
      pageTwo,
      find.byType(Scrollable).last,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    expect(barOffset(), const Offset(0, 1));

    await tester.tap(pageTwo);
    await tester.pumpAndSettle();
    expect(find.text('jugador_11'), findsOneWidget);
    // The page starts at the top, where the top bar has its room: both bars return.
    expect(barOffset(), Offset.zero);
  });

  testWidgets('the history opens over the dossier and goes back', (
    tester,
  ) async {
    final requests = <String>[];
    final db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.myPlayers)
        .insert(MyPlayersCompanion.insert(playerId: '70', alias: 'Don Ramon'));
    await tester.pumpWidget(
      AppProviders(
        apiClient: ApiClient(
          baseUrl: 'https://api.test',
          httpClient: MockClient((request) async {
            requests.add(request.url.path);
            return answer(request);
          }),
        ),
        database: db,
        child: const FatFishApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Ver la partida'), 200);
    await tester.tap(find.text('Ver la partida'));
    await tester.pumpAndSettle();
    expect(find.text('Cada partida, anotada'), findsOneWidget);
    // The history reuses the pages of the dossier: no second request.
    expect(requests.where((path) => path == '/api/pwa/partidas'), hasLength(1));

    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    expect(find.text('Cada partida, anotada'), findsNothing);
    expect(find.text('EXPEDIENTE N.º 70'), findsOneWidget);
  });

  Future<void> iosSwipe(
    WidgetTester tester,
    Finder page, {
    bool cancel = false,
  }) async {
    final route = ModalRoute.of(tester.element(page))!;
    expect(route.popGestureEnabled, isTrue);
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final gesture = await tester.startGesture(const Offset(1, 200));
    await gesture.moveBy(const Offset(24, 0));
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.moveBy(Offset(width * (cancel ? 0.15 : 0.8), 0));
    await tester.pump(const Duration(milliseconds: 100));
    expect(route.navigator!.userGestureInProgress, isTrue);
    // Release without a fling when testing cancellation.
    if (cancel) await tester.pump(const Duration(milliseconds: 600));
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets(
    'iOS edge back completes and cancels settings without losing the player',
    (tester) async {
      final db = await pumpApp(tester, player: true);
      await tester.tap(find.byTooltip('Ajustes'));
      await tester.pumpAndSettle();
      await iosSwipe(tester, find.byType(AjustesPage), cancel: true);
      expect(find.byType(AjustesPage), findsOneWidget);
      await iosSwipe(tester, find.byType(AjustesPage));
      expect(find.byType(AjustesPage), findsNothing);
      expect(find.text('EXPEDIENTE N.º 70'), findsOneWidget);
      expect((await db.select(db.myPlayers).getSingle()).playerId, '70');
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'iOS edge back cancels and completes player search without changing selection',
    (tester) async {
      final db = await pumpApp(tester, player: true);
      await tester.tap(find.text('Cambiar'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'don');
      await tester.pump(const Duration(milliseconds: 400));
      await iosSwipe(tester, find.byType(JugadorPage), cancel: true);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'don',
      );
      await iosSwipe(tester, find.byType(JugadorPage));
      expect(find.byType(JugadorPage), findsNothing);
      expect(find.text('EXPEDIENTE N.º 70'), findsOneWidget);
      expect((await db.select(db.myPlayers).getSingle()).playerId, '70');
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets('iOS edge back returns from nested history', (tester) async {
    final db = await pumpApp(tester, player: true);
    await tester.scrollUntilVisible(find.text('Ver la partida'), 200);
    await tester.tap(find.text('Ver la partida'));
    await tester.pumpAndSettle();
    expect(find.byType(HistorialPage), findsOneWidget);
    await iosSwipe(tester, find.byType(HistorialPage), cancel: true);
    expect(find.byType(HistorialPage), findsOneWidget);
    await iosSwipe(tester, find.byType(HistorialPage));
    expect(find.byType(HistorialPage), findsNothing);
    expect((await db.select(db.myPlayers).getSingle()).playerId, '70');
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets(
    'Android back closes settings, search and nested history in order',
    (tester) async {
      final db = await pumpApp(tester, player: true);
      await tester.scrollUntilVisible(find.text('Ver la partida'), 200);
      final dossierScroll = Scrollable.of(tester.element(find.text('Cambiar')))
          .position;
      final savedOffset = dossierScroll.pixels;
      await tester.tap(find.text('Ver la partida'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Ajustes'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(AjustesPage), findsNothing);
      expect(find.byType(HistorialPage), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(HistorialPage), findsNothing);
      expect(dossierScroll.pixels, savedOffset);
      dossierScroll.jumpTo(0);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cambiar'));
      await tester.pumpAndSettle();
      expect(find.byType(JugadorPage), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(JugadorPage), findsNothing);
      expect((await db.select(db.myPlayers).getSingle()).playerId, '70');
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets('iOS does not back-swipe between root tabs', (tester) async {
    final db = await pumpApp(tester, player: true);
    final route = ModalRoute.of(tester.element(find.byType(ExpedientePage)))!;
    expect(route.popGestureEnabled, isFalse);
    await tester.dragFrom(const Offset(1, 200), const Offset(650, 0));
    await tester.pumpAndSettle();
    expect(find.text('EXPEDIENTE N.º 70'), findsOneWidget);
    expect(
      tester.widget<FatFishNavBar>(find.byType(FatFishNavBar)).currentIndex,
      0,
    );
    expect((await db.select(db.myPlayers).getSingle()).playerId, '70');
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets(
    'Android back returns to the previous section with its history intact',
    (tester) async {
      var exits = 0;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'SystemNavigator.pop') exits++;
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      final db = await pumpApp(tester, player: true);
      await tester.scrollUntilVisible(find.text('Ver la partida'), 200);
      await tester.tap(find.text('Ver la partida'));
      await tester.pumpAndSettle();
      await tester.tap(tab('Ranking'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(exits, 0); // Section history takes priority over leaving the app.
      expect(
        tester.widget<FatFishNavBar>(find.byType(FatFishNavBar)).currentIndex,
        0,
      );
      expect(find.byType(HistorialPage), findsOneWidget);
      expect((await db.select(db.myPlayers).getSingle()).playerId, '70');
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    'Android keeps native back registered after closing settings over history',
    (tester) async {
      final handlesBack = <bool>[];
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'SystemNavigator.setFrameworkHandlesBack') {
            handlesBack.add(call.arguments as bool);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pumpApp(tester, player: true);
      await tester.scrollUntilVisible(find.text('Ver la partida'), 200);
      await tester.tap(find.text('Ver la partida'));
      await tester.pumpAndSettle();
      expect(handlesBack.last, isTrue);
      await tester.tap(find.byTooltip('Ajustes'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(HistorialPage), findsOneWidget);
      expect(handlesBack.last, isTrue); // There is still an inner page to pop.
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  int section(WidgetTester tester) =>
      tester.widget<FatFishNavBar>(find.byType(FatFishNavBar)).currentIndex;

  Future<void> sectionSwipe(
    WidgetTester tester, {
    double distance = -180,
    bool edge = false,
    bool cancel = false,
    bool returnToOrigin = false,
  }) async {
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final gesture = await tester.startGesture(
      Offset(edge ? 1 : width / 2, 240),
    );
    await gesture.moveBy(Offset(distance, 0));
    await tester.pump(const Duration(milliseconds: 100));
    if (returnToOrigin) {
      await gesture.moveBy(Offset(-distance, 0));
      await tester.pump(const Duration(milliseconds: 100));
    }
    // Release slowly: assertions below exercise travel, not an accidental fling.
    await tester.pump(const Duration(milliseconds: 600));
    if (cancel) {
      await gesture.cancel();
    } else {
      await gesture.up();
    }
    await tester.pumpAndSettle();
  }

  Future<void> sectionBack(WidgetTester tester) async {
    final platform = Theme.of(tester.element(find.byType(FatFishNavBar)))
        .platform;
    if (platform == TargetPlatform.iOS) {
      await sectionSwipe(tester, distance: 180, edge: true);
    } else {
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }
  }

  List<String> recordExits(WidgetTester tester) {
    final exits = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemNavigator.pop') exits.add('exit');
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    return exits;
  }

  testWidgets(
    'content swipes keep tab order, endpoints, scroll and roulette state',
    (tester) async {
      await pumpApp(tester, player: true);
      await tester.drag(find.byType(ListView).first, const Offset(0, -180));
      await tester.pumpAndSettle();
      final scroll = Scrollable.of(tester.element(find.text('Cambiar')))
          .position;
      final offset = scroll.pixels;
      expect(offset, greaterThan(0));
      await sectionSwipe(tester);
      expect(section(tester), 1);
      await tester.tap(find.bySemanticsLabel('Girar la ruleta'));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(RegExp('Esta visita a la mesa: 1 giros')),
        findsOneWidget,
      );
      await sectionSwipe(tester);
      expect(section(tester), 2);
      await sectionSwipe(tester); // Last section does not wrap around.
      expect(section(tester), 2);
      await sectionSwipe(tester, distance: 180);
      expect(section(tester), 1);
      expect(
        find.bySemanticsLabel(RegExp('Esta visita a la mesa: 1 giros')),
        findsOneWidget,
      );
      await sectionSwipe(tester, distance: 180);
      expect(section(tester), 0);
      expect(scroll.pixels, offset);
      await sectionSwipe(tester, distance: 180);
      expect(section(tester), 0);
    },
    variant: TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );

  testWidgets(
    'section swipes and section back play one chip each',
    (tester) async {
      final sound = _RecordingSound();
      await pumpApp(tester, player: true, tableSound: sound);
      await sectionSwipe(tester);
      expect(section(tester), 1);
      expect(sound.chips, 1);
      await sectionSwipe(tester, distance: 16); // Too short: no change.
      expect(sound.chips, 1);
      await sectionBack(tester);
      expect(section(tester), 0);
      expect(sound.chips, 2);
    },
    variant: TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );

  testWidgets(
    'short, cancelled and reversed swipes do not consume visits',
    (tester) async {
      await pumpApp(tester, player: true);
      await tester.tap(tab('Mesa'));
      await tester.pumpAndSettle();
      await sectionSwipe(tester, distance: 16);
      expect(section(tester), 1);
      await sectionSwipe(tester, cancel: true);
      expect(section(tester), 1);
      await sectionSwipe(tester, returnToOrigin: true);
      expect(section(tester), 1);
      await sectionSwipe(tester, distance: 180, edge: true, cancel: true);
      expect(section(tester), 1);
      await sectionSwipe(
        tester,
        distance: 180,
        edge: true,
        returnToOrigin: true,
      );
      expect(section(tester), 1);
      await sectionBack(tester);
      expect(section(tester), 0); // The original visit is still available.
    },
    variant: TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );

  testWidgets(
    'back follows visits including repeats, without adding return loops',
    (tester) async {
      final exits = recordExits(tester);
      final db = await pumpApp(tester, player: true);
      for (final label in ['Ranking', 'Mesa', 'Ranking', 'Ranking']) {
        await tester.tap(tab(label));
        await tester.pumpAndSettle();
      }
      for (final previous in [1, 2, 0]) {
        await sectionBack(tester);
        expect(section(tester), previous);
        expect(exits, isEmpty);
      }
      await sectionBack(tester);
      expect(section(tester), 0);
      final platform = Theme.of(tester.element(find.byType(FatFishNavBar)))
          .platform;
      expect(exits.length, platform == TargetPlatform.android ? 1 : 0);
      expect((await db.select(db.myPlayers).getSingle()).playerId, '70');
    },
    variant: TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );

  testWidgets(
    'only the last five section visits can be undone',
    (tester) async {
      final exits = recordExits(tester);
      await pumpApp(tester, player: true);
      for (final label in [
        'Mesa',
        'Ranking',
        'Expediente',
        'Ranking',
        'Mesa',
        'Expediente',
        'Ranking',
      ]) {
        await tester.tap(tab(label));
        await tester.pumpAndSettle();
      }
      for (final previous in [0, 1, 2, 0, 2]) {
        await sectionBack(tester);
        expect(section(tester), previous);
        expect(exits, isEmpty);
      }
      await sectionBack(tester); // The two oldest visits have been discarded.
      expect(section(tester), 2);
      final platform = Theme.of(tester.element(find.byType(FatFishNavBar)))
          .platform;
      expect(exits.length, platform == TargetPlatform.android ? 1 : 0);
    },
    variant: TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );

  testWidgets(
    'stacked pages close before section history is consumed',
    (tester) async {
      await pumpApp(tester, player: true);
      await tester.tap(tab('Mesa'));
      await tester.pumpAndSettle();
      await tester.tap(tab('Expediente'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Ver la partida'), 200);
      await tester.tap(find.text('Ver la partida'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Ajustes').hitTestable());
      await tester.pumpAndSettle();
      final platform = Theme.of(tester.element(find.byType(AjustesPage)))
          .platform;
      if (platform == TargetPlatform.iOS) {
        await iosSwipe(tester, find.byType(AjustesPage));
        expect(find.byType(HistorialPage), findsOneWidget);
        await iosSwipe(tester, find.byType(HistorialPage));
      } else {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(HistorialPage), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }
      expect(section(tester), 0);
      expect(find.byType(HistorialPage), findsNothing);
      await sectionBack(tester);
      expect(section(tester), 1);
      await sectionBack(tester);
      expect(section(tester), 0);
    },
    variant: TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );

  testWidgets('without connection it shows the last saved dossier and ranking', (
    tester,
  ) async {
    var online = true;
    // A file, so the second visit opens a new database over the same data, as the
    // phone does when the app starts again.
    final file = File(
      '${Directory.systemTemp.createTempSync().path}/cache.sqlite',
    );
    final first = AppDatabase(NativeDatabase(file));
    await first
        .into(first.myPlayers)
        .insert(MyPlayersCompanion.insert(playerId: '70', alias: 'Don Ramon'));
    Future<void> openApp(AppDatabase db) async {
      await tester.pumpWidget(
        AppProviders(
          apiClient: ApiClient(
            baseUrl: 'https://api.test',
            httpClient: MockClient((request) async {
              if (!online) throw http.ClientException('sin red');
              return answer(request);
            }),
          ),
          database: db,
          child: const FatFishApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    // First visit, online: the dossier and the ranking are saved on the device.
    await openApp(first);
    await tester.tap(tab('Ranking'));
    await tester.pumpAndSettle();
    expect(find.text('SIN CONEXIÓN'), findsNothing);

    // Next visit, offline: the same data, with the notice and its date.
    online = false;
    // Closing the providers closes the first database.
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await openApp(AppDatabase(NativeDatabase(file)));
    expect(find.text('EXPEDIENTE N.º 70'), findsOneWidget);
    expect(find.text('SIN CONEXIÓN'), findsOneWidget);
    expect(find.textContaining('Pueden estar desactualizados'), findsOneWidget);

    // Retrying while still offline spins, then says so at the bottom.
    await tester.tap(find.text('Reintentar'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text(const NetworkException().message), findsOneWidget);

    await tester.tap(tab('Ranking'));
    await tester.pumpAndSettle();
    expect(find.text('jugador_1'), findsWidgets);
    // The dossier tab stays alive behind; look only inside the ranking.
    expect(
      find.descendant(
        of: find.byType(RankingPage),
        matching: find.text('SIN CONEXIÓN'),
      ),
      findsOneWidget,
    );
  });

  group('game typography on narrow phones', () {
    setUpAll(() async {
      // Ahem hides real font metrics and can miss wrapping/overflow regressions.
      for (final family in [
        'Jersey10',
        'Jersey15',
        'FatFishPixel',
        'CourierPrime',
      ]) {
        final loader = FontLoader(family)
          ..addFont(rootBundle.load('assets/fonts/$family-Regular.ttf'));
        if (family == 'CourierPrime') {
          loader.addFont(rootBundle.load('assets/fonts/$family-Bold.ttf'));
        }
        await loader.load();
      }
    });

    for (final size in [const Size(320, 640), const Size(360, 800)]) {
      for (final scale in [1.0, 1.3, 2.0]) {
        for (final player in [false, true]) {
          testWidgets('$size, text $scale, saved player $player', (
            tester,
          ) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(() {
              tester.view.resetPhysicalSize();
              tester.view.resetDevicePixelRatio();
              tester.platformDispatcher.clearTextScaleFactorTestValue();
            });
            await pumpApp(tester, player: player);
            expect(tester.takeException(), isNull);

            if (player) {
              // The tab must wrap while keeping the change-player action usable.
              await tester.tap(find.text('Cambiar'));
              await tester.pumpAndSettle();
              expect(find.byType(TextField), findsOneWidget);
              await tester.tap(find.byTooltip('Volver'));
              await tester.pumpAndSettle();
              for (final name in ['Mesa', 'Ranking']) {
                await tester.tap(tab(name));
                await tester.pumpAndSettle();
                expect(tester.takeException(), isNull, reason: name);
              }
              await tester.tap(
                find.descendant(
                  of: find.byType(RankingPage),
                  matching: find.byTooltip('Ajustes'),
                ),
              );
              await tester.pumpAndSettle();
              expect(find.text('Sonidos de la mesa'), findsOneWidget);
              expect(tester.takeException(), isNull, reason: 'Ajustes');
              await tester.tap(find.byTooltip('Volver'));
              await tester.pumpAndSettle();
            } else {
              // Large text makes the welcome taller than the viewport.
              await tester.ensureVisible(find.text('Buscar mi jugador'));
              await tester.tap(find.text('Buscar mi jugador'));
              await tester.pumpAndSettle();
              await tester.enterText(find.byType(TextField), 'Ángel Muñoz');
              await tester.pump(const Duration(milliseconds: 400));
              await tester.pumpAndSettle();
              expect(find.text('Ángel Muñoz'), findsOneWidget);
              expect(tester.takeException(), isNull, reason: 'Mi jugador');
            }
            await tester.pumpWidget(const SizedBox());
            await tester.pumpAndSettle();
          });
        }
      }
    }
  });
}
