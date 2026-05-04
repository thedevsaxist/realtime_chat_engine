import 'package:flutter/material.dart';
import 'package:realtime_chat_engine/features/auth/presentation/screens/login_screen.dart';
import 'package:realtime_chat_engine/features/auth/presentation/screens/register_screen.dart';

class AuthInterface extends StatefulWidget {
  const AuthInterface({super.key});

  @override
  State<AuthInterface> createState() => _AuthInterfaceState();
}

class _AuthInterfaceState extends State<AuthInterface> {
  bool toggle = false;

  void toggleAuthScreens() {
    setState(() => toggle = !toggle);
  }

  @override
  Widget build(BuildContext context) {
    if (toggle) {
      return RegisterScreen(onSwitchToLogin: () => toggleAuthScreens());
    } else {
      return LoginScreen(onSwitchToRegister: () => toggleAuthScreens());
    }
  }
}
