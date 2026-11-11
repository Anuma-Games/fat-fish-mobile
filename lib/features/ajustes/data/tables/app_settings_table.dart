import 'package:drift/drift.dart';

/// The settings of this device, in one row (id 1). A missing row means the defaults.
@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  IntColumn get id => integer()();

  /// Background ambience and table sounds. Off until the player turns them on.
  BoolColumn get ambienceOn => boolean()();
  BoolColumn get tableSoundsOn => boolean()();

  /// From 0 to 10.
  IntColumn get volume => integer()();
  BoolColumn get vibration => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}
