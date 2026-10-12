import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/app_config.dart';
import '../storage/token_storage.dart';

class SocketService {
  SocketService(this._config, this._storage);

  final AppConfig _config;
  final TokenStorage _storage;
  io.Socket? chat;
  io.Socket? calls;
  final List<VoidCallback> onConnected = [];

  String get _origin {
    final uri = Uri.parse(_config.apiBaseUrl);
    return '${uri.scheme}://${uri.authority}';
  }

  Future<void> connect() async {
    final token = await _storage.readAccess();
    if (token == null) {
      return;
    }
    chat = _open('/chat', token);
    calls = _open('/calls', token);
    for (final hook in onConnected) {
      hook();
    }
  }

  io.Socket _open(String nsp, String token) {
    return io.io(
      '$_origin$nsp',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );
  }

  Future<void> disconnect() async {
    chat?.dispose();
    calls?.dispose();
    chat = null;
    calls = null;
  }
}
