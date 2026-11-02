import 'dart:async';

import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/domain/repositories/player_repository.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/clear_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/get_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/save_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/cubit/my_player_cubit.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/pages/jugador_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPlayerRepository extends Mock implements PlayerRepository {}

void main() {
  const player = PlayerSummary(id: '70', alias: 'Don Ramon');

  testWidgets('shows the spinner in the field without moving the results', (
    tester,
  ) async {
    final repository = _MockPlayerRepository();
    final second = Completer<List<PlayerSummary>>();
    when(() => repository.getMyPlayer()).thenAnswer((_) async => null);
    when(() => repository.getRecentPlayers()).thenAnswer((_) async => []);
    when(() => repository.searchPlayers('don'))
        .thenAnswer((_) async => [player]);
    when(() => repository.searchPlayers('don r'))
        .thenAnswer((_) => second.future);

    await tester.pumpWidget(
      RepositoryProvider<PlayerRepository>.value(
        value: repository,
        child: BlocProvider(
          create: (_) => MyPlayerCubit(
            getMyPlayer: GetMyPlayer(repository),
            saveMyPlayer: SaveMyPlayer(repository),
            clearMyPlayer: ClearMyPlayer(repository),
          )..load(),
          child: const MaterialApp(home: JugadorPage()),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'don');
    await tester.pump(const Duration(milliseconds: 400));
    // Let the rows finish their entrance before measuring.
    await tester.pumpAndSettle();
    final before = tester.getTopLeft(find.textContaining('Ramon'));

    await tester.enterText(find.byType(TextField), 'don r');
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.descendant(
        of: find.byType(TextField),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.getTopLeft(find.textContaining('Ramon')), before);

    second.complete([player]);
    // The spinner fades out; once gone, the row that stayed did not re-enter.
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.getTopLeft(find.textContaining('Ramon')), before);
  });

  testWidgets('leaves your player out of the recent players', (tester) async {
    final repository = _MockPlayerRepository();
    const other = PlayerSummary(id: '68', alias: 'Otro');
    when(() => repository.getMyPlayer()).thenAnswer((_) async => player);
    when(() => repository.getRecentPlayers())
        .thenAnswer((_) async => [player, other]);

    await tester.pumpWidget(
      RepositoryProvider<PlayerRepository>.value(
        value: repository,
        child: BlocProvider(
          create: (_) => MyPlayerCubit(
            getMyPlayer: GetMyPlayer(repository),
            saveMyPlayer: SaveMyPlayer(repository),
            clearMyPlayer: ClearMyPlayer(repository),
          )..load(),
          child: const MaterialApp(home: JugadorPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Once in the card, never in the list.
    expect(find.textContaining('Don Ramon'), findsOneWidget);
    expect(find.text('RECIENTES'), findsOneWidget);
    expect(find.textContaining('Otro'), findsOneWidget);
  });
}
