import 'dart:async';
import 'dart:io';

import 'package:fat_fish_mobile/core/monitoring/network_failure_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  SentryEvent? send(Object error) =>
      dropNetworkFailures(SentryEvent(throwable: error), Hint());

  test('drops requests that failed for lack of network', () {
    expect(
      send(
        http.ClientException(
          "Failed host lookup: 'api'",
          Uri.parse('https://api/ranking'),
        ),
      ),
      isNull,
    );
    expect(send(const SocketException('Network is unreachable')), isNull);
    expect(send(TimeoutException('20 s')), isNull);
  });

  test('drops an event whose exceptions are all of the network', () {
    final event = SentryEvent(
      exceptions: [
        SentryException(type: 'OSError', value: 'nodename nor servname'),
        SentryException(type: 'ClientException', value: 'Failed host lookup'),
      ],
    );

    expect(dropNetworkFailures(event, Hint()), isNull);
  });

  test('keeps the errors of the app', () {
    final error = StateError('Cannot emit new states after calling close');

    expect(send(error), isNotNull);
    expect(send(const FormatException('bad JSON')), isNotNull);
  });
}
