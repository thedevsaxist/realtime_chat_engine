import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/theme/app_theme.dart';
import 'package:realtime_chat_engine/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/home/presentation/screens/chat_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realtime Chat Engine',
      theme: AppTheme.light,
      initialRoute: "/",
      routes: {"/": (context) => const HomeScreen(), "/chat": (context) => const ChatScreen()},
    );
  }
}
