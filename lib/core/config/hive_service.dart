// import 'package:flutter/widgets.dart';
// import 'package:hive_ce/hive.dart';
// import 'package:realtime_chat_engine/core/shared/constants.dart';

// class HiveService {
//   static Box? _chatBox;
//   static Box get chatBox => _chatBox!;

//   static Future<void> init() async {
//     try {
//       /*
//         The rule with Hive and lists of custom types: always open the box untyped, and always cast the result manually after reading.
//       */
//       _chatBox = await Hive.openBox(Constants.chatRoomBox);

//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }
// }
