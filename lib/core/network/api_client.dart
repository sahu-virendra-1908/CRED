import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'request_deduplicator.dart';

class ApiClient {
  ApiClient({
    required Dio dio,
    RequestDeduplicator? deduplicator,
  })  : _dio = dio,
        _deduplicator = deduplicator ?? RequestDeduplicator();

  final Dio _dio;
  final RequestDeduplicator _deduplicator;

  Future<Map<String, dynamic>> getJson(
    String path, {
    bool forceRefresh = false,
  }) async {
    final requestKey = 'GET:$path';
    if (!forceRefresh && _deduplicator.isInFlight(requestKey)) {
      return _deduplicator.run<Map<String, dynamic>>(
        requestKey,
        () => _executeGet(path),
      );
    }

    return _deduplicator.run<Map<String, dynamic>>(
      requestKey,
      () => _executeGet(path),
    );
  }

  Future<Map<String, dynamic>> _executeGet(String path) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        options: Options(
          responseType: ResponseType.json,
          headers: const <String, String>{
            'Accept': 'application/json',
          },
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      throw const InvalidPayloadException();
    } on DioException catch (error) {
      throw _mapDioError(error);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const InvalidPayloadException();
    }
  }

  AppException _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkTimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkUnavailableException();
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        return ServerException(
          'Unable to load card details (HTTP ${status ?? 'unknown'}).',
          statusCode: status,
        );
      case DioExceptionType.cancel:
        return const NetworkUnavailableException('Request was cancelled.');
      default:
        return const NetworkUnavailableException();
    }
  }

  static Dio createDefaultDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ),
    );
  }
}
