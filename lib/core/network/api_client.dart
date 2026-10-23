import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Thin HTTP client for the Fat Fish API. Features use it from their remote data sources.
class ApiClient {
  ApiClient({
    required String baseUrl,
    this.apiKey = '',
    this.timeout = const Duration(seconds: 10),
    http.Client? httpClient,
  }) : _baseUrl = baseUrl.endsWith('/')
           ? baseUrl.substring(0, baseUrl.length - 1)
           : baseUrl,
       _http = httpClient ?? http.Client();

  final String _baseUrl;
  final String apiKey;
  final Duration timeout;
  final http.Client _http;

  /// GET [path] (for example `/api/pwa/perfil`) and return the decoded JSON body.
  Future<Object?> getJson(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);

    final http.Response response;
    try {
      response = await _http.get(uri, headers: _headers).timeout(timeout);
    } on TimeoutException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }

    _throwIfError(response);
    // A 204 (or any success without body) has nothing to decode.
    if (response.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    if (apiKey.isNotEmpty) 'X-Api-Key': apiKey,
  };

  /// Turns a non-2xx response into an [ApiException]; returns normally on success.
  void _throwIfError(http.Response response) {
    switch (response.statusCode) {
      case >= 200 && < 300:
        return;
      case 404:
        throw const NotFoundException();
      case >= 400 && < 500:
        throw SomethingWentWrongException(response.statusCode);
      default:
        throw ServerException(response.statusCode);
    }
  }

  void close() => _http.close();
}
