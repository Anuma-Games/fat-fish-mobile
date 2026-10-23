import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/app_database.dart';

/// Composition root: shared services are created here and handed down with RepositoryProvider.
/// Each feature adds its data sources, repositories and use cases to this list.
void main() {
  final apiClient = ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    apiKey: AppConfig.apiKey,
    timeout: AppConfig.requestTimeout,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>(
          create: (_) => apiClient,
          dispose: (client) => client.close(),
        ),
        RepositoryProvider<AppDatabase>(
          create: (_) => AppDatabase(),
          dispose: (db) => db.close(),
        ),
      ],
      child: const FatFishApp(),
    ),
  );
}
