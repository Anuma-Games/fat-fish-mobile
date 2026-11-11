import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/features/expediente/domain/entities/played_match.dart';
import 'package:fat_fish_mobile/features/expediente/domain/entities/player_profile.dart';
import 'package:fat_fish_mobile/features/expediente/domain/repositories/expediente_repository.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/expediente_scope.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/pages/expediente_page.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/pages/historial_page.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/widgets/match_row.dart';
import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/domain/repositories/player_repository.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/clear_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/get_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/save_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/cubit/my_player_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPlayerRepository extends Mock implements PlayerRepository {}

class _MockExpedienteRepository extends Mock implements ExpedienteRepository {}

void main() {
  const player = PlayerSummary(id: '7', alias: 'Ñandú');
  final profile = PlayerProfile(
    id: '7',
    alias: 'Ñandú',
    createdAt: DateTime(2026, 10),
    stats: const ProfileStats(
      totalMatches: 12,
      matchesWon: 3,
      moneyInvested: 4500,
      moneyLost: 3200,
      longestLosingStreak: 5,
      secondsPlayed: 7260,
    ),
    generatedAt: DateTime.utc(2026, 11, 2, 20, 5),
  );

  PlayedMatch playedMatch(String id, int round) => PlayedMatch(
    id: id,
    result: MatchResult.victory,
    roundReached: round,
    score: 1200,
    moneyInvested: 300,
    moneyWon: 900,
    moneyLost: 0,
    durationSeconds: 600,
    playedAt: DateTime.utc(2026, 11, 1, 12),
  );

  Finder round(int n) =>
      find.byWidgetPredicate((w) => w is RoundBadge && w.round == n);

  late _MockPlayerRepository players;
  late _MockExpedienteRepository expediente;

  setUp(() {
    players = _MockPlayerRepository();
    expediente = _MockExpedienteRepository();
    when(() => players.getMyPlayer()).thenAnswer((_) async => player);
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    Widget page = const ExpedientePage(),
  }) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<PlayerRepository>.value(value: players),
          RepositoryProvider<ExpedienteRepository>.value(value: expediente),
        ],
        child: BlocProvider(
          create: (_) => MyPlayerCubit(
            getMyPlayer: GetMyPlayer(players),
            saveMyPlayer: SaveMyPlayer(players),
            clearMyPlayer: ClearMyPlayer(players),
          )..load(),
          child: MaterialApp(home: ExpedienteScope(child: page)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('asks to choose a player when there is none', (tester) async {
    when(() => players.getMyPlayer()).thenAnswer((_) async => null);

    await pumpPage(tester);

    expect(find.textContaining('Elige tu jugador'), findsOneWidget);
    expect(find.text('Buscar mi jugador'), findsOneWidget);
    verifyZeroInteractions(expediente);
  });

  testWidgets('shows the sheet, the house cut and the recent matches', (
    tester,
  ) async {
    when(() => expediente.getProfile('7')).thenAnswer((_) async => profile);
    when(() => expediente.getMatches('7', page: 0)).thenAnswer(
      (_) async => MatchPage(
        matches: [for (var i = 1; i <= 5; i++) playedMatch('m$i', 10 + i)],
        page: 0,
        totalMatches: 12,
        isLast: false,
      ),
    );

    await pumpPage(tester);

    expect(find.text('EXPEDIENTE N.º 7'), findsOneWidget);
    expect(find.text('Ñandú'), findsOneWidget);
    expect(find.text('1 de octubre, 2026'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Ganaste 3'), findsOneWidget);
    expect(find.text(r'$3,200'), findsOneWidget);
    expect(find.text(r'De $4,500 invertidos'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('2 h 1 min'), findsOneWidget);
    expect(find.text('10 min por partida'), findsOneWidget);
    // 3,200 of 4,500: the house kept $71 of every $100.
    expect(
      find.textContaining(r'la casa se quedó con $71', findRichText: true),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(find.text('Ver las 12 partidas'), 200);
    expect(round(11), findsOneWidget);
    expect(round(13), findsOneWidget);
    // Only the three most recent; the rest are in the history.
    expect(round(14), findsNothing);
  });

  testWidgets('the history loads more matches until the first one', (
    tester,
  ) async {
    when(() => expediente.getProfile('7')).thenAnswer((_) async => profile);
    when(() => expediente.getMatches('7', page: 0)).thenAnswer(
      (_) async => MatchPage(
        matches: [playedMatch('a', 11)],
        page: 0,
        totalMatches: 2,
        isLast: false,
      ),
    );
    when(() => expediente.getMatches('7', page: 1)).thenAnswer(
      (_) async => MatchPage(
        matches: [playedMatch('b', 3)],
        page: 1,
        totalMatches: 2,
        isLast: true,
      ),
    );

    await pumpPage(tester, page: const HistorialPage());

    expect(find.text('Cada partida, anotada'), findsOneWidget);
    expect(round(11), findsOneWidget);
    expect(find.text(r'de $300'), findsOneWidget);
    await tester.tap(find.text('Ver más partidas'));
    await tester.pumpAndSettle();

    expect(round(3), findsOneWidget);
    expect(find.text('Ver más partidas'), findsNothing);
    expect(find.textContaining('Esa fue tu primera partida'), findsOneWidget);
  });

  testWidgets('says when the player has no matches yet', (tester) async {
    when(() => expediente.getProfile('7')).thenAnswer((_) async => profile);
    when(() => expediente.getMatches('7', page: 0)).thenAnswer(
      (_) async =>
          const MatchPage(matches: [], page: 0, totalMatches: 0, isLast: true),
    );

    await pumpPage(tester);
    await tester.scrollUntilVisible(
      find.text('Este jugador todavía no tiene partidas.'),
      200,
    );

    expect(
      find.text('Este jugador todavía no tiene partidas.'),
      findsOneWidget,
    );
    expect(find.text('Ver más partidas'), findsNothing);
  });

  testWidgets('offers another player when the saved one does not exist', (
    tester,
  ) async {
    when(() => expediente.getProfile('7'))
        .thenAnswer((_) async => throw const NotFoundException());
    when(() => expediente.getMatches('7', page: 0))
        .thenAnswer((_) async => throw const NotFoundException());

    await pumpPage(tester);

    expect(find.textContaining('No encontramos a Ñandú (#7)'), findsOneWidget);
    expect(find.text('Elegir otro jugador'), findsOneWidget);
  });

  testWidgets('retries after a network error', (tester) async {
    var online = false;
    when(() => expediente.getProfile('7')).thenAnswer(
      (_) async => online ? profile : throw const NetworkException(),
    );
    when(() => expediente.getMatches('7', page: 0)).thenAnswer(
      (_) async =>
          const MatchPage(matches: [], page: 0, totalMatches: 0, isLast: true),
    );

    await pumpPage(tester);
    expect(find.text(const NetworkException().message), findsOneWidget);

    online = true;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Ñandú'), findsOneWidget);
    expect(find.text('Reintentar'), findsNothing);
  });

  testWidgets('a failed "Ver más" keeps the list and shows the error', (
    tester,
  ) async {
    when(() => expediente.getProfile('7')).thenAnswer((_) async => profile);
    when(() => expediente.getMatches('7', page: 0)).thenAnswer(
      (_) async => MatchPage(
        matches: [playedMatch('a', 11)],
        page: 0,
        totalMatches: 2,
        isLast: false,
      ),
    );
    when(() => expediente.getMatches('7', page: 1))
        .thenAnswer((_) async => throw const NetworkException());

    await pumpPage(tester, page: const HistorialPage());
    await tester.tap(find.text('Ver más partidas'));
    await tester.pumpAndSettle();

    expect(round(11), findsOneWidget);
    expect(find.text(const NetworkException().message), findsOneWidget);
    expect(find.text('Ver más partidas'), findsOneWidget);
  });

  testWidgets('offline, the history waits for a connection to show more', (
    tester,
  ) async {
    final saved = PlayerProfile(
      id: profile.id,
      alias: profile.alias,
      createdAt: profile.createdAt,
      stats: profile.stats,
      generatedAt: profile.generatedAt,
      savedAt: DateTime(2026, 11, 3, 18, 42),
    );
    when(() => expediente.getProfile('7')).thenAnswer((_) async => saved);
    when(() => expediente.getMatches('7', page: 0)).thenAnswer(
      (_) async => MatchPage(
        matches: [playedMatch('a', 11)],
        page: 0,
        totalMatches: 12,
        isLast: false,
      ),
    );

    await pumpPage(tester, page: const HistorialPage());

    expect(find.text('SIN CONEXIÓN'), findsOneWidget);
    expect(
      find.textContaining('3 de noviembre, 2026, a las 18:42'),
      findsOneWidget,
    );
    expect(find.text('Ver más partidas'), findsNothing);
    expect(
      find.textContaining('El historial guardado tiene 1 de 12 partidas'),
      findsOneWidget,
    );
  });
}
