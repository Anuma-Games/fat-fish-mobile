import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';

/// `beforeSend` of Sentry: drops requests that failed for lack of network (no connection,
/// unknown host, timeout). The app already handles them with the saved copy and the
/// offline notice, so they are not errors of the app. Answers with an error code (5xx)
/// still reach Sentry.
SentryEvent? dropNetworkFailures(SentryEvent event, Hint hint) =>
    isNetworkFailure(event) ? null : event;

const _networkTypes = {
  'SocketException',
  'ClientException',
  'TimeoutException',
  'OSError',
  'HandshakeException',
};

bool isNetworkFailure(SentryEvent event) {
  final throwable = event.throwable;
  if (throwable is SocketException ||
      throwable is http.ClientException ||
      throwable is TimeoutException ||
      throwable is OSError ||
      throwable is HandshakeException) {
    return true;
  }
  final exceptions = event.exceptions ?? const <SentryException>[];
  return exceptions.isNotEmpty &&
      exceptions.every((exception) => _networkTypes.contains(exception.type));
}
