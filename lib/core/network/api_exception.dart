/// Errors raised by [ApiClient]. Messages are shown to the player, so they are in Spanish.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Our fault: bad request or wrong API key. Retrying won't help.
class SomethingWentWrongException extends ApiException {
  const SomethingWentWrongException(this.statusCode)
    : super('Algo salió mal de nuestro lado. Ya estamos en ello.');

  final int statusCode;
}

/// The requested resource does not exist (for example, an unknown player id).
class NotFoundException extends ApiException {
  const NotFoundException() : super('No encontramos lo que buscabas.');
}

/// No connection, DNS failure or timeout.
class NetworkException extends ApiException {
  const NetworkException()
    : super('No pudimos conectarnos. Revisa tu internet e intenta de nuevo.');
}

/// A 2xx answer whose body is not the JSON we expect (a proxy page, a changed contract).
class UnexpectedResponseException extends ApiException {
  const UnexpectedResponseException()
    : super('Algo salió mal de nuestro lado. Ya estamos en ello.');
}

/// Any other non-2xx answer from the API.
class ServerException extends ApiException {
  const ServerException(this.statusCode)
    : super('No pudimos cargar los datos. Intenta más tarde.');

  final int statusCode;
}
