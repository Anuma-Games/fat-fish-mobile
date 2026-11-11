import 'dart:convert';

import 'package:drift/native.dart';
import 'package:fat_fish_mobile/core/network/api_client.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/core/storage/app_database.dart';
import 'package:fat_fish_mobile/features/jugador/data/datasources/player_local_data_source.dart';
import 'package:fat_fish_mobile/features/jugador/data/datasources/player_remote_data_source.dart';
import 'package:fat_fish_mobile/features/jugador/data/repositories/player_repository_impl.dart';
import 'package:fat_fish_mobile/features/jugador/domain/entities/player_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late AppDatabase db;
  late http.Request sent;

  PlayerRepositoryImpl repositoryAnswering(Object? body) {
    final api = ApiClient(
      baseUrl: 'https://api.test',
      httpClient: MockClient((request) async {
        sent = request;
        return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
      }),
    );
    return PlayerRepositoryImpl(
      remote: PlayerRemoteDataSource(api),
      local: PlayerLocalDataSource(db),
    );
  }

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('searches by alias and maps the API fields', () async {
    final repository = repositoryAnswering([
      {
        'jugadorId': '7',
        'alias': 'Ñandú',
        'ultimaActividad': '2026-10-16T17:40:00Z',
      },
      {'jugadorId': '12', 'alias': 'Nadie', 'ultimaActividad': null},
    ]);

    final players = await repository.searchPlayers('nand');

    expect(sent.url.path, '/api/pwa/jugadores');
    expect(sent.url.queryParameters, {'busqueda': 'nand'});
    expect(players, [
      PlayerSummary(
        id: '7',
        alias: 'Ñandú',
        lastActivity: DateTime.utc(2026, 10, 16, 17, 40),
      ),
      const PlayerSummary(id: '12', alias: 'Nadie'),
    ]);
  });

  test('has no player until one is chosen', () async {
    final repository = repositoryAnswering([]);

    expect(await repository.getMyPlayer(), isNull);
  });

  test('keeps only the last chosen player', () async {
    final repository = repositoryAnswering([]);

    await repository.saveMyPlayer(const PlayerSummary(id: '7', alias: 'A'));
    await repository.saveMyPlayer(const PlayerSummary(id: '9', alias: 'B'));

    expect(
      await repository.getMyPlayer(),
      const PlayerSummary(id: '9', alias: 'B'),
    );
    expect(await db.select(db.myPlayers).get(), hasLength(1));
  });

  test('forgets the player when cleared', () async {
    final repository = repositoryAnswering([]);
    await repository.saveMyPlayer(const PlayerSummary(id: '7', alias: 'A'));

    await repository.clearMyPlayer();

    expect(await repository.getMyPlayer(), isNull);
  });

  group('recent players', () {
    test('keeps the newest six, newest first', () async {
      final repository = repositoryAnswering([]);

      for (var i = 1; i <= 7; i++) {
        await repository.addRecentPlayer(PlayerSummary(id: '$i', alias: 'J$i'));
      }

      final ids = (await repository.getRecentPlayers()).map((p) => p.id);
      expect(ids, ['7', '6', '5', '4', '3', '2']);
      expect(await db.select(db.recentPlayers).get(), hasLength(6));
    });

    test('moves a player tapped again to the top', () async {
      final repository = repositoryAnswering([]);
      await repository.addRecentPlayer(
        const PlayerSummary(id: '1', alias: 'A'),
      );
      await repository.addRecentPlayer(
        const PlayerSummary(id: '2', alias: 'B'),
      );

      await repository.addRecentPlayer(
        const PlayerSummary(id: '1', alias: 'A'),
      );

      final ids = (await repository.getRecentPlayers()).map((p) => p.id);
      expect(ids, ['1', '2']);
    });

    test('forgets a removed player', () async {
      final repository = repositoryAnswering([]);
      await repository.addRecentPlayer(
        const PlayerSummary(id: '1', alias: 'A'),
      );

      await repository.removeRecentPlayer('1');

      expect(await repository.getRecentPlayers(), isEmpty);
    });
  });

  test('turns a body with another shape into an ApiException', () {
    final repository = repositoryAnswering({'jugadores': []});

    expect(
      repository.searchPlayers('don'),
      throwsA(isA<UnexpectedResponseException>()),
    );
  });
}
