import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/providers/incoming_message_provider.dart';
import 'package:realtime_chat_engine/core/providers/unread_provider.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/user_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';
import 'package:realtime_chat_engine/features/chat/data/repo/chat_repository_impl.dart';
import 'package:realtime_chat_engine/features/chat/domain/repositories/chat_repository.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/conversation_entity.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_local_storage.dart';

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
  late final String e;
  late final StackTrace st;

  HomeControllerStateError({StackTrace? stackTrace, String? error})
    : e = error ?? "User not found",
      st = stackTrace ?? StackTrace.current;
}

final homeControllerProvider =
    StateNotifierProvider.autoDispose<HomeController, HomeControllerState>(
      (ref) => HomeController(ref),
    );

class HomeController extends StateNotifier<HomeControllerState> {
  final Ref ref;
  late final ChatRepository _chatRepository;
  late final AuthLocalStorage _authLocalStorage;

  HomeController(this.ref) : super(const HomeControllerStateLoading()) {
    _chatRepository = ref.read(chatRepositoryProvider);
    _authLocalStorage = ref.read(authLocalStorageProvider);

    ref.listen(incomingMessageProvider, (_, next) {
      next.whenData(_handleIncoming);
    });

    _init();
  }

  void _init() async {
    state = HomeControllerStateLoading();

    final user = await _authLocalStorage.getUser('HomeController._init()');

    if (user == null) {
      state = HomeControllerStateError();
      return;
    }

    try {
      final res = await _chatRepository.getConversations(user.id);

      state = HomeControllerStateSuccess(res.conversations, UserEntity.fromModel(user));
    } catch (e, st) {
      state = HomeControllerStateError(error: e.toString(), stackTrace: st);
    }
  }

  void _handleIncoming(MessageEntity newMessage) {
    final current = state;

    if (current is! HomeControllerStateSuccess) return;

    _chatRepository.cacheMessage(newMessage);
    ref.invalidate(unreadCountProvider(newMessage.conversationId));

    final updatedConversations = current.conversations.map((conv) {
      if (conv.id != newMessage.conversationId) return conv;

      final List<MessageEntity> updatedMessages = [...(conv.messages ?? []), newMessage];
      return ConversationEntity(
        id: conv.id,
        createdAt: conv.createdAt,
        participants: conv.participants,
        messages: updatedMessages,
      );
    }).toList();

    state = HomeControllerStateSuccess(updatedConversations, current.user);
  }
}
