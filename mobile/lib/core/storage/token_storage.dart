import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage(FlutterSecureStorage storage) : _secure = storage;

  /// In-memory tokens for widget tests (no platform channel).
  TokenStorage.memory() : _secure = null;

  static const _access = 'access_token';
  static const _refresh = 'refresh_token';

  final FlutterSecureStorage? _secure;
  final Map<String, String> _memory = {};

  Future<void> save({required String access, required String refresh}) async {
    _memory[_access] = access;
    _memory[_refresh] = refresh;
    final secure = _secure;
    if (secure == null) {
      return;
    }
    try {
      await secure.write(key: _access, value: access);
      await secure.write(key: _refresh, value: refresh);
    } catch (_) {}
  }

  Future<String?> readAccess() => _read(_access);

  Future<String?> readRefresh() => _read(_refresh);

  Future<String?> _read(String key) async {
    final cached = _memory[key];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    final secure = _secure;
    if (secure == null) {
      return null;
    }
    try {
      final value = await secure.read(key: key);
      if (value != null && value.isNotEmpty) {
        _memory[key] = value;
      }
      return value;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    _memory.remove(_access);
    _memory.remove(_refresh);
    final secure = _secure;
    if (secure == null) {
      return;
    }
    try {
      await secure.delete(key: _access);
      await secure.delete(key: _refresh);
    } catch (_) {}
  }
}
