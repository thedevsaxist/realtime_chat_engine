import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/theme/app_colors.dart';
import 'package:realtime_chat_engine/core/theme/font_weights.dart';

import '../controller/auth_controller.dart';
import '../widget/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onSwitchToRegister;

  const LoginScreen({super.key, required this.onSwitchToRegister});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late TapGestureRecognizer _switchToRegisterScreen;

  @override
  void initState() {
    super.initState();
    _switchToRegisterScreen = TapGestureRecognizer()..onTap = _handlePress;
  }

  @override
  void dispose() {
    _switchToRegisterScreen.dispose();
    super.dispose();
  }

  void _handlePress() {
    widget.onSwitchToRegister();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state is LoadingState;

    if (state is AuthError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
      });
    }

    return Stack(
      children: [
        _buildBody(),
        if (isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,

      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            "Login",
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: AppFontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // email
              AuthTextField(controller: emailController, label: "Email"),
              SizedBox(height: 10),

              // password
              AuthTextField(controller: passwordController, label: "Password"),
              SizedBox(height: 30),

              ListenableBuilder(
                listenable: Listenable.merge([emailController, passwordController]),
                builder: (context, child) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: .symmetric(horizontal: 16, vertical: 12),
                      // backgroundColor: Colors.red,
                    ),
                    onPressed: emailController.text.isEmpty || passwordController.text.isEmpty
                        ? null
                        : () {
                            ref
                                .read(authControllerProvider.notifier)
                                .login(emailController.text.trim(), passwordController.text.trim());
                          },
                    child: const Text("Login"),
                  );
                },
              ),

              SizedBox(height: 10),

              RichText(
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      recognizer: _switchToRegisterScreen,
                      text: "Sign up",

                      style: TextStyle(fontStyle: .italic, color: AppColors.primaryBlue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
