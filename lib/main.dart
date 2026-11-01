import 'package:flutter/material.dart';

import 'package:fat_fish_mobile/app/app.dart';
import 'package:fat_fish_mobile/app/app_providers.dart';
import 'package:fat_fish_mobile/core/config/app_config.dart';
import 'package:fat_fish_mobile/core/network/api_client.dart';
import 'package:fat_fish_mobile/core/storage/app_database.dart';

void main() {
  runApp(
    AppProviders(
      apiClient: ApiClient(
        baseUrl: AppConfig.apiBaseUrl,
        apiKey: AppConfig.apiKey,
        timeout: AppConfig.requestTimeout,
      ),
      database: AppDatabase(),
      child: const FatFishApp(),
    ),
  );
}
