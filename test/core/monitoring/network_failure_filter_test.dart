import 'dart:async';
import 'dart:io';

import 'package:fat_fish_mobile/core/monitoring/network_failure_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  final request = http.Request('GET', Uri.parse('https://api/ranking'));

  /// What SentryHttpClient sends when an API request fails.
  SentryEvent? fromApi(Object error) => dropNetworkFailures(
    SentryEvent(throwable: error),
    Hint.withMap({TypeCheckHint.httpRequest: request}),
  );

  SentryEvent? elsewhere(Object error) =>
      dropNetworkFailures(SentryEvent(throwable: error), Hint());

  test('drops API requests that failed for lack of network', () {
    expect(
      fromApi(http.ClientException("Failed host lookup: 'api'", request.url)),
      isNull,
    );
    expect(fromApi(const SocketException('Network is unreachable')), isNull);
    expect(fromApi(TimeoutException('20 s')), isNull);
  });

  test('keeps a TLS failure of the API', () {
    expect(fromApi(const HandshakeException('certificate expired')), isNotNull);
  });

  test('keeps the same errors when they do not come from a request', () {
    expect(elsewhere(TimeoutException('20 s')), isNotNull);
    expect(elsewhere(const OSError('nodename nor servname', 8)), isNotNull);
  });

  test('keeps the errors of the app', () {
    expect(elsewhere(StateError('Cannot emit after close')), isNotNull);
    expect(fromApi(const FormatException('bad JSON')), isNotNull);
  });
}
