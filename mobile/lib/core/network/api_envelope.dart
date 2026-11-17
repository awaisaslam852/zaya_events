import 'package:dio/dio.dart';
import '../error/failures.dart';

class ApiException implements Exception {
  ApiException(this.failure);
  final Failure failure;
}

Map<String, String>? parseZodFieldErrors(dynamic details) {
  if (details is! Map) {
    return null;
  }
  final raw = details['fieldErrors'];
  if (raw is! Map) {
    return null;
  }
  final mapped = <String, String>{};
  raw.forEach((key, value) {
    if (value is List && value.isNotEmpty) {
      final first = value.first?.toString();
      if (first != null && first.isNotEmpty) {
        mapped[key.toString()] = first;
      }
    } else if (value is String && value.isNotEmpty) {
      mapped[key.toString()] = value;
    }
  });
  return mapped.isEmpty ? null : mapped;
}

Failure failureFromApiError(Map err, {int? statusCode}) {
  final message = err['message']?.toString() ?? 'errorGeneric';
  final code = err['code']?.toString();
  final fieldErrors = parseZodFieldErrors(err['details']);
  if (statusCode == 401) {
    return AuthFailure(message, code: code, fieldErrors: fieldErrors);
  }
  return ServerFailure(message, code: code, fieldErrors: fieldErrors);
}

Failure mapDioError(DioException error) {
  if (error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout) {
    final base = error.requestOptions.baseUrl;
    return NetworkFailure(
      'Cannot reach API at $base.',
    );
  }
  final data = error.response?.data;
  if (data is Map && data['error'] is Map) {
    return failureFromApiError(
      data['error'] as Map,
      statusCode: error.response?.statusCode,
    );
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
        err is Map
            ? failureFromApiError(err)
            : const ServerFailure('errorGeneric'),
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
