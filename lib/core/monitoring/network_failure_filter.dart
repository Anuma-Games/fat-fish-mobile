import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sentry_flutter/sentry_flutter.dart';

/// `beforeSend` of Sentry: drops the API requests that failed for lack of network (no
/// connection, unknown host, timeout). The app already handles them with the saved copy
/// and the offline notice, so they are not errors of the app. Only events of
/// `SentryHttpClient` are dropped: a timeout elsewhere, a TLS failure
/// (`HandshakeException`) and answers with an error code (5xx) still reach Sentry.
SentryEvent? dropNetworkFailures(SentryEvent event, Hint hint) =>
    isNetworkFailure(event, hint) ? null : event;

bool isNetworkFailure(SentryEvent event, Hint hint) {
  final fromApi = hint.get(TypeCheckHint.httpRequest) != null;
  final throwable = event.throwable;
  return fromApi &&
      (throwable is SocketException ||
          throwable is http.ClientException ||
          throwable is TimeoutException);
}
