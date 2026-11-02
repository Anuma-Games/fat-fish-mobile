import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:fat_fish_mobile/app/app.dart';
import 'package:fat_fish_mobile/app/app_providers.dart';
import 'package:fat_fish_mobile/core/config/app_config.dart';
import 'package:fat_fish_mobile/core/network/api_client.dart';
import 'package:fat_fish_mobile/core/storage/app_database.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.sentryDsn;
      options.environment = AppConfig.sentryEnvironment;
      // Few users, so every transaction is kept.
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      SentryWidget(
        child: AppProviders(
          apiClient: ApiClient(
            baseUrl: AppConfig.apiBaseUrl,
            apiKey: AppConfig.apiKey,
            timeout: AppConfig.requestTimeout,
            // Spans for each API call; 5xx responses are reported as errors.
            httpClient: SentryHttpClient(),
          ),
          database: AppDatabase(),
          child: const FatFishApp(),
        ),
      ),
    ),
  );
}
