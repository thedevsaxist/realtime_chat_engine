import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/chat/data/models/create_message_req_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

final chatWebSocketProvider = Provider((ref) => ChatWebSocket());

/// A dedicated web socket interface for managing real-time chat functionality.
///
/// Handles establishing a connection to the chat server, joining conversations,
/// sending outgoing messages, receiving real-time incoming messages, and
/// automatically attempting to reconnect if the connection drops.
class ChatWebSocket {
  /// The active web socket channel.
  WebSocketChannel? _channel;

  /// Broadcast stream controller that surfaces parsed incoming messages to listeners.
  StreamController<Map<String, dynamic>>? _streamController;

  /// The ID of the conversation this socket is currently connected to.
  String? _conversationId;

  /// Current connection status of the web socket.
  bool _isConnected = false;

  /// Indicates whether the socket should attempt to reconnect upon disconnection.
  bool _shouldReconnect = true;

  /// Counter for the number of connection attempts made during reconnection.
  int _reconnectAttempt = 0;

  /// Maximum number of times to try reconnecting before giving up.
  static const int _maxReconnectAttempts = 5;

  /// A stream of incoming parsed JSON messages.
  ///
  /// Throws if accessed before [connect] is called.
  Stream<Map<String, dynamic>> get messageStream => _streamController!.stream;

  /// Whether the web socket is currently active and connected to the server.
  bool get isConnected => _isConnected;

  /// Initializes the web socket and connects it to the specified [conversationId].
  ///
  /// Readies the stream, allows reconnects, and begins the connection process.
  void connect(String conversationId) async {
    _conversationId = conversationId;
    _streamController = StreamController.broadcast();
    _shouldReconnect = true;

    await _connect();
  }

  /// Internal method to establish the web socket channel connection.
  Future<void> _connect() async {
    try {
      final uri = Uri(scheme: 'ws', host: 'localhost', port: 3000);
      // final uri = Uri.parse(Constants.chatWebSocketUrl);
      _channel = WebSocketChannel.connect(uri);

      // Notify the server which conversation we intend to join.
      if (_conversationId != null) {
        _channel?.sink.add(jsonEncode({"event": "join_conversation", "data": _conversationId}));
      }

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

  /// Sends a chat message to the server over the established web socket.
  ///
  /// It fails silently if the web socket is not currently connected.
  void sendMessage(CreateMessageReqModel message) {
    if (!_isConnected || _channel == null) {
      debugPrint("Not connected to WebSocket server");
      return;
    }

    final messageJson = jsonEncode({
      "event": "send_message",
      "data": {"conversationId": message.conversationId, "senderId": message.senderId, "content": message.content},
    });

    _channel?.sink.add(messageJson);
  }

  /// Handles incoming data events from the web socket.
  Future<void> _onMessage(dynamic raw) async {
    try {
      final Map<String, dynamic> data = jsonDecode(raw);

      _streamController?.add(data);
    } catch (e) {
      debugPrint("Failed to decode message: $e");
    }
  }

  /// Handles errors encountered by the web socket channel.
  Future<void> _onError(dynamic error) async {
    debugPrint("WebSocket error: $error");
    _isConnected = false;
  }

  /// Handles the web socket channel completing (disconnecting).
  Future<void> _onDone() async {
    debugPrint("WebSocket disconnected");
    _isConnected = false;

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  /// Calculates a delay and schedules an attempt to reconnect the web socket.
  ///
  /// Implements exponential back-off based on the current reconnect attempt.
  Future<void> _scheduleReconnect() async {
    if (_reconnectAttempt >= _maxReconnectAttempts) {
      debugPrint("Max reconnect attempts reached");
      return;
    }

    final delay = Duration(seconds: 2 << _reconnectAttempt);
    _reconnectAttempt++;
    debugPrint("Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempt/$_maxReconnectAttempts)");

    await Future.delayed(delay, () {
      if (_shouldReconnect) _connect();
    });
  }

  /// Gracefully terminates the web socket connection.
  ///
  /// Instructs the socket not to reconnect and closes both the sink and the stream.
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _isConnected = false;
    _channel?.sink.add(jsonEncode({"event": "leave_conversation", "data": _conversationId}));
    await _channel?.sink.close(status.goingAway);
    await _streamController?.close();
  }
}
