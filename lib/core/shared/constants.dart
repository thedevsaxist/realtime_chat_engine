import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static final String baseUrl = dotenv.env["BASEURL"] ?? "No url found";
  static final String chatRoomBox = "conersation";
}
