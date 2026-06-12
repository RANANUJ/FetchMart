import 'package:dio/dio.dart';

enum ApiExceptionType { noInternet, timeout, server, badResponse, unknown }

class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
  });

  final ApiExceptionType type;
  final String message;
  final int? statusCode;

  bool get canRetry =>
      type == ApiExceptionType.timeout ||
      type == ApiExceptionType.server ||
      type == ApiExceptionType.unknown;

  factory ApiException.noInternet() {
    return const ApiException(
      type: ApiExceptionType.noInternet,
      message: 'You are offline. Showing saved products when available.',
    );
  }

  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          type: ApiExceptionType.timeout,
          message: 'The request timed out. Please try again.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return ApiException(
          type: statusCode != null && statusCode >= 500
              ? ApiExceptionType.server
              : ApiExceptionType.badResponse,
          statusCode: statusCode,
          message: statusCode != null && statusCode >= 500
              ? 'The server is busy. Please try again shortly.'
              : 'We could not load products from the server.',
        );
      case DioExceptionType.connectionError:
        return ApiException.noInternet();
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const ApiException(
          type: ApiExceptionType.unknown,
          message: 'Something went wrong while loading products.',
        );
    }
  }

  @override
  String toString() => message;
}
