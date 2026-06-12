import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import 'api_exception.dart';
import 'connectivity_service.dart';

class ApiClient {
  ApiClient({
    required Dio dio,
    required ConnectivityService connectivityService,
  }) : _dio = dio,
       _connectivityService = connectivityService {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: const {'Accept': 'application/json'},
    );
  }

  static const int _maxRetries = 2;

  final Dio _dio;
  final ConnectivityService _connectivityService;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(() => _dio.get(path, queryParameters: queryParameters));
  }

  Future<Response<dynamic>> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    if (!await _connectivityService.hasConnection) {
      throw ApiException.noInternet();
    }

    ApiException? lastError;
    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final response = await request();
        final statusCode = response.statusCode ?? 500;
        if (statusCode >= 200 && statusCode < 300) {
          return response;
        }

        throw ApiException(
          type: statusCode >= 500
              ? ApiExceptionType.server
              : ApiExceptionType.badResponse,
          statusCode: statusCode,
          message: 'Unexpected response from the server.',
        );
      } on DioException catch (error) {
        lastError = ApiException.fromDio(error);
        if (!lastError.canRetry || attempt == _maxRetries) {
          throw lastError;
        }
      } on ApiException catch (error) {
        lastError = error;
        if (!error.canRetry || attempt == _maxRetries) {
          rethrow;
        }
      }

      await Future<void>.delayed(Duration(milliseconds: 350 * (attempt + 1)));
    }

    throw lastError ??
        const ApiException(
          type: ApiExceptionType.unknown,
          message: 'Unable to complete the request.',
        );
  }
}
