import 'package:drift/native.dart';
import 'package:fat_fish_mobile/app/app.dart';
import 'package:fat_fish_mobile/app/app_providers.dart';
import 'package:fat_fish_mobile/app/nav_bar.dart';
import 'package:fat_fish_mobile/core/network/api_client.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/status_bar_blur.dart';
import 'package:fat_fish_mobile/core/storage/app_database.dart';
import 'package:flutter/material.dart';
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
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
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
        child: const FatFishApp(),
      ),
    );
    await tester.pumpAndSettle();
    return db;
  }

  testWidgets('without a player it opens the welcome, not the dossier', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.bySemanticsLabel('Fat Fish'), findsOneWidget);
    expect(find.byType(FatFishNavBar), findsNothing);

    await tester.tap(find.text('Ver el ranking mundial'));
    await tester.pumpAndSettle();
    expect(find.text('Mejores puntajes'), findsOneWidget);

    // The dossier needs a player: its tab leads back to the welcome.
    await tester.tap(tab('Expediente'));
    await tester.pumpAndSettle();
    expect(find.text('Buscar mi jugador'), findsOneWidget);
  });

  testWidgets('choosing a player opens the dossier', (tester) async {
    final db = await pumpApp(tester);

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

  testWidgets('switches tabs by tapping and by sliding along the bar', (
    tester,
  ) async {
    await pumpApp(tester, player: true);
    int open() =>
        tester.widget<FatFishNavBar>(find.byType(FatFishNavBar)).currentIndex;

    await tester.tap(tab('Mesa'));
    await tester.pumpAndSettle();
    expect(open(), 1);
    expect(find.text('Toma asiento'), findsOneWidget);

    // Slide from the table to the ranking and lift the finger there.
    final from = tester.getCenter(tab('Mesa'));
    final to = tester.getCenter(tab('Ranking'));
    await tester.dragFrom(from, to - from);
    await tester.pumpAndSettle();
    expect(open(), 2);
    expect(find.text('Mejores puntajes'), findsOneWidget);
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

    await tester.drag(find.text('Mejores puntajes'), const Offset(0, -300));
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
}
