import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/theme/app_theme.dart';
import 'package:realtime_chat_engine/features/auth/presentation/controller/auth_controller.dart';
import 'package:realtime_chat_engine/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    
    return MaterialApp(
      title: 'Realtime Chat Engine',
      theme: AppTheme.light,
      home: switch (authState) {
        Authenticated() => const HomeScreen(),
        UnAuthenticated() => const LoginScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == "/chat") {
          final conversationId = settings.arguments as String;
          return MaterialPageRoute(builder: (context) => ChatScreen(conversationId: conversationId));
        }
        return null;
      },
    );
  }
}
