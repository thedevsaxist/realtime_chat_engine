import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/home/presentation/screens/home_screen.dart';
import 'package:realtime_chat_engine/features/auth/presentation/widget/auth_interface.dart';
import 'package:realtime_chat_engine/core/shared/message_bus.dart';
import 'package:realtime_chat_engine/features/auth/presentation/controller/auth_controller.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      final wasAuthenticated = previous is Authenticated;
      final isLoggedOut = next is UnAuthenticated || next is AuthError;
      if (!wasAuthenticated || !isLoggedOut) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.popUntil((route) => route.isFirst);
        }
      });
    });

    final authState = ref.watch(authControllerProvider);

    if (authState is Authenticated) {
      ref.watch(readReceiptSyncProvider);
    }

    return switch (authState) {
      Authenticated() => const HomeScreen(),
      UnAuthenticated() || AuthError() || LoadingState() => const AuthInterface(),
    };
  }
}
