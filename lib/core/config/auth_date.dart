import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/home/presentation/screens/home_screen.dart';
import 'package:realtime_chat_engine/features/auth/presentation/widget/auth_interface.dart';
import 'package:realtime_chat_engine/features/auth/presentation/controller/auth_controller.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return switch (authState) {
      Authenticated() => const HomeScreen(),
      UnAuthenticated() || AuthError() => const AuthInterface(),
    };
  }
}
