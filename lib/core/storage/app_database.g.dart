// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MyPlayersTable extends MyPlayers
    with TableInfo<$MyPlayersTable, MyPlayerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MyPlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastActivityMeta = const VerificationMeta(
    'lastActivity',
  );
  @override
  late final GeneratedColumn<DateTime> lastActivity = GeneratedColumn<DateTime>(
    'last_activity',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [playerId, alias, lastActivity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'my_players';
  @override
  VerificationContext validateIntegrity(
    Insertable<MyPlayerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    if (data.containsKey('last_activity')) {
      context.handle(
        _lastActivityMeta,
        lastActivity.isAcceptableOrUnknown(
          data['last_activity']!,
          _lastActivityMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playerId};
  @override
  MyPlayerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MyPlayerRow(
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      )!,
      lastActivity: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_activity'],
      ),
    );
  }

  @override
  $MyPlayersTable createAlias(String alias) {
    return $MyPlayersTable(attachedDatabase, alias);
  }
}

class MyPlayerRow extends DataClass implements Insertable<MyPlayerRow> {
  final String playerId;
  final String alias;
  final DateTime? lastActivity;
  const MyPlayerRow({
    required this.playerId,
    required this.alias,
    this.lastActivity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['player_id'] = Variable<String>(playerId);
    map['alias'] = Variable<String>(alias);
    if (!nullToAbsent || lastActivity != null) {
      map['last_activity'] = Variable<DateTime>(lastActivity);
    }
    return map;
  }

  MyPlayersCompanion toCompanion(bool nullToAbsent) {
    return MyPlayersCompanion(
      playerId: Value(playerId),
      alias: Value(alias),
      lastActivity: lastActivity == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActivity),
    );
  }

  factory MyPlayerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MyPlayerRow(
      playerId: serializer.fromJson<String>(json['playerId']),
      alias: serializer.fromJson<String>(json['alias']),
      lastActivity: serializer.fromJson<DateTime?>(json['lastActivity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playerId': serializer.toJson<String>(playerId),
      'alias': serializer.toJson<String>(alias),
      'lastActivity': serializer.toJson<DateTime?>(lastActivity),
    };
  }

  MyPlayerRow copyWith({
    String? playerId,
    String? alias,
    Value<DateTime?> lastActivity = const Value.absent(),
  }) => MyPlayerRow(
    playerId: playerId ?? this.playerId,
    alias: alias ?? this.alias,
    lastActivity: lastActivity.present ? lastActivity.value : this.lastActivity,
  );
  MyPlayerRow copyWithCompanion(MyPlayersCompanion data) {
    return MyPlayerRow(
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      alias: data.alias.present ? data.alias.value : this.alias,
      lastActivity: data.lastActivity.present
          ? data.lastActivity.value
          : this.lastActivity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MyPlayerRow(')
          ..write('playerId: $playerId, ')
          ..write('alias: $alias, ')
          ..write('lastActivity: $lastActivity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playerId, alias, lastActivity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MyPlayerRow &&
          other.playerId == this.playerId &&
          other.alias == this.alias &&
          other.lastActivity == this.lastActivity);
}

class MyPlayersCompanion extends UpdateCompanion<MyPlayerRow> {
  final Value<String> playerId;
  final Value<String> alias;
  final Value<DateTime?> lastActivity;
  final Value<int> rowid;
  const MyPlayersCompanion({
    this.playerId = const Value.absent(),
    this.alias = const Value.absent(),
    this.lastActivity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MyPlayersCompanion.insert({
    required String playerId,
    required String alias,
    this.lastActivity = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : playerId = Value(playerId),
       alias = Value(alias);
  static Insertable<MyPlayerRow> custom({
    Expression<String>? playerId,
    Expression<String>? alias,
    Expression<DateTime>? lastActivity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playerId != null) 'player_id': playerId,
      if (alias != null) 'alias': alias,
      if (lastActivity != null) 'last_activity': lastActivity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MyPlayersCompanion copyWith({
    Value<String>? playerId,
    Value<String>? alias,
    Value<DateTime?>? lastActivity,
    Value<int>? rowid,
  }) {
    return MyPlayersCompanion(
      playerId: playerId ?? this.playerId,
      alias: alias ?? this.alias,
      lastActivity: lastActivity ?? this.lastActivity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (lastActivity.present) {
      map['last_activity'] = Variable<DateTime>(lastActivity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MyPlayersCompanion(')
          ..write('playerId: $playerId, ')
          ..write('alias: $alias, ')
          ..write('lastActivity: $lastActivity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecentPlayersTable extends RecentPlayers
    with TableInfo<$RecentPlayersTable, RecentPlayerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentPlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastActivityMeta = const VerificationMeta(
    'lastActivity',
  );
  @override
  late final GeneratedColumn<DateTime> lastActivity = GeneratedColumn<DateTime>(
    'last_activity',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viewedAtMeta = const VerificationMeta(
    'viewedAt',
  );
  @override
  late final GeneratedColumn<int> viewedAt = GeneratedColumn<int>(
    'viewed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    playerId,
    alias,
    lastActivity,
    viewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_players';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentPlayerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    if (data.containsKey('last_activity')) {
      context.handle(
        _lastActivityMeta,
        lastActivity.isAcceptableOrUnknown(
          data['last_activity']!,
          _lastActivityMeta,
        ),
      );
    }
    if (data.containsKey('viewed_at')) {
      context.handle(
        _viewedAtMeta,
        viewedAt.isAcceptableOrUnknown(data['viewed_at']!, _viewedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_viewedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playerId};
  @override
  RecentPlayerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentPlayerRow(
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      )!,
      lastActivity: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_activity'],
      ),
      viewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}viewed_at'],
      )!,
    );
  }

  @override
  $RecentPlayersTable createAlias(String alias) {
    return $RecentPlayersTable(attachedDatabase, alias);
  }
}

class RecentPlayerRow extends DataClass implements Insertable<RecentPlayerRow> {
  final String playerId;
  final String alias;
  final DateTime? lastActivity;

  /// Microseconds since epoch: Drift stores DateTime in whole seconds, and two taps
  /// in the same second would tie and drop the wrong row.
  final int viewedAt;
  const RecentPlayerRow({
    required this.playerId,
    required this.alias,
    this.lastActivity,
    required this.viewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['player_id'] = Variable<String>(playerId);
    map['alias'] = Variable<String>(alias);
    if (!nullToAbsent || lastActivity != null) {
      map['last_activity'] = Variable<DateTime>(lastActivity);
    }
    map['viewed_at'] = Variable<int>(viewedAt);
    return map;
  }

  RecentPlayersCompanion toCompanion(bool nullToAbsent) {
    return RecentPlayersCompanion(
      playerId: Value(playerId),
      alias: Value(alias),
      lastActivity: lastActivity == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActivity),
      viewedAt: Value(viewedAt),
    );
  }

  factory RecentPlayerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentPlayerRow(
      playerId: serializer.fromJson<String>(json['playerId']),
      alias: serializer.fromJson<String>(json['alias']),
      lastActivity: serializer.fromJson<DateTime?>(json['lastActivity']),
      viewedAt: serializer.fromJson<int>(json['viewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playerId': serializer.toJson<String>(playerId),
      'alias': serializer.toJson<String>(alias),
      'lastActivity': serializer.toJson<DateTime?>(lastActivity),
      'viewedAt': serializer.toJson<int>(viewedAt),
    };
  }

  RecentPlayerRow copyWith({
    String? playerId,
    String? alias,
    Value<DateTime?> lastActivity = const Value.absent(),
    int? viewedAt,
  }) => RecentPlayerRow(
    playerId: playerId ?? this.playerId,
    alias: alias ?? this.alias,
    lastActivity: lastActivity.present ? lastActivity.value : this.lastActivity,
    viewedAt: viewedAt ?? this.viewedAt,
  );
  RecentPlayerRow copyWithCompanion(RecentPlayersCompanion data) {
    return RecentPlayerRow(
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      alias: data.alias.present ? data.alias.value : this.alias,
      lastActivity: data.lastActivity.present
          ? data.lastActivity.value
          : this.lastActivity,
      viewedAt: data.viewedAt.present ? data.viewedAt.value : this.viewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentPlayerRow(')
          ..write('playerId: $playerId, ')
          ..write('alias: $alias, ')
          ..write('lastActivity: $lastActivity, ')
          ..write('viewedAt: $viewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playerId, alias, lastActivity, viewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentPlayerRow &&
          other.playerId == this.playerId &&
          other.alias == this.alias &&
          other.lastActivity == this.lastActivity &&
          other.viewedAt == this.viewedAt);
}

class RecentPlayersCompanion extends UpdateCompanion<RecentPlayerRow> {
  final Value<String> playerId;
  final Value<String> alias;
  final Value<DateTime?> lastActivity;
  final Value<int> viewedAt;
  final Value<int> rowid;
  const RecentPlayersCompanion({
    this.playerId = const Value.absent(),
    this.alias = const Value.absent(),
    this.lastActivity = const Value.absent(),
    this.viewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentPlayersCompanion.insert({
    required String playerId,
    required String alias,
    this.lastActivity = const Value.absent(),
    required int viewedAt,
    this.rowid = const Value.absent(),
  }) : playerId = Value(playerId),
       alias = Value(alias),
       viewedAt = Value(viewedAt);
  static Insertable<RecentPlayerRow> custom({
    Expression<String>? playerId,
    Expression<String>? alias,
    Expression<DateTime>? lastActivity,
    Expression<int>? viewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playerId != null) 'player_id': playerId,
      if (alias != null) 'alias': alias,
      if (lastActivity != null) 'last_activity': lastActivity,
      if (viewedAt != null) 'viewed_at': viewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentPlayersCompanion copyWith({
    Value<String>? playerId,
    Value<String>? alias,
    Value<DateTime?>? lastActivity,
    Value<int>? viewedAt,
    Value<int>? rowid,
  }) {
    return RecentPlayersCompanion(
      playerId: playerId ?? this.playerId,
      alias: alias ?? this.alias,
      lastActivity: lastActivity ?? this.lastActivity,
      viewedAt: viewedAt ?? this.viewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (lastActivity.present) {
      map['last_activity'] = Variable<DateTime>(lastActivity.value);
    }
    if (viewedAt.present) {
      map['viewed_at'] = Variable<int>(viewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentPlayersCompanion(')
          ..write('playerId: $playerId, ')
          ..write('alias: $alias, ')
          ..write('lastActivity: $lastActivity, ')
          ..write('viewedAt: $viewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedResponsesTable extends CachedResponses
    with TableInfo<$CachedResponsesTable, CachedResponseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedResponsesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _requestKeyMeta = const VerificationMeta(
    'requestKey',
  );
  @override
  late final GeneratedColumn<String> requestKey = GeneratedColumn<String>(
    'request_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [requestKey, body, savedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_responses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedResponseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('request_key')) {
      context.handle(
        _requestKeyMeta,
        requestKey.isAcceptableOrUnknown(data['request_key']!, _requestKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_requestKeyMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {requestKey};
  @override
  CachedResponseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedResponseRow(
      requestKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_key'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $CachedResponsesTable createAlias(String alias) {
    return $CachedResponsesTable(attachedDatabase, alias);
  }
}

class CachedResponseRow extends DataClass
    implements Insertable<CachedResponseRow> {
  /// Path and query of the request, for example `/api/pwa/perfil?id=7`.
  final String requestKey;

  /// The JSON body as the API sent it.
  final String body;

  /// When the answer arrived, shown as the date of the data offline.
  final DateTime savedAt;
  const CachedResponseRow({
    required this.requestKey,
    required this.body,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['request_key'] = Variable<String>(requestKey);
    map['body'] = Variable<String>(body);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  CachedResponsesCompanion toCompanion(bool nullToAbsent) {
    return CachedResponsesCompanion(
      requestKey: Value(requestKey),
      body: Value(body),
      savedAt: Value(savedAt),
    );
  }

  factory CachedResponseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedResponseRow(
      requestKey: serializer.fromJson<String>(json['requestKey']),
      body: serializer.fromJson<String>(json['body']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'requestKey': serializer.toJson<String>(requestKey),
      'body': serializer.toJson<String>(body),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  CachedResponseRow copyWith({
    String? requestKey,
    String? body,
    DateTime? savedAt,
  }) => CachedResponseRow(
    requestKey: requestKey ?? this.requestKey,
    body: body ?? this.body,
    savedAt: savedAt ?? this.savedAt,
  );
  CachedResponseRow copyWithCompanion(CachedResponsesCompanion data) {
    return CachedResponseRow(
      requestKey: data.requestKey.present
          ? data.requestKey.value
          : this.requestKey,
      body: data.body.present ? data.body.value : this.body,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedResponseRow(')
          ..write('requestKey: $requestKey, ')
          ..write('body: $body, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(requestKey, body, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedResponseRow &&
          other.requestKey == this.requestKey &&
          other.body == this.body &&
          other.savedAt == this.savedAt);
}

class CachedResponsesCompanion extends UpdateCompanion<CachedResponseRow> {
  final Value<String> requestKey;
  final Value<String> body;
  final Value<DateTime> savedAt;
  final Value<int> rowid;
  const CachedResponsesCompanion({
    this.requestKey = const Value.absent(),
    this.body = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedResponsesCompanion.insert({
    required String requestKey,
    required String body,
    required DateTime savedAt,
    this.rowid = const Value.absent(),
  }) : requestKey = Value(requestKey),
       body = Value(body),
       savedAt = Value(savedAt);
  static Insertable<CachedResponseRow> custom({
    Expression<String>? requestKey,
    Expression<String>? body,
    Expression<DateTime>? savedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (requestKey != null) 'request_key': requestKey,
      if (body != null) 'body': body,
      if (savedAt != null) 'saved_at': savedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedResponsesCompanion copyWith({
    Value<String>? requestKey,
    Value<String>? body,
    Value<DateTime>? savedAt,
    Value<int>? rowid,
  }) {
    return CachedResponsesCompanion(
      requestKey: requestKey ?? this.requestKey,
      body: body ?? this.body,
      savedAt: savedAt ?? this.savedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (requestKey.present) {
      map['request_key'] = Variable<String>(requestKey.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedResponsesCompanion(')
          ..write('requestKey: $requestKey, ')
          ..write('body: $body, ')
          ..write('savedAt: $savedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MyPlayersTable myPlayers = $MyPlayersTable(this);
  late final $RecentPlayersTable recentPlayers = $RecentPlayersTable(this);
  late final $CachedResponsesTable cachedResponses = $CachedResponsesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    myPlayers,
    recentPlayers,
    cachedResponses,
  ];
}

typedef $$MyPlayersTableCreateCompanionBuilder = MyPlayersCompanion Function({
  required String playerId,
  required String alias,
  Value<DateTime?> lastActivity,
  Value<int> rowid,
});
typedef $$MyPlayersTableUpdateCompanionBuilder = MyPlayersCompanion Function({
  Value<String> playerId,
  Value<String> alias,
  Value<DateTime?> lastActivity,
  Value<int> rowid,
});

class $$MyPlayersTableFilterComposer
    extends Composer<_$AppDatabase, $MyPlayersTable> {
  $$MyPlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActivity => $composableBuilder(
    column: $table.lastActivity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MyPlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $MyPlayersTable> {
  $$MyPlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActivity => $composableBuilder(
    column: $table.lastActivity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MyPlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MyPlayersTable> {
  $$MyPlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<DateTime> get lastActivity => $composableBuilder(
    column: $table.lastActivity,
    builder: (column) => column,
  );
}

class $$MyPlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MyPlayersTable,
          MyPlayerRow,
          $$MyPlayersTableFilterComposer,
          $$MyPlayersTableOrderingComposer,
          $$MyPlayersTableAnnotationComposer,
          $$MyPlayersTableCreateCompanionBuilder,
          $$MyPlayersTableUpdateCompanionBuilder,
          (
            MyPlayerRow,
            BaseReferences<_$AppDatabase, $MyPlayersTable, MyPlayerRow>,
          ),
          MyPlayerRow,
          PrefetchHooks Function()
        > {
  $$MyPlayersTableTableManager(_$AppDatabase db, $MyPlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MyPlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MyPlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MyPlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playerId = const Value.absent(),
                Value<String> alias = const Value.absent(),
                Value<DateTime?> lastActivity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MyPlayersCompanion(
                playerId: playerId,
                alias: alias,
                lastActivity: lastActivity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playerId,
                required String alias,
                Value<DateTime?> lastActivity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MyPlayersCompanion.insert(
                playerId: playerId,
                alias: alias,
                lastActivity: lastActivity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MyPlayersTable, MyPlayerRow>(table),
                  BaseReferences<_$AppDatabase, $MyPlayersTable, MyPlayerRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MyPlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MyPlayersTable,
      MyPlayerRow,
      $$MyPlayersTableFilterComposer,
      $$MyPlayersTableOrderingComposer,
      $$MyPlayersTableAnnotationComposer,
      $$MyPlayersTableCreateCompanionBuilder,
      $$MyPlayersTableUpdateCompanionBuilder,
      (
        MyPlayerRow,
        BaseReferences<_$AppDatabase, $MyPlayersTable, MyPlayerRow>,
      ),
      MyPlayerRow,
      PrefetchHooks Function()
    >;
typedef $$RecentPlayersTableCreateCompanionBuilder =
    RecentPlayersCompanion Function({
      required String playerId,
      required String alias,
      Value<DateTime?> lastActivity,
      required int viewedAt,
      Value<int> rowid,
    });
typedef $$RecentPlayersTableUpdateCompanionBuilder =
    RecentPlayersCompanion Function({
      Value<String> playerId,
      Value<String> alias,
      Value<DateTime?> lastActivity,
      Value<int> viewedAt,
      Value<int> rowid,
    });

class $$RecentPlayersTableFilterComposer
    extends Composer<_$AppDatabase, $RecentPlayersTable> {
  $$RecentPlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActivity => $composableBuilder(
    column: $table.lastActivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get viewedAt => $composableBuilder(
    column: $table.viewedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentPlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentPlayersTable> {
  $$RecentPlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActivity => $composableBuilder(
    column: $table.lastActivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get viewedAt => $composableBuilder(
    column: $table.viewedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentPlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentPlayersTable> {
  $$RecentPlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<DateTime> get lastActivity => $composableBuilder(
    column: $table.lastActivity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get viewedAt =>
      $composableBuilder(column: $table.viewedAt, builder: (column) => column);
}

class $$RecentPlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentPlayersTable,
          RecentPlayerRow,
          $$RecentPlayersTableFilterComposer,
          $$RecentPlayersTableOrderingComposer,
          $$RecentPlayersTableAnnotationComposer,
          $$RecentPlayersTableCreateCompanionBuilder,
          $$RecentPlayersTableUpdateCompanionBuilder,
          (
            RecentPlayerRow,
            BaseReferences<_$AppDatabase, $RecentPlayersTable, RecentPlayerRow>,
          ),
          RecentPlayerRow,
          PrefetchHooks Function()
        > {
  $$RecentPlayersTableTableManager(_$AppDatabase db, $RecentPlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentPlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentPlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentPlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playerId = const Value.absent(),
                Value<String> alias = const Value.absent(),
                Value<DateTime?> lastActivity = const Value.absent(),
                Value<int> viewedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecentPlayersCompanion(
                playerId: playerId,
                alias: alias,
                lastActivity: lastActivity,
                viewedAt: viewedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playerId,
                required String alias,
                Value<DateTime?> lastActivity = const Value.absent(),
                required int viewedAt,
                Value<int> rowid = const Value.absent(),
              }) => RecentPlayersCompanion.insert(
                playerId: playerId,
                alias: alias,
                lastActivity: lastActivity,
                viewedAt: viewedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecentPlayersTable, RecentPlayerRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RecentPlayersTable,
                    RecentPlayerRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentPlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentPlayersTable,
      RecentPlayerRow,
      $$RecentPlayersTableFilterComposer,
      $$RecentPlayersTableOrderingComposer,
      $$RecentPlayersTableAnnotationComposer,
      $$RecentPlayersTableCreateCompanionBuilder,
      $$RecentPlayersTableUpdateCompanionBuilder,
      (
        RecentPlayerRow,
        BaseReferences<_$AppDatabase, $RecentPlayersTable, RecentPlayerRow>,
      ),
      RecentPlayerRow,
      PrefetchHooks Function()
    >;
typedef $$CachedResponsesTableCreateCompanionBuilder =
    CachedResponsesCompanion Function({
      required String requestKey,
      required String body,
      required DateTime savedAt,
      Value<int> rowid,
    });
typedef $$CachedResponsesTableUpdateCompanionBuilder =
    CachedResponsesCompanion Function({
      Value<String> requestKey,
      Value<String> body,
      Value<DateTime> savedAt,
      Value<int> rowid,
    });

class $$CachedResponsesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedResponsesTable> {
  $$CachedResponsesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedResponsesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedResponsesTable> {
  $$CachedResponsesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedResponsesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedResponsesTable> {
  $$CachedResponsesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get requestKey => $composableBuilder(
    column: $table.requestKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$CachedResponsesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedResponsesTable,
          CachedResponseRow,
          $$CachedResponsesTableFilterComposer,
          $$CachedResponsesTableOrderingComposer,
          $$CachedResponsesTableAnnotationComposer,
          $$CachedResponsesTableCreateCompanionBuilder,
          $$CachedResponsesTableUpdateCompanionBuilder,
          (
            CachedResponseRow,
            BaseReferences<
              _$AppDatabase,
              $CachedResponsesTable,
              CachedResponseRow
            >,
          ),
          CachedResponseRow,
          PrefetchHooks Function()
        > {
  $$CachedResponsesTableTableManager(
    _$AppDatabase db,
    $CachedResponsesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedResponsesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedResponsesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedResponsesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> requestKey = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedResponsesCompanion(
                requestKey: requestKey,
                body: body,
                savedAt: savedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String requestKey,
                required String body,
                required DateTime savedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedResponsesCompanion.insert(
                requestKey: requestKey,
                body: body,
                savedAt: savedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedResponsesTable, CachedResponseRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CachedResponsesTable,
                    CachedResponseRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedResponsesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedResponsesTable,
      CachedResponseRow,
      $$CachedResponsesTableFilterComposer,
      $$CachedResponsesTableOrderingComposer,
      $$CachedResponsesTableAnnotationComposer,
      $$CachedResponsesTableCreateCompanionBuilder,
      $$CachedResponsesTableUpdateCompanionBuilder,
      (
        CachedResponseRow,
        BaseReferences<_$AppDatabase, $CachedResponsesTable, CachedResponseRow>,
      ),
      CachedResponseRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MyPlayersTableTableManager get myPlayers =>
      $$MyPlayersTableTableManager(_db, _db.myPlayers);
  $$RecentPlayersTableTableManager get recentPlayers =>
      $$RecentPlayersTableTableManager(_db, _db.recentPlayers);
  $$CachedResponsesTableTableManager get cachedResponses =>
      $$CachedResponsesTableTableManager(_db, _db.cachedResponses);
}
