import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:realtime_chat_engine/core/shared/constants.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_messages_res_entity.dart';
import 'package:realtime_chat_engine/features/home/data/repos/chat_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// part 'home_controller.g.dart';

sealed class HomeControllerState {
  const HomeControllerState();
}

final class HomeControllerStateLoading extends HomeControllerState {
  const HomeControllerStateLoading();
}

final class HomeControllerStateSuccess extends HomeControllerState {
  final GetMessagesResEntity data;
  const HomeControllerStateSuccess(this.data);
}

final class HomeControllerStateError extends HomeControllerState {
  final String error;
  final String stackTrace;
  const HomeControllerStateError(this.error, this.stackTrace);
}

final homeControllerProvider = StateNotifierProvider<HomeController, HomeControllerState>((ref) {
  return HomeController(ref);
});

class HomeController extends StateNotifier<HomeControllerState> {
  final Ref ref;
  ChatRepositoryImpl? _chatRepository;

  HomeController(this.ref) : super(HomeControllerStateLoading()) {
    _chatRepository = ref.watch(chatRepositoryProvider);

    _init();
  }

  void _init() {
    _chatRepository
        ?.getMessages(Constants.conversationId)
        .then((value) {
          state = HomeControllerStateSuccess(value);
        })
        .onError((Exception error, StackTrace stackTrace) {
          state = HomeControllerStateError(error.toString(), stackTrace.toString());
        });
  }

  void clearCache() {
    try {
      _chatRepository?.clearCache();
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Couldn't clear cache $e");
    }
  }
}
