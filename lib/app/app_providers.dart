import 'package:fat_fish_mobile/core/network/api_client.dart';
import 'package:fat_fish_mobile/core/storage/app_database.dart';
import 'package:fat_fish_mobile/features/jugador/data/datasources/player_local_data_source.dart';
import 'package:fat_fish_mobile/features/jugador/data/datasources/player_remote_data_source.dart';
import 'package:fat_fish_mobile/features/jugador/data/repositories/player_repository_impl.dart';
import 'package:fat_fish_mobile/features/jugador/domain/repositories/player_repository.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/clear_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/get_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/domain/usecases/save_my_player.dart';
import 'package:fat_fish_mobile/features/jugador/presentation/cubit/my_player_cubit.dart';
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
    required this.child,
  });

  final ApiClient apiClient;
  final AppDatabase database;
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
        RepositoryProvider<PlayerRepository>(
          create: (context) => PlayerRepositoryImpl(
            remote: PlayerRemoteDataSource(context.read<ApiClient>()),
            local: PlayerLocalDataSource(context.read<AppDatabase>()),
          ),
        ),
      ],
      child: BlocProvider(
        // Above the router: the dossier and ranking tabs read the same player.
        create: (context) {
          final players = context.read<PlayerRepository>();
          return MyPlayerCubit(
            getMyPlayer: GetMyPlayer(players),
            saveMyPlayer: SaveMyPlayer(players),
            clearMyPlayer: ClearMyPlayer(players),
          )..load();
        },
        child: child,
      ),
    );
  }
}
