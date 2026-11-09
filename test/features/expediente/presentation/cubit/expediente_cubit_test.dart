import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/features/expediente/domain/entities/played_match.dart';
import 'package:fat_fish_mobile/features/expediente/domain/entities/player_profile.dart';
import 'package:fat_fish_mobile/features/expediente/domain/repositories/expediente_repository.dart';
import 'package:fat_fish_mobile/features/expediente/domain/usecases/get_matches.dart';
import 'package:fat_fish_mobile/features/expediente/domain/usecases/get_profile.dart';
import 'package:fat_fish_mobile/features/expediente/presentation/cubit/expediente_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockExpedienteRepository extends Mock implements ExpedienteRepository {}

final profile = PlayerProfile(
  id: '7',
  alias: 'Ñandú',
  createdAt: DateTime.utc(2026, 10),
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

PlayedMatch playedMatch(String id, {int round = 4}) => PlayedMatch(
  id: id,
  result: MatchResult.defeat,
  roundReached: round,
  score: 1200,
  moneyInvested: 300,
  moneyWon: 0,
  moneyLost: 300,
  durationSeconds: 600,
  playedAt: DateTime.utc(2026, 11, 1),
);

MatchPage matchPage(
  List<PlayedMatch> matches, {
  int page = 0,
  int total = 12,
  bool isLast = false,
}) => MatchPage(
  matches: matches,
  page: page,
  totalMatches: total,
  isLast: isLast,
);

void main() {
  late _MockExpedienteRepository repository;

  ExpedienteCubit build() => ExpedienteCubit(
    playerId: '7',
    getProfile: GetProfile(repository),
    getMatches: GetMatches(repository),
    // The spinner wait is for people; the tests do not need it.
    minimumWait: Duration.zero,
  );

  final first = [playedMatch('a'), playedMatch('b')];
  final loaded = ExpedienteLoaded(
    profile: profile,
    matches: first,
    page: 0,
    totalMatches: 4,
    hasMore: true,
  );

  void answerFirstPage() {
    when(() => repository.getProfile('7')).thenAnswer((_) async => profile);
    when(() => repository.getMatches('7', page: 0))
        .thenAnswer((_) async => matchPage(first, total: 4));
  }

  setUp(() => repository = _MockExpedienteRepository());

  blocTest<ExpedienteCubit, ExpedienteState>(
    'loads the profile and the first page together',
    setUp: answerFirstPage,
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [const ExpedienteLoading(), loaded],
  );

  blocTest<ExpedienteCubit, ExpedienteState>(
    'says when the player does not exist',
    setUp: () {
      when(() => repository.getProfile('7'))
          .thenThrow(const NotFoundException());
      when(() => repository.getMatches('7', page: 0))
          .thenAnswer((_) async => throw const NotFoundException());
    },
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [const ExpedienteLoading(), const ExpedienteNotFound()],
  );

  blocTest<ExpedienteCubit, ExpedienteState>(
    'shows the network error on the first load',
    setUp: () {
      when(() => repository.getProfile('7'))
          .thenAnswer((_) async => throw const NetworkException());
      when(() => repository.getMatches('7', page: 0))
          .thenAnswer((_) async => matchPage(first));
    },
    build: build,
    act: (cubit) => cubit.load(),
    expect: () => [
      const ExpedienteLoading(),
      ExpedienteFailure(const NetworkException().message),
    ],
  );

  blocTest<ExpedienteCubit, ExpedienteState>(
    'appends the next page and stops at the last one',
    setUp: () => when(() => repository.getMatches('7', page: 1)).thenAnswer(
      (_) async => matchPage(
        [playedMatch('c'), playedMatch('d')],
        page: 1,
        total: 4,
        isLast: true,
      ),
    ),
    build: build,
    seed: () => loaded,
    act: (cubit) => cubit.loadMore(),
    expect: () => [
      loaded.copyWith(loadingMore: true),
      loaded.copyWith(
        matches: [...first, playedMatch('c'), playedMatch('d')],
        page: 1,
        hasMore: false,
      ),
    ],
  );

  blocTest<ExpedienteCubit, ExpedienteState>(
    'drops a match repeated between two pages',
    setUp: () => when(() => repository.getMatches('7', page: 1)).thenAnswer(
      (_) async =>
          matchPage([playedMatch('b'), playedMatch('c')], page: 1, total: 5),
    ),
    build: build,
    seed: () => loaded,
    act: (cubit) => cubit.loadMore(),
    skip: 1,
    expect: () => [
      loaded.copyWith(
        matches: [...first, playedMatch('c')],
        page: 1,
        totalMatches: 5,
      ),
    ],
  );

  blocTest<ExpedienteCubit, ExpedienteState>(
    'keeps the matches and reports the error when "Ver más" fails',
    setUp: () =>
        when(() => repository.getMatches('7', page: 1))
            .thenAnswer((_) async => throw const NetworkException()),
    build: build,
    seed: () => loaded,
    act: (cubit) => cubit.loadMore(),
    expect: () => [
      loaded.copyWith(loadingMore: true),
      loaded.copyWith(failure: const NetworkException().message),
    ],
  );

  blocTest<ExpedienteCubit, ExpedienteState>(
    'asks for one page at a time',
    setUp: () {
      final pending = Completer<MatchPage>();
      when(() => repository.getMatches('7', page: 1))
          .thenAnswer((_) => pending.future);
    },
    build: build,
    seed: () => loaded,
    act: (cubit) {
      cubit.loadMore();
      cubit.loadMore();
    },
    verify: (_) => verify(() => repository.getMatches('7', page: 1)).called(1),
  );

  blocTest<ExpedienteCubit, ExpedienteState>(
    'a failed refresh keeps the dossier on screen',
    setUp: () {
      when(() => repository.getProfile('7'))
          .thenAnswer((_) async => throw const NetworkException());
      when(() => repository.getMatches('7', page: 0))
          .thenAnswer((_) async => matchPage(first));
    },
    build: build,
    seed: () => loaded,
    act: (cubit) => cubit.refresh(),
    expect: () => [loaded.copyWith(failure: const NetworkException().message)],
  );

  blocTest<ExpedienteCubit, ExpedienteState>(
    'reports a second failed refresh in a row',
    setUp: () {
      when(() => repository.getProfile('7'))
          .thenAnswer((_) async => throw const NetworkException());
      when(() => repository.getMatches('7', page: 0))
          .thenAnswer((_) async => matchPage(first));
    },
    build: build,
    seed: () => loaded.copyWith(failure: const NetworkException().message),
    act: (cubit) => cubit.refresh(),
    expect: () => [
      loaded,
      loaded.copyWith(failure: const NetworkException().message),
    ],
  );

  blocTest<ExpedienteCubit, ExpedienteState>(
    'ignores "Ver más" while a refresh is on its way',
    setUp: () {
      final pending = Completer<PlayerProfile>();
      when(() => repository.getProfile('7')).thenAnswer((_) => pending.future);
      when(() => repository.getMatches('7', page: 0))
          .thenAnswer((_) async => matchPage(first));
    },
    build: build,
    seed: () => loaded,
    act: (cubit) {
      unawaited(cubit.refresh());
      cubit.loadMore();
    },
    verify: (_) => verifyNever(() => repository.getMatches('7', page: 1)),
  );

  blocTest<ExpedienteCubit, ExpedienteState>(
    'a refresh drops the page of a "Ver más" still on its way',
    setUp: () {
      answerFirstPage();
      final late = Completer<MatchPage>();
      when(() => repository.getMatches('7', page: 1))
          .thenAnswer((_) => late.future);
      // Completes after the refresh, with a page that no longer fits.
      Future<void>.delayed(
        const Duration(milliseconds: 10),
        () => late.complete(matchPage([playedMatch('x')], page: 1)),
      );
    },
    build: build,
    seed: () => loaded,
    act: (cubit) async {
      unawaited(cubit.loadMore());
      await cubit.refresh();
    },
    wait: const Duration(milliseconds: 20),
    expect: () => [loaded.copyWith(loadingMore: true), loaded],
  );

  blocTest<ExpedienteCubit, ExpedienteState>(
    'a refresh that only finds the saved copy says it is still offline',
    setUp: () {
      when(() => repository.getProfile('7')).thenAnswer(
        (_) async => PlayerProfile(
          id: profile.id,
          alias: profile.alias,
          createdAt: profile.createdAt,
          stats: profile.stats,
          generatedAt: profile.generatedAt,
          savedAt: DateTime(2026, 11, 3, 18, 42),
        ),
      );
      when(() => repository.getMatches('7', page: 0))
          .thenAnswer((_) async => matchPage(first, total: 4));
    },
    build: build,
    seed: () => loaded,
    act: (cubit) => cubit.refresh(),
    expect: () => [
      isA<ExpedienteLoaded>()
          .having((s) => s.profile.savedAt, 'savedAt', isNotNull)
          .having(
            (s) => s.failure,
            'failure',
            const NetworkException().message,
          ),
    ],
  );
}
