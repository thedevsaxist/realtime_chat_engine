import 'package:flutter_riverpod/legacy.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_messages_res_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/usecases/get_messages_usecase.dart';
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
  GetMessagesUsecase? _getMessagesUsecase;

  HomeController(this.ref) : super(HomeControllerStateLoading()) {
    _getMessagesUsecase = ref.watch(getMessagesUsecaseProvider);

    _init();
  }

  void _init() {
    _getMessagesUsecase
        ?.call("7feae4b2-7ae9-4181-b9fa-d9d7841f5734")
        .then((value) {
          state = HomeControllerStateSuccess(value);
        })
        .onError((error, stackTrace) {
          state = HomeControllerStateError(error.toString(), stackTrace.toString());
        });
  }
}
