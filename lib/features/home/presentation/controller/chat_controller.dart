import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';
import 'package:realtime_chat_engine/features/home/domain/usecases/delete_messages_usecase.dart';
import 'package:realtime_chat_engine/features/home/domain/usecases/get_messages_usecase.dart';
import 'package:riverpod/legacy.dart';

final chatControllerProvider = StateNotifierProvider((ref) => ChatController(ref));

class ChatController extends StateNotifier<List<MessageEntity>> {
  final Ref ref;
  GetMessagesUsecase? _getMessagesUsecase;
  DeleteMessagesUsecase? _deleteMessagesUsecase;

  ChatController(this.ref) : super([]) {
    _getMessagesUsecase = ref.watch(getMessagesUsecaseProvider);
    _deleteMessagesUsecase = ref.watch(deleteMessageUsecaseProvider);

    _init();
  }

  void _init() {
    _getMessagesUsecase
        ?.call("7feae4b2-7ae9-4181-b9fa-d9d7841f5734")
        .then((value) {
          state = value.data["messages"]!;
        })
        .onError((error, stackTrace) {
          debugPrint(error.toString());
          state = [];
        });
  }

  void sendMessage(String message){
    try {
      // _createMessage?.call()
    } catch (e) {
      
    }
  }

  void deleteMessage(String messageId) {
    try {
      _deleteMessagesUsecase?.call(messageId, "7feae4b2-7ae9-4181-b9fa-d9d7841f5734");
      ref.invalidateSelf();
    } catch (e) {
      debugPrint("Couldn't delete message $e");
    }
  }
}
