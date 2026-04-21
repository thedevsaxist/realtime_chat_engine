import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/shared/constants.dart';
import 'package:realtime_chat_engine/features/home/data/models/create_message_req_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

final chatWebSocketProvider = Provider((ref) => ChatWebSocket());

/// A dedicated web socket interface for managing real-time chat functionality.
///
/// Handles establishing a connection to the chat server, joining conversations,
/// sending outgoing messages, receiving real-time incoming messages, and
/// automatically attempting to reconnect if the connection drops.
class ChatWebSocket {
  /// The active socket instance.
  io.Socket? _socket;

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
  void connect(String conversationId) {
    _conversationId = conversationId;
    _streamController = StreamController.broadcast();
    _shouldReconnect = true;

    _connect();
  }

  /// Internal method to establish the web socket channel connection.
  void _connect() {
    if (_socket != null) {
      _socket?.dispose();
    }

    try {
      _socket = io.io(
        Constants.baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );

      _socket?.onConnect((_) {
        debugPrint("Connected to WebSocket server");
        _isConnected = true;
        _reconnectAttempt = 0;

        if (_conversationId != null) {
          _socket?.emit('join_conversation', _conversationId);
        }
      });

      _socket?.on('message_created', _onMessageData);

      _socket?.onConnectError((err) {
        debugPrint("Failed to connect to WebSocket server: $err");
        _isConnected = false;
        _scheduleReconnect();
      });

      _socket?.onError((err) {
        _onError(err);
      });

      _socket?.onDisconnect((_) {
        _onDone();
      });

      _socket?.connect();
    } catch (e) {
      debugPrint("Failed to setup WebSocket server connection: $e");
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  /// Sends a chat message to the server over the established web socket.
  ///
  /// It fails silently if the web socket is not currently connected.
  void sendMessage(CreateMessageReqModel message) {
    if (!_isConnected || _socket == null) {
      debugPrint("Not connected to WebSocket server");
      return;
    }

    final messageData = {
      "conversationId": message.conversationId,
      "senderId": message.senderId,
      "content": message.content,
    };

    _socket?.emit('send_message', messageData);
  }

  /// Handles incoming data events from the web socket.
  void _onMessageData(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        _streamController?.add(data);
      } else if (data is String) {
        final Map<String, dynamic> decoded = jsonDecode(data);
        _streamController?.add(decoded);
      }
    } catch (e) {
      debugPrint("Failed to process message: $e");
    }
  }

  /// Handles errors encountered by the web socket channel.
  void _onError(dynamic error) {
    debugPrint("WebSocket error: $error");
    _isConnected = false;
  }

  /// Handles the web socket channel completing (disconnecting).
  void _onDone() {
    debugPrint("WebSocket disconnected");
    _isConnected = false;

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  /// Calculates a delay and schedules an attempt to reconnect the web socket.
  ///
  /// Implements exponential back-off based on the current reconnect attempt.
  void _scheduleReconnect() {
    if (_reconnectAttempt >= _maxReconnectAttempts) {
      debugPrint("Max reconnect attempts reached");
      return;
    }

    final delay = Duration(seconds: 2 << _reconnectAttempt);
    _reconnectAttempt++;
    debugPrint("Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempt/$_maxReconnectAttempts)");

    Future.delayed(delay, () {
      if (_shouldReconnect) _connect();
    });
  }

  /// Gracefully terminates the web socket connection.
  ///
  /// Instructs the socket not to reconnect and closes both the sink and the stream.
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _isConnected = false;
    _socket?.emit('leave_conversation', _conversationId);
    _socket?.disconnect();
    _socket?.dispose();
    await _streamController?.close();
  }
}
