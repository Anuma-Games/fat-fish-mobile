import 'dart:convert';

import 'package:fat_fish_mobile/core/network/api_client.dart';
import 'package:fat_fish_mobile/core/network/api_exception.dart';
import 'package:fat_fish_mobile/core/storage/app_database.dart';

/// A JSON answer and, when it came from the device, when it was saved.
typedef CachedJson = ({Object? json, DateTime? savedAt});

/// [ApiClient] that keeps the last answer of each request on the device and returns it
/// when there is no connection. Only a [NetworkException] falls back to the copy: a
/// player that no longer exists or a server error still reach the screen.
class CachedApi {
  CachedApi({required this._api, required this._db, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final ApiClient _api;
  final AppDatabase _db;
  final DateTime Function() _now;

  /// [CachedJson.savedAt] is null for a fresh answer.
  Future<CachedJson> getJson(String path, {Map<String, String>? query}) async {
    final key = requestKey(path, query);
    try {
      final json = await _api.getJson(path, query: query);
      await _db
          .into(_db.cachedResponses)
          .insertOnConflictUpdate(
            CachedResponsesCompanion.insert(
              requestKey: key,
              body: jsonEncode(json),
              savedAt: _now(),
            ),
          );
      return (json: json, savedAt: null);
    } on NetworkException {
      final saved = await (_db.select(
        _db.cachedResponses,
      )..where((row) => row.requestKey.equals(key))).getSingleOrNull();
      if (saved == null) rethrow;
      return (json: jsonDecode(saved.body), savedAt: saved.savedAt);
    }
  }

  /// The same request always gives the same key, whatever the order of its query.
  static String requestKey(String path, Map<String, String>? query) {
    if (query == null || query.isEmpty) return path;
    final params = query.keys.toList()..sort();
    return Uri(
      path: path,
      queryParameters: {for (final name in params) name: query[name]},
    ).toString();
  }
}
