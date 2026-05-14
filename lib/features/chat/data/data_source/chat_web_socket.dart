import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

final chatWebSocketProvider = Provider((ref) => ChatWebSocket(ref.read(authSecureStorageProvider)));

class ChatWebSocket {
  final AuthSecureStorage _authSecureStorage;

  ChatWebSocket(this._authSecureStorage);

  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _streamController;
  bool _isConnected = false;
  bool _shouldReconnect = true;
  int _reconnectAttempt = 0;
  static const int _maxReconnectAttempts = 5;

  Stream<Map<String, dynamic>> get messageStream => _streamController!.stream;
  bool get isConnected => _isConnected;

  void connect() async {
    if (_isConnected) return;
    _streamController ??= StreamController.broadcast();
    _shouldReconnect = true;
    await _connect();
  }

  Future<void> _connect() async {
    try {
      final token = await _authSecureStorage.getToken();
      final uri = Uri(
        scheme: 'ws',
        host: 'localhost',
        port: 3000,
        queryParameters: {"token": token},
      );
      _channel = WebSocketChannel.connect(uri);
      await _channel?.ready;
      _isConnected = true;
      _reconnectAttempt = 0;
      debugPrint("Connected to WebSocket server");
      _channel?.stream.listen(_onMessage, onError: _onError, onDone: _onDone, cancelOnError: false);
    } catch (e) {
      debugPrint("Failed to connect to WebSocket server: $e");
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) {
    if (!_isConnected || _channel == null) {
      debugPrint("Not connected to WebSocket server");
      return;
    }
    _channel?.sink.add(
      jsonEncode({
        "event": "send_message",
        "data": {"conversationId": conversationId, "senderId": senderId, "content": content},
      }),
    );
    debugPrint("Message sent over websocket: $content(user $senderId)");
  }

  Future<void> _onMessage(dynamic raw) async {
    try {
      final Map<String, dynamic> data = jsonDecode(raw);
      _streamController?.add(data);
    } catch (e) {
      debugPrint("Failed to decode message: $e");
    }
  }

  Future<void> _onError(dynamic error) async {
    debugPrint("WebSocket error: $error");
    _isConnected = false;
  }

  Future<void> _onDone() async {
    debugPrint("WebSocket disconnected");
    _isConnected = false;
    if (_shouldReconnect) _scheduleReconnect();
  }

  Future<void> _scheduleReconnect() async {
    if (_reconnectAttempt >= _maxReconnectAttempts) {
      debugPrint("Max reconnect attempts reached");
      return;
    }
    final delay = Duration(seconds: 2 << _reconnectAttempt);
    _reconnectAttempt++;
    debugPrint(
      "Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempt/$_maxReconnectAttempts)",
    );
    await Future.delayed(delay, () {
      if (_shouldReconnect) _connect();
    });
  }

  Future<void> disconnect() async {
    _shouldReconnect = false;
    _isConnected = false;
    await _channel?.sink.close(status.goingAway);
    await _streamController?.close();
    _streamController = null;
  }
}
