import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/user_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/repositories/home_repo.dart';
import 'package:realtime_chat_engine/features/chat/data/repo/chat_repository_impl.dart';
import 'package:realtime_chat_engine/features/home/data/repos/home_repository_impl.dart';
import 'package:realtime_chat_engine/features/chat/domain/repositories/chat_repository.dart';
import 'package:realtime_chat_engine/features/chat/domain/entities/create_conversation_req_entity.dart';

final availableUsersController =
    StateNotifierProvider<AvailableUsersController, AvailableUsersState>(
      (ref) => AvailableUsersController(ref),
    );

sealed class AvailableUsersState {}

class NoAvailableUsers extends AvailableUsersState {}

class LoadingState extends AvailableUsersState {}

class ErrorState extends AvailableUsersState {
  late final String m;
  late final StackTrace st;

  ErrorState({String? message, StackTrace? stackTrace})
    : m = message ?? "[AvailableUsersState -> ErrorState] : An error has occurred",
      st = stackTrace ?? StackTrace.current;

  @override
  String toString() {
    return "$m \n\n$st";
  }
}

class UsersAvailable extends AvailableUsersState {
  final List<UserEntity> users;

  UsersAvailable(this.users);
}

class AvailableUsersController extends StateNotifier<AvailableUsersState> {
  final Ref ref;
  late final HomeRepo _homeRepo;
  late final ChatRepository _chatRepository;

  AvailableUsersController(this.ref) : super(NoAvailableUsers()) {
    _homeRepo = ref.read(homeRepositoryProvider);
    _chatRepository = ref.read(chatRepositoryProvider);
  }

  Future<void> search(String userId) async {
    state = LoadingState();

    try {
      final response = await _homeRepo.searchAvailableUsers();

      if (response.users.isEmpty) {
        state = NoAvailableUsers();
      }

      state = UsersAvailable(response.users);
    } catch (e, st) {
      state = ErrorState(message: e.toString(), stackTrace: st);
    }
  }

  Future<String> createConversation({
    required String userId,
    required String selectedUserId,
  }) async {
    state = LoadingState();

    try {
      final entity = CreateConversationReqEntity(participantIds: [userId, selectedUserId]);
      final response = await _chatRepository.createConversation(entity);

      if (response.id.isNotEmpty) {
        state = UsersAvailable([]);
        return response.id;
      } else {
        state = ErrorState();
        debugPrint(state.toString());
        return "";
      }
    } catch (e, st) {
      state = ErrorState(message: e.toString(), stackTrace: st);
      debugPrint(state.toString());
    }

    return "";
  }
}
