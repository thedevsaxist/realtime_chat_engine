import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/chat/presentation/screens/chat_screen.dart';
import 'package:realtime_chat_engine/features/profile/presentation/screens/profile_screen.dart';

import 'config/auth_gate.dart';
import 'shared/constants.dart';
import 'theme/app_theme.dart';

class RealtimeChatApp extends ConsumerWidget {
  const RealtimeChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    

    return MaterialApp(
      navigatorKey: Constants.navigationKey,
      title: 'Realtime Chat Engine',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: kDebugMode,
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
