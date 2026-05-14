import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_local_storage.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_secure_storage.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/register_req_entity.dart';
import 'package:realtime_chat_engine/features/chat/data/data_source/chat_web_socket.dart';
import 'package:realtime_chat_engine/features/chat/data/repo/chat_repository_impl.dart';

import '../../../chat/domain/repositories/chat_repository.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/entities/login_req_entity.dart';
import '../../domain/repository/auth_repository.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref);
  },
);

sealed class AuthState {}

class Authenticated extends AuthState {
  final String userId;
  final String token;

  Authenticated({required this.userId, required this.token});
}

class UnAuthenticated extends AuthState {}

class AuthController extends StateNotifier<AuthState> {
  AuthRepository? _authRepository;
  ChatRepository? _chatRepository;
  AuthLocalStorage? _authLocalStorage;
  AuthSecureStorage? _authSecureStorage;
  ChatWebSocket? _chatWebSocket;
  final Ref ref;

  AuthController(this.ref) : super(UnAuthenticated()) {
    _authRepository = ref.read(authRepositoryProvider);
    _chatRepository = ref.read(chatRepositoryProvider);
    _authLocalStorage = ref.read(authLocalStorageProvider);
    _authSecureStorage = ref.read(authSecureStorageProvider);
    _chatWebSocket = ref.read(chatWebSocketProvider);

    _init();
  }

  Future<void> _init() async {
    final token = await _authSecureStorage?.getToken();
    final user = await _authLocalStorage?.getUser();

    if (token != null && user != null) {
      state = Authenticated(userId: user.id, token: token);
      _chatWebSocket?.connect();
    }
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final result = await _authRepository?.register(
        RegisterReqEntity(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        ),
      );

      if (result == null) {
        state = UnAuthenticated();
        return;
      }

      await _onAuthSuccess(result.user.id, result.token);
    } catch (e) {
      debugPrint("Couldn't register user $e");
    }
  }

  Future<void> _onAuthSuccess(String userId, String token) async {
    try {
      state = Authenticated(userId: userId, token: token);
      _chatWebSocket?.connect();
    } catch (e) {
      debugPrint("Couldn't set success state $e");
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final result = await _authRepository?.login(
        LoginReqEntity(email: email, password: password),
      );

      if (result == null) {
        state = UnAuthenticated();
        return;
      }

      await _onAuthSuccess(result.user.id, result.token);
    } catch (e) {
      debugPrint("Couldn't login $e");
    }
  }

  Future<void> logOut() async {
    try {
      await _chatWebSocket?.disconnect();
      final currentState = state;
      if (currentState is Authenticated) {
        await _authSecureStorage?.deleteTokens();
        await _authLocalStorage?.deleteUser(currentState.userId);
      }
      _chatRepository?.clearCache();
      state = UnAuthenticated();
    } catch (e) {
      debugPrint("Couldn't clear cache $e");
    }
  }
}
