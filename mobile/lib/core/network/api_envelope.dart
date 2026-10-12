import 'package:dio/dio.dart';
import '../error/failures.dart';

class ApiException implements Exception {
  ApiException(this.failure);
  final Failure failure;
}

Failure mapDioError(DioException error) {
  if (error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout) {
    final base = error.requestOptions.baseUrl;
    return NetworkFailure(
      'Cannot reach API at $base. On Android use 10.0.2.2 (emulator) or your Mac Wi-Fi IP (phone), port 4000. Keep pnpm dev:api running.',
    );
  }
  final data = error.response?.data;
  if (data is Map && data['error'] is Map) {
    final err = data['error'] as Map;
    final message = err['message']?.toString() ?? 'errorGeneric';
    final code = err['code']?.toString();
    if (error.response?.statusCode == 401) {
      return AuthFailure(message, code: code);
    }
    return ServerFailure(message, code: code);
  }
  return ServerFailure(error.message ?? 'errorGeneric');
}

Map<String, dynamic> unwrap(dynamic body) {
  if (body is Map<String, dynamic>) {
    if (body['success'] == true && body['data'] != null) {
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {'value': data};
    }
    if (body['success'] == false) {
      final err = body['error'];
      throw ApiException(
        ServerFailure(
          err is Map ? err['message']?.toString() ?? 'errorGeneric' : 'errorGeneric',
          code: err is Map ? err['code']?.toString() : null,
        ),
      );
    }
    return body;
  }
  return {'value': body};
}

dynamic unwrapData(dynamic body) {
  if (body is Map<String, dynamic> && body['success'] == true) {
    return body['data'];
  }
  return unwrap(body);
}
