import 'dart:async';

import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/domain/repositories/player_repository.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/add_recent_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/get_recent_players.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/remove_recent_player.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/cubit/recent_players_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPlayerRepository extends Mock implements PlayerRepository {}

void main() {
  const player = PlayerSummary(id: '7', alias: 'Ñandú');
  late _MockPlayerRepository repository;

  setUpAll(() => registerFallbackValue(player));
  setUp(() => repository = _MockPlayerRepository());

  RecentPlayersCubit build() => RecentPlayersCubit(
    getRecentPlayers: GetRecentPlayers(repository),
    addRecentPlayer: AddRecentPlayer(repository),
    removeRecentPlayer: RemoveRecentPlayer(repository),
  );

  test('adds a player and shows the list again', () async {
    when(() => repository.addRecentPlayer(any())).thenAnswer((_) async {});
    when(() => repository.getRecentPlayers())
        .thenAnswer((_) async => const [player]);
    final cubit = build();

    await cubit.add(player);

    expect(cubit.state, const [player]);
    await cubit.close();
  });

  test('a screen closed while the list loads does not fail', () async {
    // Choosing a player leaves the screen before the list comes back.
    final list = Completer<List<PlayerSummary>>();
    when(() => repository.addRecentPlayer(any())).thenAnswer((_) async {});
    when(() => repository.getRecentPlayers()).thenAnswer((_) => list.future);
    final cubit = build();

    final adding = cubit.add(player);
    await cubit.close();
    list.complete(const [player]);

    await expectLater(adding, completes);
  });
}
