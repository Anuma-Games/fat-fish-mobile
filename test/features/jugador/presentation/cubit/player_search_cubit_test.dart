import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:fat_fish_mobile/features/jugador/domain/repositories/player_repository.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/search_players.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/cubit/player_search_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPlayerRepository extends Mock implements PlayerRepository {}

void main() {
  const player = PlayerSummary(id: '7', alias: 'Ñandú');
  late _MockPlayerRepository repository;

  PlayerSearchCubit build() =>
      PlayerSearchCubit(searchPlayers: SearchPlayers(repository));

  setUp(() => repository = _MockPlayerRepository());

  blocTest<PlayerSearchCubit, PlayerSearchState>(
    'shows the players found',
    setUp: () =>
        when(() => repository.searchPlayers(any()))
            .thenAnswer((_) async => [player]),
    build: build,
    act: (cubit) => cubit.search('nandu'),
    expect: () => [
      const PlayerSearchLoading(),
      const PlayerSearchLoaded([player]),
    ],
  );

  blocTest<PlayerSearchCubit, PlayerSearchState>(
    'trims the text before asking the API',
    setUp: () =>
        when(() => repository.searchPlayers(any()))
            .thenAnswer((_) async => [player]),
    build: build,
    act: (cubit) => cubit.search('  nandu '),
    verify: (_) => verify(() => repository.searchPlayers('nandu')).called(1),
  );

  blocTest<PlayerSearchCubit, PlayerSearchState>(
    'ends in empty when nobody matches',
    setUp: () =>
        when(() => repository.searchPlayers(any())).thenAnswer((_) async => []),
    build: build,
    act: (cubit) => cubit.search('nadie'),
    expect: () => [
      const PlayerSearchLoading(),
      const PlayerSearchEmpty('nadie'),
    ],
  );

  blocTest<PlayerSearchCubit, PlayerSearchState>(
    'does not call the API for blank text',
    build: build,
    act: (cubit) => cubit.search('   '),
    expect: () => [const PlayerSearchInitial()],
    verify: (_) => verifyNever(() => repository.searchPlayers(any())),
  );

  blocTest<PlayerSearchCubit, PlayerSearchState>(
    'shows the API error message',
    setUp: () =>
        when(() => repository.searchPlayers(any()))
            .thenThrow(const NetworkException()),
    build: build,
    act: (cubit) => cubit.search('nandu'),
    expect: () => [
      const PlayerSearchLoading(),
      PlayerSearchFailure(const NetworkException().message),
    ],
  );
  blocTest<PlayerSearchCubit, PlayerSearchState>(
    'drops a late answer from an older search',
    setUp: () {
      final slow = Completer<List<PlayerSummary>>();
      when(() => repository.searchPlayers('vieja'))
          .thenAnswer((_) => slow.future);
      when(() => repository.searchPlayers('nueva')).thenAnswer((_) async {
        // The older search answers after the newer one has finished.
        scheduleMicrotask(() => slow.complete([player]));
        return [];
      });
    },
    build: build,
    act: (cubit) async {
      unawaited(cubit.search('vieja'));
      await cubit.search('nueva');
      await Future<void>.delayed(Duration.zero);
    },
    expect: () => [
      const PlayerSearchLoading(),
      const PlayerSearchEmpty('nueva'),
    ],
  );
  group('while typing', () {
    PlayerSearchCubit buildFast() => PlayerSearchCubit(
      searchPlayers: SearchPlayers(repository),
      debounce: const Duration(milliseconds: 10),
    );

    blocTest<PlayerSearchCubit, PlayerSearchState>(
      'asks the API once, with the text after the last keystroke',
      setUp: () =>
          when(() => repository.searchPlayers(any()))
              .thenAnswer((_) async => [player]),
      build: buildFast,
      act: (cubit) {
        cubit.queryChanged('n');
        cubit.queryChanged('na');
        cubit.queryChanged('nan');
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        const PlayerSearchLoading(),
        const PlayerSearchLoaded([player]),
      ],
      verify: (_) {
        verify(() => repository.searchPlayers('nan')).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest<PlayerSearchCubit, PlayerSearchState>(
      'enter cancels the pending search',
      setUp: () =>
          when(() => repository.searchPlayers(any()))
              .thenAnswer((_) async => [player]),
      build: buildFast,
      act: (cubit) async {
        cubit.queryChanged('nan');
        await cubit.search('nandu');
      },
      wait: const Duration(milliseconds: 50),
      verify: (_) {
        verify(() => repository.searchPlayers('nandu')).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest<PlayerSearchCubit, PlayerSearchState>(
      'goes back to the card at once when the text is erased',
      build: buildFast,
      seed: () => const PlayerSearchLoaded([player]),
      act: (cubit) => cubit.queryChanged(''),
      expect: () => [const PlayerSearchInitial()],
    );

    blocTest<PlayerSearchCubit, PlayerSearchState>(
      'drops the pending search when the text gets too short',
      build: buildFast,
      act: (cubit) {
        cubit.queryChanged('ab');
        cubit.queryChanged('a');
      },
      wait: const Duration(milliseconds: 50),
      expect: () => <PlayerSearchState>[],
      verify: (_) => verifyNever(() => repository.searchPlayers(any())),
    );

    blocTest<PlayerSearchCubit, PlayerSearchState>(
      'waits for a second letter, but searches a one-digit number',
      setUp: () =>
          when(() => repository.searchPlayers(any()))
              .thenAnswer((_) async => [player]),
      build: buildFast,
      act: (cubit) async {
        cubit.queryChanged('a');
        await Future<void>.delayed(const Duration(milliseconds: 30));
        cubit.queryChanged('7');
      },
      wait: const Duration(milliseconds: 50),
      verify: (_) {
        verify(() => repository.searchPlayers('7')).called(1);
        verifyNoMoreInteractions(repository);
      },
    );
  });
}
