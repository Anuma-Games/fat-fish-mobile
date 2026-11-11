import 'package:fat_fish_mobile/app/sound_scope.dart';
import 'package:fat_fish_mobile/core/audio/table_sound.dart';
import 'package:fat_fish_mobile/core/network/api_client.dart';
import 'package:fat_fish_mobile/core/network/cached_api.dart';
import 'package:fat_fish_mobile/core/storage/app_database.dart';
import 'package:fat_fish_mobile/features/ajustes/data/datasources/settings_local_data_source.dart';
import 'package:fat_fish_mobile/features/ajustes/data/repositories/settings_repository_impl.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/repositories/settings_repository.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/usecases/get_settings.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/usecases/save_settings.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/cubit/settings_cubit.dart';
import 'package:fat_fish_mobile/features/expediente/data/datasources/expediente_remote_data_source.dart';
import 'package:fat_fish_mobile/features/expediente/data/repositories/expediente_repository_impl.dart';
import 'package:fat_fish_mobile/features/expediente/domain/repositories/expediente_repository.dart';
import 'package:fat_fish_mobile/features/jugador/data/datasources/player_local_data_source.dart';
import 'package:fat_fish_mobile/features/jugador/data/datasources/player_remote_data_source.dart';
import 'package:fat_fish_mobile/features/jugador/data/repositories/player_repository_impl.dart';
import 'package:fat_fish_mobile/features/jugador/domain/repositories/player_repository.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/clear_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/get_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/save_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/cubit/my_player_cubit.dart';
import 'package:fat_fish_mobile/features/ranking/data/datasources/ranking_remote_data_source.dart';
import 'package:fat_fish_mobile/features/ranking/data/repositories/ranking_repository_impl.dart';
import 'package:fat_fish_mobile/features/ranking/domain/repositories/ranking_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Composition root: shared services, repositories and app-wide Cubits.
/// main.dart passes the real services; widget tests pass fakes.
/// Each feature adds its data sources and repositories to this list.
class AppProviders extends StatelessWidget {
  const AppProviders({
    super.key,
    required this.apiClient,
    required this.database,
    this.tableSound = const SilentTableSound(),
    required this.child,
  });

  final ApiClient apiClient;
  final AppDatabase database;

  /// main.dart passes [AudioTableSound]; tests keep the silent one, which needs no plugin.
  final TableSound tableSound;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>(
          create: (_) => apiClient,
          dispose: (client) => client.close(),
        ),
        RepositoryProvider<AppDatabase>(
          create: (_) => database,
          dispose: (db) => db.close(),
        ),
        // Keeps the last dossier, history and ranking for offline use.
        RepositoryProvider<CachedApi>(
          create: (context) => CachedApi(
            api: context.read<ApiClient>(),
            db: context.read<AppDatabase>(),
          ),
        ),
        RepositoryProvider<ExpedienteRepository>(
          create: (context) => ExpedienteRepositoryImpl(
            remote: ExpedienteRemoteDataSource(context.read<CachedApi>()),
          ),
        ),
        RepositoryProvider<RankingRepository>(
          create: (context) => RankingRepositoryImpl(
            remote: RankingRemoteDataSource(context.read<CachedApi>()),
          ),
        ),
        RepositoryProvider<PlayerRepository>(
          create: (context) => PlayerRepositoryImpl(
            remote: PlayerRemoteDataSource(context.read<ApiClient>()),
            local: PlayerLocalDataSource(context.read<AppDatabase>()),
          ),
        ),
        RepositoryProvider<SettingsRepository>(
          create: (context) => SettingsRepositoryImpl(
            local: SettingsLocalDataSource(context.read<AppDatabase>()),
          ),
        ),
        RepositoryProvider<TableSound>(
          create: (_) => tableSound,
          dispose: (sound) => sound.dispose(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Above the router: the dossier and ranking tabs read the same player.
          BlocProvider(
            create: (context) {
              final players = context.read<PlayerRepository>();
              return MyPlayerCubit(
                getMyPlayer: GetMyPlayer(players),
                saveMyPlayer: SaveMyPlayer(players),
                clearMyPlayer: ClearMyPlayer(players),
              )..load();
            },
          ),
          // The top bar, the bottom bar, the table and the sound read the settings.
          BlocProvider(
            create: (context) {
              final settings = context.read<SettingsRepository>();
              return SettingsCubit(
                getSettings: GetSettings(settings),
                saveSettings: SaveSettings(settings),
              )..load();
            },
          ),
        ],
        child: SoundScope(child: child),
      ),
    );
  }
}
