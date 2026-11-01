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

    expect(find.text('Lo que el casino sabe de ti'), findsOneWidget);
    expect(find.byType(PixelIcon), findsNWidgets(3));

    await tester.tap(tab('RANKING'));
    await tester.pumpAndSettle();
    expect(find.text('Ranking mundial'), findsOneWidget);

    await tester.tap(tab('MI JUGADOR'));
    await tester.pumpAndSettle();
    expect(find.text('Buscar por alias o ID'), findsOneWidget);
    expect(find.text('Sin elegir'), findsOneWidget);
  });

  testWidgets('choosing a player opens the dossier', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      AppProviders(
        apiClient: ApiClient(
          baseUrl: 'https://api.test',
          httpClient: MockClient(
            (_) async => http.Response(
              '[{"jugadorId":"70","alias":"Don Ramon","ultimaActividad":null}]',
              200,
            ),
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
