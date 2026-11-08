import 'dart:convert';

import 'package:fat_fish_mobile/core/network/api_client.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/features/ranking/data/datasources/ranking_remote_data_source.dart';
import 'package:fat_fish_mobile/features/ranking/data/repositories/ranking_repository_impl.dart';
import 'package:fat_fish_mobile/features/ranking/domain/entities/ranking.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late http.Request sent;

  RankingRepositoryImpl repositoryAnswering(Object? body) {
    final api = ApiClient(
      baseUrl: 'https://api.test',
      httpClient: MockClient((request) async {
        sent = request;
        return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
      }),
    );
    return RankingRepositoryImpl(remote: RankingRemoteDataSource(api));
  }

  Map<String, Object?> entry(int position, String id) => {
    'posicion': position,
    'jugadorId': id,
    'alias': 'jugador $id',
    'puntaje': 2000 - position,
    'logradoEn': '2026-10-13T22:00:00Z',
  };

  Map<String, Object?> body({Object? mine}) => {
    'pagina': {
      'contenido': [entry(1, '7'), entry(2, '9')],
      'pagina': 0,
      'tamano': 10,
      'totalElementos': 15,
      'totalPaginas': 2,
      'ultima': false,
      'generadoEn': '2026-11-07T23:42:01.8Z',
    },
    'miPosicion': mine,
  };

  test('asks for a page with the saved player and maps its place', () async {
    final repository = repositoryAnswering(body(mine: entry(27, '1042')));

    final ranking = await repository.getRanking(page: 0, playerId: '1042');

    expect(sent.url.path, '/api/pwa/ranking');
    expect(sent.url.queryParameters, {
      'pagina': '0',
      'tamano': '10',
      'jugadorId': '1042',
    });
    expect(ranking.page, 0);
    expect(ranking.totalPages, 2);
    expect(ranking.entries.map((e) => e.position), [1, 2]);
    expect(
      ranking.myPosition,
      RankingEntry(
        position: 27,
        playerId: '1042',
        alias: 'jugador 1042',
        score: 1973,
        achievedAt: DateTime.utc(2026, 10, 13, 22),
      ),
    );
  });

  test('leaves the player out of the query and the place null', () async {
    final repository = repositoryAnswering(body());

    final ranking = await repository.getRanking(page: 1);

    expect(sent.url.queryParameters, {'pagina': '1', 'tamano': '10'});
    expect(ranking.myPosition, isNull);
  });

  test('a body with another shape is an unexpected response', () async {
    final repository = repositoryAnswering([]);

    expect(
      repository.getRanking(page: 0),
      throwsA(isA<UnexpectedResponseException>()),
    );
  });
}
