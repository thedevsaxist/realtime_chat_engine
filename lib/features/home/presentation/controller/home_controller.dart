import 'package:flutter_riverpod/legacy.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_local_storage.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/user_entity.dart';
import 'package:realtime_chat_engine/features/chat/data/repo/chat_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/chat/domain/repositories/chat_repository.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/conversation_entity.dart';

sealed class HomeControllerState {
  const HomeControllerState();
}

final class HomeControllerStateLoading extends HomeControllerState {
  const HomeControllerStateLoading();
}

final class HomeControllerStateSuccess extends HomeControllerState {
  final UserEntity user;
  final List<ConversationEntity> conversations;
  const HomeControllerStateSuccess(this.conversations, this.user);
}

final class HomeControllerStateError extends HomeControllerState {
  final String error;
  final String stackTrace;
  const HomeControllerStateError(this.error, this.stackTrace);
}

final homeControllerProvider =
    StateNotifierProvider.autoDispose<HomeController, HomeControllerState>((ref) {
      return HomeController(ref);
    });

class HomeController extends StateNotifier<HomeControllerState> {
  final Ref ref;
  ChatRepository? _chatRepository;
  AuthLocalStorage? _authLocalStorage;

  HomeController(this.ref) : super(const HomeControllerStateLoading()) {
    _chatRepository = ref.read(chatRepositoryProvider);
    _authLocalStorage = ref.read(authLocalStorageProvider);

    _init();
  }

  void _init() async {
    final user = await _authLocalStorage?.getUser();

    if (user == null) {
      state = const HomeControllerStateError("User not found", "User not found");
      return;
    }

    try {
      final res = await _chatRepository?.getConversations(user.id);

      state = HomeControllerStateSuccess(
        res?.conversations ?? [],
        UserEntity.fromModel(user),
      );
    } catch (e, st) {
      state = HomeControllerStateError(e.toString(), st.toString());
    }
  }
}

