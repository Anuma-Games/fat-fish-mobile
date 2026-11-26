import 'package:fat_fish_mobile/app/theme/app_theme.dart';
import 'package:fat_fish_mobile/core/theme/tokens.dart';
import 'package:fat_fish_mobile/core/presentation/widgets/paper.dart';
import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/domain/repositories/player_repository.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/clear_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/get_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/save_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/cubit/my_player_cubit.dart';
import 'package:fat_fish_mobile/features/ranking/domain/entities/ranking.dart';
import 'package:fat_fish_mobile/features/ranking/domain/repositories/ranking_repository.dart';
import 'package:fat_fish_mobile/features/ranking/presentation/pages/ranking_page.dart';
import 'package:fat_fish_mobile/features/ranking/presentation/widgets/podium.dart';
import 'package:fat_fish_mobile/features/ranking/presentation/widgets/ranking_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPlayerRepository extends Mock implements PlayerRepository {}

class _MockRankingRepository extends Mock implements RankingRepository {}

void main() {
  const player = PlayerSummary(id: '1042', alias: 'pezgordo');

  RankingEntry entry(int position) => RankingEntry(
    position: position,
    playerId: '$position',
    alias: 'jugador_$position',
    score: 2000 - position,
    achievedAt: DateTime.utc(2026, 10),
  );

  Ranking page(int index, {RankingEntry? mine}) => Ranking(
    entries: [for (var i = 1; i <= 10; i++) entry(index * 10 + i)],
    page: index,
    totalPages: 2,
    myPosition: mine,
  );

  late _MockPlayerRepository players;
  late _MockRankingRepository ranking;

  setUp(() {
    players = _MockPlayerRepository();
    ranking = _MockRankingRepository();
    when(() => players.getMyPlayer()).thenAnswer((_) async => player);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<PlayerRepository>.value(value: players),
          RepositoryProvider<RankingRepository>.value(value: ranking),
        ],
        child: BlocProvider(
          create: (_) => MyPlayerCubit(
            getMyPlayer: GetMyPlayer(players),
            saveMyPlayer: SaveMyPlayer(players),
            clearMyPlayer: ClearMyPlayer(players),
          )..load(),
          child: MaterialApp(
            theme: buildFatFishTheme(),
            home: const RankingPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder row(int position) => find.byWidgetPredicate(
    (w) => w is RankingRow && w.entry.position == position,
  );

  testWidgets('first page: your place, the podium and the rest in rows', (
    tester,
  ) async {
    when(() => ranking.getRanking(page: 0, playerId: '1042'))
        .thenAnswer((_) async => page(0, mine: entry(27)));

    await pumpPage(tester);

    expect(find.text('Las mejores partidas'), findsOneWidget);
    expect(find.text('Tu mejor victoria'), findsOneWidget);
    expect(find.text('pezgordo'), findsOneWidget);
    expect(find.text('27'), findsOneWidget);
    final podium = find.byType(Podium);
    expect(
      find.descendant(of: podium, matching: find.text('jugador_1')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: podium, matching: find.text('jugador_3')),
      findsOneWidget,
    );
    // The first three are on the podium, not in the list.
    expect(row(3), findsNothing);
    expect(row(4), findsOneWidget);
  });

  testWidgets('the second page has no podium and no place card', (
    tester,
  ) async {
    when(() => ranking.getRanking(page: 0, playerId: '1042'))
        .thenAnswer((_) async => page(0, mine: entry(27)));
    when(() => ranking.getRanking(page: 1, playerId: '1042'))
        .thenAnswer((_) async => page(1, mine: entry(27)));

    await pumpPage(tester);
    // The pedestal of second place also says 2.
    final pageTwo = find.widgetWithText(OutlinedButton, '2');
    await tester.scrollUntilVisible(pageTwo, 200);
    await tester.tap(pageTwo);
    await tester.pumpAndSettle();

    expect(find.byType(Podium), findsNothing);
    expect(find.text('Tu mejor victoria'), findsNothing);
    expect(row(11), findsOneWidget);
  });

  testWidgets('a player without wins is told how to enter', (tester) async {
    when(() => ranking.getRanking(page: 0, playerId: '1042'))
        .thenAnswer((_) async => page(0));

    await pumpPage(tester);

    expect(find.text('Gana una partida para entrar.'), findsOneWidget);
  });

  testWidgets('explains points on demand without changing the ranking', (
    tester,
  ) async {
    when(() => ranking.getRanking(page: 0, playerId: '1042'))
        .thenAnswer((_) async => page(0, mine: entry(27)));

    tester.view.physicalSize = const Size(360, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpPage(tester);

    final explanation = find.textContaining('no se suman tus partidas');
    expect(explanation, findsNothing);
    await tester.tap(find.byTooltip('Cómo funciona el ranking'));
    await tester.pumpAndSettle();
    expect(explanation, findsOneWidget);
    final dialog = find.byType(Dialog);
    expect(
      find.descendant(of: dialog, matching: find.byType(RuledPaper)),
      findsOneWidget,
    );
    final content = tester.widget<Text>(explanation);
    expect(content.style?.fontFamily, FatFishFonts.body);
    expect(content.style?.fontSize, 20);
    expect(content.style?.color, FatFishColors.ink900);
    final title = tester.widget<Text>(find.text('¿Cómo subir posiciones?'));
    expect(title.style?.fontFamily, FatFishFonts.display);
    expect(find.text('NOTA DE LA CASA'), findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.text('RANKING')),
      findsOneWidget,
    );
    expect(title.style?.color, FatFishColors.ink900);
    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();
    expect(explanation, findsNothing);
    expect(find.text('Tu mejor victoria'), findsOneWidget);
    verify(() => ranking.getRanking(page: 0, playerId: '1042')).called(1);
  });

  testWidgets('without a saved player there is no place card', (tester) async {
    when(() => players.getMyPlayer()).thenAnswer((_) async => null);
    when(() => ranking.getRanking(page: 0)).thenAnswer((_) async => page(0));

    await pumpPage(tester);

    expect(find.byType(Podium), findsOneWidget);
    expect(find.text('Tu mejor victoria'), findsNothing);
    expect(find.text('Gana una partida para entrar.'), findsNothing);
  });
}
