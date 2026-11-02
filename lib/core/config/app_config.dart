/// Values injected at build time with `--dart-define-from-file` (see README).
abstract final class AppConfig {
  /// The Android emulator reaches the host machine at 10.0.2.2.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  /// Sent as `X-Api-Key`. Empty when the API runs without a key (local and CI).
  static const apiKey = String.fromEnvironment('API_KEY');

  static const requestTimeout = Duration(seconds: 10);

  /// Sentry project key. Empty disables Sentry (tests and CI).
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static const sentryEnvironment = String.fromEnvironment(
    'SENTRY_ENVIRONMENT',
    defaultValue: 'development',
  );

  /// Shows a button that throws a test error, to check that Sentry receives it.
  static const sentryTestButton = bool.fromEnvironment('SENTRY_TEST_BUTTON');
}
