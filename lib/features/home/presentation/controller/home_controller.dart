import 'package:flutter_riverpod/legacy.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_local_storage.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/user_entity.dart';
import 'package:realtime_chat_engine/features/home/data/data_source/conversation_database.dart';
import 'package:realtime_chat_engine/features/home/data/models/conversation_model.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_messages_res_entity.dart';
import 'package:realtime_chat_engine/features/chat/data/repo/chat_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/chat/domain/repositories/chat_repository.dart';
// part 'home_controller.g.dart';

sealed class HomeControllerState {
  const HomeControllerState();
}

final class HomeControllerStateLoading extends HomeControllerState {
  const HomeControllerStateLoading();
}

final class HomeControllerStateSuccess extends HomeControllerState {
  final UserEntity user;
  final List<GetMessagesResEntity> conversations;
  const HomeControllerStateSuccess(this.conversations, this.user);
}

final class HomeControllerStateError extends HomeControllerState {
  final String error;
  final String stackTrace;
  const HomeControllerStateError(this.error, this.stackTrace);
}

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeControllerState>((ref) {
      return HomeController(ref);
    });

class HomeController extends StateNotifier<HomeControllerState> {
  final Ref ref;
  ChatRepository? _chatRepository;
  AuthLocalStorage? _authLocalStorage;
  ConversationDao? _conversationDao;

  HomeController(this.ref) : super(HomeControllerStateLoading()) {
    _chatRepository = ref.watch(chatRepositoryProvider);
    _authLocalStorage = ref.watch(authLocalStorageProvider);
    _conversationDao = ref.watch(conversationDaoProvider);

    _init();
  }

  void _init() async {
    final user = await _authLocalStorage?.getUser();

    List<GetMessagesResEntity> conversations = [];

    if (user == null) {
      state = HomeControllerStateError("User not found", "User not found");
      return;
    }

    final data = await _conversationDao?.getUserConversations(
      user.id,
    );

    if (data == null) {
      state = HomeControllerStateError(
        "No conversation ids found for this user",
        "No conversation ids found for this user",
      );
      return;
    }

    try {
      for (ConversationModel conversation in data) {
        final res = await _chatRepository?.getMessages(conversation.id);
        conversations.add(res!);
      }

      state = HomeControllerStateSuccess(conversations, UserEntity.fromModel(user));
    } catch (e) {
      state = HomeControllerStateError(e.toString(), e.toString());
    }
  }
}
