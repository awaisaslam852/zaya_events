import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage(FlutterSecureStorage storage) : _secure = storage, _memory = null;

  /// In-memory tokens for widget tests (no platform channel).
  TokenStorage.memory() : _secure = null, _memory = {};

  static const _access = 'access_token';
  static const _refresh = 'refresh_token';

  final FlutterSecureStorage? _secure;
  final Map<String, String>? _memory;

  Future<void> save({required String access, required String refresh}) async {
    final mem = _memory;
    if (mem != null) {
      mem[_access] = access;
      mem[_refresh] = refresh;
      return;
    }
    try {
      await _secure!.write(key: _access, value: access);
      await _secure.write(key: _refresh, value: refresh);
    } catch (_) {}
  }

  Future<String?> readAccess() async {
    final mem = _memory;
    if (mem != null) {
      return mem[_access];
    }
    try {
      return await _secure!.read(key: _access);
    } catch (_) {
      return null;
    }
  }

  Future<String?> readRefresh() async {
    final mem = _memory;
    if (mem != null) {
      return mem[_refresh];
    }
    try {
      return await _secure!.read(key: _refresh);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final mem = _memory;
    if (mem != null) {
      mem.remove(_access);
      mem.remove(_refresh);
      return;
    }
    try {
      await _secure!.delete(key: _access);
      await _secure!.delete(key: _refresh);
    } catch (_) {}
  }
}
