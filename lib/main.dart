import 'package:flutter/material.dart';
import 'package:realtime_chat_engine/core/theme/app_theme.dart';
import 'package:realtime_chat_engine/features/presentation/home_screen.dart';

void main() {
  runApp(const MyApp());
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
        "/" : (context) => const HomeScreen(),
      },
    );
  }
}
