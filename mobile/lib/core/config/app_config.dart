import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig({
    required String apiBaseUrl,
    required this.adminWebUrl,
    required this.agoraAppId,
  }) : apiBaseUrl = _normalize(apiBaseUrl);

  static const prefsOverrideKey = 'api_base_url_override';

  factory AppConfig.fromEnvironment() {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    const adminDefine = String.fromEnvironment('ADMIN_WEB_URL');
    const agora = String.fromEnvironment('AGORA_APP_ID');
    return AppConfig(
      apiBaseUrl: fromDefine.isNotEmpty ? fromDefine : defaultApiBaseUrl(),
      adminWebUrl: adminDefine.isNotEmpty ? adminDefine : 'http://localhost:5173',
      agoraAppId: agora,
    );
  }

  static Future<AppConfig> resolve({String? prefsOverride}) async {
    final base = AppConfig.fromEnvironment();
    if (prefsOverride != null && prefsOverride.trim().isNotEmpty) {
      return AppConfig(
        apiBaseUrl: _normalize(prefsOverride.trim()),
        adminWebUrl: base.adminWebUrl,
        agoraAppId: base.agoraAppId,
      );
    }
    final url = await rewriteForDevice(base.apiBaseUrl);
    return AppConfig(apiBaseUrl: url, adminWebUrl: base.adminWebUrl, agoraAppId: base.agoraAppId);
  }

  static String defaultApiBaseUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:4000/api/v1';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.0.123:4000/api/v1';
    }
    return 'http://127.0.0.1:4000/api/v1';
  }

  static Future<String> rewriteForDevice(String url) async {
    final normalized = _normalize(url);
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return normalized;
    }
    final uri = Uri.tryParse(normalized);
    if (uri == null) {
      return normalized;
    }
    final loopback = uri.host == '127.0.0.1' || uri.host == 'localhost';
    if (!loopback) {
      return normalized;
    }
    return uri.replace(host: '192.168.0.123').toString();
  }

  static String _normalize(String url) {
    var value = url.trim();
    if (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    if (!value.endsWith('/api/v1')) {
      if (value.contains('/api/v1')) {
        return value;
      }
      value = '$value/api/v1';
    }
    return value;
  }

  String apiBaseUrl;
  final String adminWebUrl;
  final String agoraAppId;

  /// Origin of the API host, without `/api/v1` (used for `/uploads/...` files).
  String get apiOrigin {
    final uri = Uri.parse(apiBaseUrl);
    return Uri(scheme: uri.scheme, host: uri.host, port: uri.hasPort ? uri.port : null).toString();
  }

  /// Android cannot load `localhost` — that is the phone, not the API machine.
  String rewriteMediaUrl(String url) {
    var trimmed = url.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://') && !trimmed.startsWith('/')) {
      final key = trimmed.startsWith('uploads/') ? trimmed.substring('uploads/'.length) : trimmed;
      trimmed = '/uploads/$key';
    }
    if (trimmed.startsWith('/')) {
      return '$apiOrigin$trimmed';
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.host.isEmpty) {
      return trimmed;
    }
    final loopback = uri.host == 'localhost' || uri.host == '127.0.0.1';
    if (!loopback) {
      return trimmed;
    }
    final api = Uri.parse(apiBaseUrl);
    return uri
        .replace(
          scheme: api.scheme,
          host: api.host,
          port: api.hasPort ? api.port : null,
        )
        .toString();
  }
}
