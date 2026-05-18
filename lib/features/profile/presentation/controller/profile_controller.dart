import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_local_storage.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/user_entity.dart';
import 'package:riverpod/legacy.dart';

sealed class ProfileState {}

class EmptyState implements ProfileState {}

class DefaultState implements ProfileState {
  final UserEntity userDetails;

  const DefaultState(this.userDetails);
}

class ErrorState implements ProfileState {
  late final String e;
  late final StackTrace st;

  ErrorState({StackTrace? stackTrace, String? error})
    : e = error ?? "User not found",
      st = stackTrace ?? StackTrace.current;
}

final profileControllerProvider = StateNotifierProvider<ProfileController, ProfileState>((ref) {
  return ProfileController(ref);
});

class ProfileController extends StateNotifier<ProfileState> {
  final Ref ref;
  late final AuthLocalStorage _localStorage;

  ProfileController(this.ref) : super(EmptyState()) {
    _localStorage = ref.read(authLocalStorageProvider);

    _init();
  }

  Future<void> _init() async {
    final user = await _localStorage.getUser();

    if (user == null) {
      state = ErrorState();
    }

    state = DefaultState(UserEntity.fromModel(user!));
  }
}
