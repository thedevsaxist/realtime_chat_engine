import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/theme/app_theme.dart';
import 'package:realtime_chat_engine/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // await Hive.initFlutter();

  // Hive.registerAdapter(MessageEntityAdapter());

  // await HiveService.init();

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
      routes: {
        "/": (context) => const LoginScreen(),
        "/home": (context) => const HomeScreen(),
        "/chat": (context) => const ChatScreen(),
        },
    );
  }
}
