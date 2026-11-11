import 'package:bloc_test/bloc_test.dart';
import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/domain/repositories/player_repository.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/clear_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/get_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/save_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/cubit/my_player_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPlayerRepository extends Mock implements PlayerRepository {}

void main() {
  const player = PlayerSummary(id: '7', alias: 'Ñandú');
  late _MockPlayerRepository repository;

  MyPlayerCubit build() => MyPlayerCubit(
    getMyPlayer: GetMyPlayer(repository),
    saveMyPlayer: SaveMyPlayer(repository),
    clearMyPlayer: ClearMyPlayer(repository),
  );

  setUpAll(() => registerFallbackValue(player));
  setUp(() => repository = _MockPlayerRepository());

  blocTest<MyPlayerCubit, MyPlayerState>(
    'loads the saved player',
    setUp: () =>
        when(() => repository.getMyPlayer()).thenAnswer((_) async => player),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [const MyPlayerChosen(player)],
  );

  blocTest<MyPlayerCubit, MyPlayerState>(
    'reports no player when none is saved',
    setUp: () =>
        when(() => repository.getMyPlayer()).thenAnswer((_) async => null),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [const MyPlayerNone()],
  );

  blocTest<MyPlayerCubit, MyPlayerState>(
    'saves the chosen player',
    setUp: () =>
        when(() => repository.saveMyPlayer(any())).thenAnswer((_) async {}),
    build: build,
    act: (cubit) => cubit.choose(player),
    expect: () => [const MyPlayerChosen(player)],
    verify: (_) => verify(() => repository.saveMyPlayer(player)).called(1),
  );

  blocTest<MyPlayerCubit, MyPlayerState>(
    'clears the player',
    setUp: () =>
        when(() => repository.clearMyPlayer()).thenAnswer((_) async {}),
    build: build,
    act: (cubit) => cubit.clear(),
    expect: () => [const MyPlayerNone()],
  );
}
