import 'dart:convert';

import 'package:fat_fish_mobile/core/network/api_client.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/features/expediente/data/datasources/expediente_remote_data_source.dart';
import 'package:fat_fish_mobile/features/expediente/data/repositories/expediente_repository_impl.dart';
import 'package:fat_fish_mobile/features/expediente/domain/entities/played_match.dart';
import 'package:fat_fish_mobile/features/expediente/domain/entities/player_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late http.Request sent;

  ExpedienteRepositoryImpl repositoryAnswering(
    Object? body, {
    int status = 200,
  }) {
    final api = ApiClient(
      baseUrl: 'https://api.test',
      httpClient: MockClient((request) async {
        sent = request;
        return http.Response.bytes(utf8.encode(jsonEncode(body)), status);
      }),
    );
    return ExpedienteRepositoryImpl(remote: ExpedienteRemoteDataSource(api));
  }

  test('reads the profile and maps the six statistics', () async {
    final repository = repositoryAnswering({
      'jugadorId': '7',
      'alias': 'Ñandú',
      'creadoEn': '2026-10-01T12:00:00Z',
      'ultimaActividad': null,
      'estadisticas': {
        'partidasTotales': 12,
        'partidasGanadas': 3,
        'totalInvertido': 4500,
        'totalPerdido': 3200,
        'rachaDerrotasMax': 5,
        'tiempoJugadoSeg': 7260,
      },
      'generadoEn': '2026-11-02T20:05:00Z',
    });

    final profile = await repository.getProfile('7');

    expect(sent.url.path, '/api/pwa/perfil');
    expect(sent.url.queryParameters, {'id': '7'});
    expect(
      profile,
      PlayerProfile(
        id: '7',
        alias: 'Ñandú',
        createdAt: DateTime.utc(2026, 10, 1, 12),
        stats: const ProfileStats(
          totalMatches: 12,
          matchesWon: 3,
          moneyInvested: 4500,
          moneyLost: 3200,
          longestLosingStreak: 5,
          secondsPlayed: 7260,
        ),
        generatedAt: DateTime.utc(2026, 11, 2, 20, 5),
      ),
    );
  });

  test('asks for one page of matches and maps each result', () async {
    Map<String, Object?> match(String id, String result) => {
      'id': id,
      'resultado': result,
      'rondaAlcanzada': 11,
      'puntaje': 98000,
      'dineroInvertido': 500,
      'dineroGanado': 900,
      'dineroPerdido': 100,
      'duracionSeg': 1080,
      'creadaEn': '2026-11-01T18:30:00Z',
    };
    final repository = repositoryAnswering({
      'contenido': [
        match('a', 'VICTORIA'),
        match('b', 'DERROTA'),
        match('c', 'ABANDONO'),
      ],
      'pagina': 1,
      'tamano': 10,
      'totalElementos': 13,
      'totalPaginas': 2,
      'ultima': true,
      'generadoEn': '2026-11-02T20:05:00Z',
    });

    final page = await repository.getMatches('7', page: 1);

    expect(sent.url.path, '/api/pwa/partidas');
    expect(sent.url.queryParameters, {
      'id': '7',
      'pagina': '1',
      'tamano': '10',
    });
    expect(page.page, 1);
    expect(page.totalMatches, 13);
    expect(page.isLast, isTrue);
    expect(page.matches.map((m) => m.result), [
      MatchResult.victory,
      MatchResult.defeat,
      MatchResult.abandoned,
    ]);
    expect(
      page.matches.first,
      PlayedMatch(
        id: 'a',
        result: MatchResult.victory,
        roundReached: 11,
        score: 98000,
        moneyInvested: 500,
        moneyWon: 900,
        moneyLost: 100,
        durationSeconds: 1080,
        playedAt: DateTime.utc(2026, 11, 1, 18, 30),
      ),
    );
  });

  test('an unknown player is a NotFoundException', () {
    final repository = repositoryAnswering({'error': 'x'}, status: 404);

    expect(repository.getProfile('999'), throwsA(isA<NotFoundException>()));
  });

  test('a body with another shape is an UnexpectedResponseException', () {
    final repository = repositoryAnswering([]);

    expect(
      repository.getProfile('7'),
      throwsA(isA<UnexpectedResponseException>()),
    );
    expect(
      repository.getMatches('7', page: 0),
      throwsA(isA<UnexpectedResponseException>()),
    );
  });

  test('an unknown result is an UnexpectedResponseException', () {
    final repository = repositoryAnswering({
      'contenido': [
        {
          'id': 'a',
          'resultado': 'EMPATE',
          'rondaAlcanzada': 1,
          'puntaje': 0,
          'dineroInvertido': 0,
          'dineroGanado': 0,
          'dineroPerdido': 0,
          'duracionSeg': 0,
          'creadaEn': '2026-11-01T18:30:00Z',
        },
      ],
      'pagina': 0,
      'totalElementos': 1,
      'ultima': true,
    });

    expect(
      repository.getMatches('7', page: 0),
      throwsA(isA<UnexpectedResponseException>()),
    );
  });
}
