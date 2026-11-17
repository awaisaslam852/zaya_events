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
  var _callsReady = false;

  bool get callsConnected => calls?.connected == true || _callsReady;

  String get _origin {
    final uri = Uri.parse(_config.apiBaseUrl);
    return '${uri.scheme}://${uri.authority}';
  }

  Future<void> connect() async {
    final token = await _storage.readAccess();
    if (token == null) {
      return;
    }
    await disconnect();
    chat = _open('/chat', token);
    calls = _open('/calls', token);
    calls?.on('connect', (_) {
      _callsReady = true;
      _notifyConnected();
    });
    calls?.on('calls:ready', (_) {
      _callsReady = true;
      _notifyConnected();
    });
    if (calls?.connected == true) {
      _callsReady = true;
      _notifyConnected();
    }
  }

  void _notifyConnected() {
    for (final hook in List<VoidCallback>.from(onConnected)) {
      hook();
    }
  }

  io.Socket _open(String nsp, String token) {
    final socket = io.io(
      '$_origin$nsp',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .setQuery({'token': token})
          .enableForceNew()
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(99)
          .setReconnectionDelay(1000)
          .build(),
    );
    socket.connect();
    return socket;
  }

  Future<void> disconnect() async {
    _callsReady = false;
    chat?.dispose();
    calls?.dispose();
    chat = null;
    calls = null;
  }
}
