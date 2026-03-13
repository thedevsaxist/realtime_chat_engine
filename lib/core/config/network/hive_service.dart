import 'package:flutter/widgets.dart';
import 'package:hive_ce/hive.dart';
import 'package:realtime_chat_engine/core/shared/constants.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/get_messages_res_entity.dart';

class HiveService {
  static LazyBox<MessageEntity>? _chatBox;
  static LazyBox<MessageEntity> get chatBox => _chatBox!;

  static Future<void> init() async {
    try {
      // debugPrint("Opening box");
      _chatBox = await Hive.openLazyBox<MessageEntity>(Constants.chatRoomBox);

      // debugPrint("Box opened successfully");
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
