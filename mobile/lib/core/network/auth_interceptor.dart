import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_envelope.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.storage,
    required this.config,
    required this.refreshDio,
    this.onForceLogout,
  });

  final TokenStorage storage;
  final AppConfig config;
  final Dio refreshDio;
  void Function()? onForceLogout;
  bool _refreshing = false;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await storage.readAccess();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 || err.requestOptions.path.contains('/auth/refresh')) {
      handler.next(err);
      return;
    }
    if (_refreshing) {
      handler.next(err);
      return;
    }
    _refreshing = true;
    try {
      final refresh = await storage.readRefresh();
      if (refresh == null) {
        onForceLogout?.call();
        handler.next(err);
        return;
      }
      final response = await refreshDio.post<dynamic>(
        '${config.apiBaseUrl}/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final data = unwrap(response.data);
      final tokens = data['tokens'] as Map<String, dynamic>? ?? data;
      final access = tokens['accessToken'] as String?;
      final nextRefresh = tokens['refreshToken'] as String?;
      if (access == null || nextRefresh == null) {
        await storage.clear();
        onForceLogout?.call();
        handler.next(err);
        return;
      }
      await storage.save(access: access, refresh: nextRefresh);
      final request = err.requestOptions;
      request.headers['Authorization'] = 'Bearer $access';
      final clone = await Dio().fetch<dynamic>(request);
      handler.resolve(clone);
    } catch (_) {
      await storage.clear();
      onForceLogout?.call();
      handler.next(err);
    } finally {
      _refreshing = false;
    }
  }
}
