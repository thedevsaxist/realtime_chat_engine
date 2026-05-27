import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/bootstrap.dart';
import 'core/realtime_chat_app.dart';

void main() async {
  await bootstrap();

  runApp(const ProviderScope(child: RealtimeChatApp()));
}
