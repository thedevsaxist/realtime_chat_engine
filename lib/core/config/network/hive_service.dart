import 'package:flutter/widgets.dart';
import 'package:hive_ce/hive.dart';
import 'package:realtime_chat_engine/core/shared/constants.dart';
import 'package:realtime_chat_engine/features/home/data/data_source/chat_room.dart';

class HiveService {
  static LazyBox<ChatRoomModel>? _chatBox;
  static LazyBox<ChatRoomModel> get chatBox => _chatBox!;

  static Future<void> init() async {
    try {
      // debugPrint("Opening box");
      _chatBox = await Hive.openLazyBox<ChatRoomModel>(Constants.chatRoomBox);

      // debugPrint("Box opened successfully");
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
