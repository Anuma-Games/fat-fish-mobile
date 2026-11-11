import 'package:drift/drift.dart';

/// Last answer of each API request the app shows offline: the dossier, the history
/// and the ranking. One row per request, replaced by every new answer.
@DataClassName('CachedResponseRow')
class CachedResponses extends Table {
  /// Path and query of the request, for example `/api/pwa/perfil?id=7`.
  TextColumn get requestKey => text()();

  /// The JSON body as the API sent it.
  TextColumn get body => text()();

  /// When the answer arrived, shown as the date of the data offline.
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {requestKey};
}
