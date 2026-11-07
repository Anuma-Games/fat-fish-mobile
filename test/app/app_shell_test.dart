import 'package:drift/native.dart';
import 'package:fat_fish_mobile/app/app.dart';
import 'package:fat_fish_mobile/app/app_providers.dart';
import 'package:fat_fish_mobile/core/network/api_client.dart';
import 'package:fat_fish_mobile/core/storage/app_database.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/pixel_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  Finder tab(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  testWidgets('opens on the dossier and switches tabs', (tester) async {
    await tester.pumpWidget(
      AppProviders(
        apiClient: ApiClient(
          baseUrl: 'https://api.test',
          httpClient: MockClient((_) async => http.Response('[]', 200)),
        ),
        database: AppDatabase(NativeDatabase.memory()),
        child: const FatFishApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Elige tu jugador'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byType(PixelIcon),
      ),
      findsNWidgets(3),
    );
    // The Sentry test button only appears with SENTRY_TEST_BUTTON=true.
    expect(find.byType(FloatingActionButton), findsNothing);

    await tester.tap(tab('RANKING'));
    await tester.pumpAndSettle();
    expect(find.text('Ranking mundial'), findsOneWidget);

    await tester.tap(tab('MI JUGADOR'));
    await tester.pumpAndSettle();
    expect(find.text('Buscar por alias o ID'), findsOneWidget);
    expect(find.text('Sin elegir'), findsOneWidget);
  });

  testWidgets('the history opens over the dossier and goes back', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.myPlayers)
        .insert(MyPlayersCompanion.insert(playerId: '70', alias: 'Don Ramon'));
    final requests = <String>[];
    await tester.pumpWidget(
      AppProviders(
        apiClient: ApiClient(
          baseUrl: 'https://api.test',
          httpClient: MockClient((request) async {
            requests.add(request.url.path);
            return switch (request.url.path) {
              '/api/pwa/perfil' => http.Response(
                '{"jugadorId":"70","alias":"Don Ramon",'
                '"creadoEn":"2026-10-02T12:00:00Z","ultimaActividad":null,'
                '"estadisticas":{"partidasTotales":1,"partidasGanadas":0,'
                '"totalInvertido":500,"totalPerdido":500,'
                '"rachaDerrotasMax":1,"tiempoJugadoSeg":600},'
                '"generadoEn":"2026-11-07T12:00:00Z"}',
                200,
              ),
              _ => http.Response(
                '{"contenido":[{"id":"p1","resultado":"DERROTA",'
                '"rondaAlcanzada":2,"puntaje":144,"dineroInvertido":500,'
                '"dineroGanado":0,"dineroPerdido":500,"duracionSeg":600,'
                '"creadaEn":"2026-11-01T12:00:00Z"}],'
                '"pagina":0,"totalElementos":1,"ultima":true}',
                200,
              ),
            };
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

  testWidgets('choosing a player opens the dossier', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      AppProviders(
        apiClient: ApiClient(
          baseUrl: 'https://api.test',
          httpClient: MockClient(
            (request) async => switch (request.url.path) {
              '/api/pwa/jugadores' => http.Response(
                '[{"jugadorId":"70","alias":"Don Ramon","ultimaActividad":null}]',
                200,
              ),
              // The dossier opens next; its content is tested in expediente_page_test.
              _ => http.Response('', 404),
            },
          ),
        ),
        database: db,
        child: const FatFishApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(tab('MI JUGADOR'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'don');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Don Ramon'));
    // Pause on the gold row, then the tab fades to the dossier.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 0);
    expect((await db.select(db.myPlayers).getSingle()).playerId, '70');
    // Back on the tab, the search is clear and the card shows the player.
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
  });
}
