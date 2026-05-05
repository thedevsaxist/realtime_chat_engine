import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/user_entity.dart';
import 'package:realtime_chat_engine/features/home/data/repos/home_repository_impl.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/search_available_users_req_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/repositories/home_repo.dart';

final availableUsersController =
    StateNotifierProvider<AvailableUsersController, AvailableUsersState>((ref) {
      return AvailableUsersController(ref);
    });

sealed class AvailableUsersState {}

class NoAvailableUsers extends AvailableUsersState {}

class LoadingState extends AvailableUsersState {}

class ErrorState extends AvailableUsersState {
  final String message;
  final StackTrace? stacktrace;

  ErrorState(this.message, this.stacktrace);
}

class UsersAvailable extends AvailableUsersState {
  final List<UserEntity> users;

  UsersAvailable(this.users);
}

class AvailableUsersController extends StateNotifier<AvailableUsersState> {
  final Ref ref;
  HomeRepo? _homeRepo;

  AvailableUsersController(this.ref) : super(NoAvailableUsers()) {
    _homeRepo = ref.watch(homeRepositoryProvider);
  }

  Future<void> search(String userId) async {
    state = LoadingState();
    final request = SearchAvailableUsersReqEntity(userId: userId);

    try {
      final response = await _homeRepo?.searchAvailableUsers(request);

      if (response == null) {
        state = NoAvailableUsers();
      }

      state = UsersAvailable(response!.users);
    } catch (e, st) {
      state = ErrorState(e.toString(), st);
    }
  }
}
