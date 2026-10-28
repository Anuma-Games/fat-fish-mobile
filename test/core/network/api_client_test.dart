import 'dart:convert';

import 'package:fat_fish_mobile/core/network/api_client.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  ApiClient clientReturning(int status, {String body = '{}'}) => ApiClient(
    baseUrl: 'https://api.test/',
    httpClient: MockClient((_) async => http.Response(body, status)),
  );

  test('builds the URL and sends the API key', () async {
    late http.Request sent;
    final client = ApiClient(
      baseUrl: 'https://api.test/',
      apiKey: 'llave',
      httpClient: MockClient((request) async {
        sent = request;
        // The API answers UTF-8 JSON; bytes keep the accents intact.
        return http.Response.bytes(utf8.encode('{"alias":"Ñandú"}'), 200);
      }),
    );

    final json = await client.getJson('/api/pwa/perfil', query: {'id': '1'});

    expect(sent.url.toString(), 'https://api.test/api/pwa/perfil?id=1');
    expect(sent.headers['X-Api-Key'], 'llave');
    expect(json, {'alias': 'Ñandú'});
  });

  test('omits the API key header when the key is empty', () async {
    late http.Request sent;
    final client = ApiClient(
      baseUrl: 'https://api.test',
      httpClient: MockClient((request) async {
        sent = request;
        return http.Response('[]', 200);
      }),
    );

    await client.getJson('/api/pwa/partidas');

    expect(sent.headers.containsKey('X-Api-Key'), isFalse);
  });

  test('returns null when a success has no body', () async {
    expect(await clientReturning(204, body: '').getJson('/x'), isNull);
  });

  for (final status in [200, 299]) {
    test('accepts $status as success', () async {
      expect(await clientReturning(status).getJson('/x'), <String, Object?>{});
    });
  }

  test('maps 404 to NotFoundException', () {
    expect(
      clientReturning(404).getJson('/x'),
      throwsA(isA<NotFoundException>()),
    );
  });

  for (final status in [400, 401, 403, 499]) {
    test('maps $status to SomethingWentWrongException', () {
      expect(
        clientReturning(status).getJson('/x'),
        throwsA(
          isA<SomethingWentWrongException>().having(
            (e) => e.statusCode,
            'statusCode',
            status,
          ),
        ),
      );
    });
  }

  for (final status in [300, 500, 503]) {
    test('maps $status to ServerException', () {
      expect(
        clientReturning(status).getJson('/x'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.statusCode,
            'statusCode',
            status,
          ),
        ),
      );
    });
  }

  test('maps a connection failure to NetworkException', () {
    final client = ApiClient(
      baseUrl: 'https://api.test',
      httpClient: MockClient((_) async => throw http.ClientException('down')),
    );

    expect(client.getJson('/x'), throwsA(isA<NetworkException>()));
  });
}
