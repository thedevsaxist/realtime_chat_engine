import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repository/auth_repository_impl.dart';
import '../../domain/entities/login_req_entity.dart';
import '../../domain/repository/auth_repository.dart';

final loginScreenControllerProvider = StateNotifierProvider<LoginScreenController, LoginState>((ref) {
  return LoginScreenController(ref);
});

sealed class LoginState {}

class Authenticated extends LoginState {
  final String userId;
  final String token;

  Authenticated({required this.userId, required this.token});
}

class UnAuthenticated extends LoginState {}

class LoginScreenController extends StateNotifier<LoginState> {
  AuthRepository? _authRepository;
  final Ref ref;

  LoginScreenController(this.ref) : super(UnAuthenticated()) {
    _authRepository = ref.watch(authRepositoryProvider);
  }

  void login(String userId, String password) async {
    try {
      final result = await _authRepository?.login(LoginReqEntity(userId: userId, password: password));

      if (result == null) {
        state = UnAuthenticated();
      }

      state = Authenticated(userId: result!.userId, token: result.token);
    } catch (e) {
      debugPrint("Couldn't login $e");
    }
  }
}
