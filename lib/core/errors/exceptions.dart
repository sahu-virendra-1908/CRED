sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      '$runtimeType(message: $message, statusCode: $statusCode)';
}

final class NetworkTimeoutException extends AppException {
  const NetworkTimeoutException([
    super.message = 'Request timed out while fetching card details.',
  ]);
}

final class NetworkUnavailableException extends AppException {
  const NetworkUnavailableException([
    super.message = 'No internet connection. Please check your network.',
  ]);
}

final class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

final class InvalidPayloadException extends AppException {
  const InvalidPayloadException([
    super.message = 'Received malformed card management response.',
  ]);
}
