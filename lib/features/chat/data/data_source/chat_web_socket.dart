import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/config/network/dio_service.dart';
import 'package:realtime_chat_engine/core/shared/constants.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

final chatWebSocketProvider = Provider((ref) {
  return ChatWebSocket(ref.read(authSecureStorageProvider), ref.read(dioServiceProvider));
});

class ChatWebSocket {
  final AuthSecureStorage _authSecureStorage;
  final DioService _dioService;

  ChatWebSocket(this._authSecureStorage, this._dioService);

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
      final host = Uri.parse(Constants.baseUrl).host;
      final uri = Uri(
        scheme: kReleaseMode ? 'wss' : 'ws',
        host: kReleaseMode ? host : 'localhost',
        port: kDebugMode ? 3000 : null,
        queryParameters: {"token": token},
      );

      debugPrint(
        "\n-----------------------------------------------------------[🔗 WEBSOCKET CONNECTION]------------------------------------------------------------\n",
      );
      debugPrint("Websocket URL: ${uri.toString()}");
      debugPrint(
        "\n------------------------------------------------------------------------------------------------------------------------------------------------\n",
      );

      _channel = WebSocketChannel.connect(uri);

      try {
        await _channel?.ready;
      } on SocketException catch (e) {
        debugPrint(e.message);
        return;
      } on WebSocketChannelException catch (e) {
        debugPrint(e.message);
        return;
      }

      _isConnected = true;
      _reconnectAttempt = 0;
      debugPrint("Connected to WebSocket server 🔗\n");
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
    required String tempId,
  }) {
    if (!_isConnected || _channel == null) {
      debugPrint("Not connected to WebSocket server");
      return;
    }
    _channel?.sink.add(
      jsonEncode({
        "event": "send_message",
        "data": {
          "conversationId": conversationId,
          "senderId": senderId,
          "content": content,
          "tempId": tempId,
        },
      }),
    );
    debugPrint("Message sent over websocket: $content(user $senderId)");
  }

  Future<void> _onMessage(dynamic raw) async {
    try {
      final Map<String, dynamic> data = jsonDecode(raw);
      if (data['type'] == 'error') {
        _onError(data);
      }
      _streamController?.add(data);
    } catch (e) {
      debugPrint("Failed to decode message: $e");
    }
  }

  Future<void> _onError(dynamic error) async {
    debugPrint("WebSocket error: $error");

    if (error is Map<String, dynamic>) {
      if (error['statusCode'] as int == 401) {
        _refreshAuthToken();
      }
    }

    _isConnected = false;
  }

  Future<void> _refreshAuthToken() async {
    try {
      await _dioService.tokenRefresh.refresh();
    } catch (e) {
      debugPrint('[ChatWebSocket] refresh failed: $e');
      // await onLogout?.call();  //TODO: find a way to log out without creating a circular dependency between the ChatWebSocket and AuthController
    }
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

    final channel = _channel;
    _channel = null;

    if (channel != null) {
      try {
        await channel.sink.close(status.normalClosure).timeout(const Duration(seconds: 2));
      } catch (e) {
        debugPrint("WebSocket close error (ignored): $e");
      }
    }

    // Do not await close — Riverpod StreamProviders may still be subscribed
    // (e.g. incomingMessageProvider) and close() waits for all listeners to cancel.
    final controller = _streamController;
    _streamController = null;
    if (controller != null && !controller.isClosed) {
      controller.close();
    }

    debugPrint("WebSocket disconnect complete");
  }
}
