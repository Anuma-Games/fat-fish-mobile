import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/features/ranking/domain/entities/ranking.dart';
import 'package:fat_fish_mobile/features/ranking/domain/repositories/ranking_repository.dart';
import 'package:fat_fish_mobile/features/ranking/domain/usecases/get_ranking.dart';
import 'package:fat_fish_mobile/features/ranking/presentation/cubit/ranking_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRankingRepository extends Mock implements RankingRepository {}

Ranking rankingPage(int page, {int total = 3}) => Ranking(
  entries: [
    RankingEntry(
      position: page * 10 + 1,
      playerId: '${page * 10 + 1}',
      alias: 'jugador',
      score: 900,
      achievedAt: DateTime.utc(2026, 10),
    ),
  ],
  page: page,
  totalPages: total,
);

void main() {
  late _MockRankingRepository repository;

  RankingCubit build() =>
      RankingCubit(getRanking: GetRanking(repository), playerId: '7');

  setUp(() => repository = _MockRankingRepository());

  blocTest<RankingCubit, RankingState>(
    'loads the first page with the place of the player',
    setUp: () =>
        when(() => repository.getRanking(page: 0, playerId: '7'))
            .thenAnswer((_) async => rankingPage(0)),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      const RankingLoading(),
      RankingLoaded(ranking: rankingPage(0)),
    ],
  );

  blocTest<RankingCubit, RankingState>(
    'keeps the current page on screen while the next one loads',
    setUp: () =>
        when(() => repository.getRanking(page: 2, playerId: '7'))
            .thenAnswer((_) async => rankingPage(2)),
    build: build,
    seed: () => RankingLoaded(ranking: rankingPage(0)),
    act: (cubit) => cubit.goToPage(2),
    expect: () => [
      RankingLoaded(ranking: rankingPage(0), loadingPage: 2),
      RankingLoaded(ranking: rankingPage(2)),
    ],
  );

  blocTest<RankingCubit, RankingState>(
    'ignores pages out of range and the page on screen',
    build: build,
    seed: () => RankingLoaded(ranking: rankingPage(0)),
    act: (cubit) async {
      await cubit.goToPage(-1);
      await cubit.goToPage(3);
      await cubit.goToPage(0);
    },
    expect: () => <RankingState>[],
    verify: (_) => verifyZeroInteractions(repository),
  );

  blocTest<RankingCubit, RankingState>(
    'a failed page keeps the one on screen and reports the error',
    setUp: () =>
        when(() => repository.getRanking(page: 1, playerId: '7'))
            .thenAnswer((_) async => throw const NetworkException()),
    build: build,
    seed: () => RankingLoaded(ranking: rankingPage(0)),
    act: (cubit) => cubit.goToPage(1),
    expect: () => [
      RankingLoaded(ranking: rankingPage(0), loadingPage: 1),
      RankingLoaded(
        ranking: rankingPage(0),
        failure: const NetworkException().message,
      ),
    ],
  );

  blocTest<RankingCubit, RankingState>(
    'a failed first load shows the error',
    setUp: () =>
        when(() => repository.getRanking(page: 0, playerId: '7'))
            .thenAnswer((_) async => throw const NetworkException()),
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      const RankingLoading(),
      RankingFailure(const NetworkException().message),
    ],
  );

  blocTest<RankingCubit, RankingState>(
    'only the last page asked for is shown',
    setUp: () {
      final slow = Completer<Ranking>();
      when(() => repository.getRanking(page: 1, playerId: '7'))
          .thenAnswer((_) => slow.future);
      when(() => repository.getRanking(page: 2, playerId: '7'))
          .thenAnswer((_) async {
            // Page 1 answers after page 2 was asked for.
            slow.complete(rankingPage(1));
            return rankingPage(2);
          });
    },
    build: build,
    seed: () => RankingLoaded(ranking: rankingPage(0)),
    act: (cubit) async {
      unawaited(cubit.goToPage(1));
      await cubit.goToPage(2);
    },
    expect: () => [
      RankingLoaded(ranking: rankingPage(0), loadingPage: 1),
      RankingLoaded(ranking: rankingPage(0), loadingPage: 2),
      RankingLoaded(ranking: rankingPage(2)),
    ],
  );

  blocTest<RankingCubit, RankingState>(
    'reports a second failed refresh in a row',
    setUp: () =>
        when(() => repository.getRanking(page: 0, playerId: '7'))
            .thenAnswer((_) async => throw const NetworkException()),
    build: build,
    seed: () => RankingLoaded(
      ranking: rankingPage(0),
      failure: const NetworkException().message,
    ),
    act: (cubit) => cubit.refresh(),
    expect: () => [
      RankingLoaded(ranking: rankingPage(0)),
      RankingLoaded(
        ranking: rankingPage(0),
        failure: const NetworkException().message,
      ),
    ],
  );

  blocTest<RankingCubit, RankingState>(
    'a refresh while a page loads asks for that page',
    setUp: () =>
        when(() => repository.getRanking(page: 2, playerId: '7'))
            .thenAnswer((_) async => rankingPage(2)),
    build: build,
    seed: () => RankingLoaded(ranking: rankingPage(0), loadingPage: 2),
    act: (cubit) => cubit.refresh(),
    expect: () => [RankingLoaded(ranking: rankingPage(2))],
    verify: (_) =>
        verifyNever(() => repository.getRanking(page: 0, playerId: '7')),
  );
}
