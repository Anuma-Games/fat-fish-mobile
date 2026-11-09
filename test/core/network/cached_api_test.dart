import 'package:drift/native.dart';
import 'package:fat_fish_mobile/core/network/api_client.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/core/network/cached_api.dart';
import 'package:fat_fish_mobile/core/storage/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late AppDatabase db;
  late http.Response Function() answer;
  final savedAt = DateTime(2026, 11, 3, 18, 42);

  CachedApi build() => CachedApi(
    api: ApiClient(
      baseUrl: 'https://api.test',
      httpClient: MockClient((_) async => answer()),
    ),
    db: db,
    now: () => savedAt,
  );

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('a fresh answer is saved and comes without a date', () async {
    answer = () => http.Response('{"alias":"pez"}', 200);

    final result = await build().getJson('/api/pwa/perfil', query: {'id': '7'});

    expect(result.json, {'alias': 'pez'});
    expect(result.savedAt, isNull);
    final row = await db.select(db.cachedResponses).getSingle();
    expect(row.requestKey, '/api/pwa/perfil?id=7');
    expect(row.savedAt, savedAt);
  });

  test('without connection it returns the saved copy with its date', () async {
    final api = build();
    answer = () => http.Response('{"alias":"pez"}', 200);
    await api.getJson('/api/pwa/perfil', query: {'id': '7'});

    answer = () => throw http.ClientException('sin red');
    final result = await api.getJson('/api/pwa/perfil', query: {'id': '7'});

    expect(result.json, {'alias': 'pez'});
    expect(result.savedAt, savedAt);
  });

  test('without connection and without a copy the error goes on', () async {
    answer = () => throw http.ClientException('sin red');

    expect(
      build().getJson('/api/pwa/perfil', query: {'id': '8'}),
      throwsA(isA<NetworkException>()),
    );
  });

  test('a server answer is not replaced by the copy', () async {
    final api = build();
    answer = () => http.Response('{"alias":"pez"}', 200);
    await api.getJson('/api/pwa/perfil', query: {'id': '7'});

    answer = () => http.Response('', 404);

    expect(
      api.getJson('/api/pwa/perfil', query: {'id': '7'}),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('the key does not depend on the order of the query', () {
    expect(
      CachedApi.requestKey('/r', {'b': '2', 'a': '1'}),
      CachedApi.requestKey('/r', {'a': '1', 'b': '2'}),
    );
    expect(CachedApi.requestKey('/r', null), '/r');
  });
}
