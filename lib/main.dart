import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'package:realtime_chat_engine/core/theme/app_theme.dart';
import 'package:realtime_chat_engine/core/config/auth_date.dart';
import 'package:realtime_chat_engine/features/profile/presentation/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'Realtime Chat Engine',
      theme: AppTheme.light,
      home: AuthGate(),
      routes: {'/profile': (context) => ProfileScreen()},
      onGenerateRoute: (settings) {
        if (settings.name == "/chat") {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: args['conversationId']!,
              receiverName: args['receiverName']!,
            ),
          );
        }
        return null;
      },
    );
  }
}
