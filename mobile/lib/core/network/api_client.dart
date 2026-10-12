import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../config/app_config.dart';
import '../error/failures.dart';
import 'api_envelope.dart';
import 'auth_interceptor.dart';

class ApiClient {
  ApiClient({
    required AppConfig config,
    required AuthInterceptor interceptor,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: config.apiBaseUrl,
           connectTimeout: const Duration(seconds: 20),
           receiveTimeout: const Duration(seconds: 30),
           contentType: Headers.jsonContentType,
           headers: {'Accept': 'application/json'},
         ),
       ) {
    _dio.interceptors.add(interceptor);
  }

  final Dio _dio;

  Dio get raw => _dio;

  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic data) parse,
  }) {
    return _guard(() async {
      final response = await _dio.get<dynamic>(path, queryParameters: query);
      return parse(unwrapData(response.data));
    });
  }

  Future<Either<Failure, T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    required T Function(dynamic data) parse,
  }) {
    return _guard(() async {
      final response = await _dio.post<dynamic>(path, data: data, queryParameters: query);
      return parse(unwrapData(response.data));
    });
  }

  Future<Either<Failure, T>> patch<T>(
    String path, {
    Object? data,
    required T Function(dynamic data) parse,
  }) {
    return _guard(() async {
      final response = await _dio.patch<dynamic>(path, data: data);
      return parse(unwrapData(response.data));
    });
  }

  Future<Either<Failure, T>> delete<T>(
    String path, {
    Object? data,
    required T Function(dynamic data) parse,
  }) {
    return _guard(() async {
      final response = await _dio.delete<dynamic>(path, data: data);
      return parse(unwrapData(response.data));
    });
  }

  Future<Either<Failure, T>> upload<T>(
    String path, {
    required FormData data,
    required T Function(dynamic data) parse,
  }) {
    return _guard(() async {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
      return parse(unwrapData(response.data));
    });
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on ApiException catch (error) {
      return Left(error.failure);
    } on DioException catch (error) {
      return Left(mapDioError(error));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
