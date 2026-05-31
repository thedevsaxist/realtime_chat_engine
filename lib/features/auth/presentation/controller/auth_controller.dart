import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/config/network/dio_service.dart';
import 'package:realtime_chat_engine/core/providers/incoming_message_provider.dart';
import 'package:realtime_chat_engine/core/providers/incoming_read_receipt_provider.dart';
import 'package:realtime_chat_engine/features/chat/data/repo/chat_repository_impl.dart';
import 'package:realtime_chat_engine/features/chat/data/data_source/chat_web_socket.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/login_req_entity.dart';
import 'package:realtime_chat_engine/features/auth/domain/repository/auth_repository.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_local_storage.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/register_req_entity.dart';
import 'package:realtime_chat_engine/features/chat/domain/repositories/chat_repository.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_secure_storage.dart';
import 'package:realtime_chat_engine/core/config/network/interceptors/auth_interceptors.dart';
import 'package:realtime_chat_engine/features/auth/data/repository/auth_repository_impl.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

sealed class AuthState {}

class LoadingState extends AuthState {}

class Authenticated extends AuthState {
  final String userId;
  final String token;

  Authenticated({required this.userId, required this.token});
}

class UnAuthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthController extends StateNotifier<AuthState> {
  final Ref ref;

  late final ChatWebSocket _chatWebSocket;
  late final AuthRepository _authRepository;
  late final ChatRepository _chatRepository;
  late final AuthLocalStorage _authLocalStorage;
  late final AuthSecureStorage _authSecureStorage;

  AuthController(this.ref) : super(UnAuthenticated()) {
    _chatWebSocket = ref.read(chatWebSocketProvider);
    _authRepository = ref.read(authRepositoryProvider);
    _chatRepository = ref.read(chatRepositoryProvider);
    _authLocalStorage = ref.read(authLocalStorageProvider);
    _authSecureStorage = ref.read(authSecureStorageProvider);

    _init();
  }

  Future<void> _init() async {
    final dioService = ref.read(dioServiceProvider);
    final interceptor = dioService.dio.interceptors.whereType<AuthInterceptor>().firstOrNull;
    interceptor?.onLogout = logOut;

    final token = await _authSecureStorage.getToken();
    final user = await _authLocalStorage.getUser('AuthController._init()');

    if (token != null && user != null) {
      state = Authenticated(userId: user.id, token: token);
      _chatWebSocket.connect();
    }
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    state = LoadingState();
    try {
      final entity = RegisterReqEntity(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      final result = await _authRepository.register(entity);

      result.when((response) async {
        if (response.token.isEmpty) {
          state = UnAuthenticated();
          return;
        }
        await _onAuthSuccess(response.user.id, response.token);
      }, (error) => state = AuthError(error.message));
    } catch (e) {
      state = AuthError(e.toString());
      debugPrint("Couldn't register user $e");
    }
  }

  Future<void> _onAuthSuccess(String userId, String token) async {
    try {
      state = Authenticated(userId: userId, token: token);
      _chatWebSocket.connect();
    } catch (e) {
      state = AuthError(e.toString());
      debugPrint("Couldn't set success state $e");
    }
  }

  Future<void> login(String email, String password) async {
    state = LoadingState();

    try {
      final result = await _authRepository.login(LoginReqEntity(email: email, password: password));

      if (result.token.isEmpty) {
        state = UnAuthenticated();
        return;
      }

      await _onAuthSuccess(result.user.id, result.token);
    } catch (e) {
      state = AuthError(e.toString());
      debugPrint("Couldn't login $e");
    }
  }

  Future<void> logOut() async {
    debugPrint("Logging out");

    // Update UI and tear down stream listeners before blocking cleanup.
    state = UnAuthenticated();
    ref.invalidate(incomingMessageProvider);
    ref.invalidate(incomingReadReceiptProvider);

    try {
      await _chatWebSocket.disconnect();
    } catch (e, st) {
      debugPrint("Logout: disconnect failed: $e\n$st");
    }

    try {
      await _chatRepository.clearCache();
    } catch (e, st) {
      debugPrint("Logout: clearCache failed: $e\n$st");
    }

    try {
      await _authSecureStorage.deleteTokens();
    } catch (e, st) {
      debugPrint("Logout: deleteTokens failed: $e\n$st");
    }

    try {
      await _authLocalStorage.deleteUser();
    } catch (e, st) {
      debugPrint("Logout: deleteUser failed: $e\n$st");
    }

    debugPrint("Logout complete");
  }
}
