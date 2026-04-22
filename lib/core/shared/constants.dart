import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static final String baseUrl = dotenv.env["BASEURL"] ?? "No url found";
  static final String chatRoomBox = "chat_room";
  static final String conversationId = "7feae4b2-7ae9-4181-b9fa-d9d7841f5734";
  static final String authDbPassword = dotenv.env["AUTH_DB_PASSWORD"] ?? "No password found";
}
