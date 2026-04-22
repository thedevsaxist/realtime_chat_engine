import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/login_screen_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginScreenControllerProvider);

    if (state is Authenticated) {
      Navigator.pushNamed(context, "/home");
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            TextField(
              controller: userIdController,
              decoration: InputDecoration(hintText: "User Id", border: OutlineInputBorder()),
            ),

            SizedBox(height: 10),

            TextField(
              controller: passwordController,
              decoration: InputDecoration(hintText: "Password", border: OutlineInputBorder()),
            ),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: userIdController.text.isEmpty || passwordController.text.isEmpty
                  ? null
                  : () {
                      ref
                          .read(loginScreenControllerProvider.notifier)
                          .login(userIdController.text.trim(), passwordController.text.trim());
                    },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
