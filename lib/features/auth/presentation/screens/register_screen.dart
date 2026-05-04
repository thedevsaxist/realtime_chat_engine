import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/theme/app_colors.dart';
import 'package:realtime_chat_engine/core/theme/font_weights.dart';
import 'package:realtime_chat_engine/features/auth/presentation/widget/auth_text_field.dart';

import '../controller/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final VoidCallback onSwitchToLogin;

  const RegisterScreen({super.key, required this.onSwitchToLogin});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  late TapGestureRecognizer _switchToLoginScreen;

  @override
  void initState() {
    super.initState();

    _switchToLoginScreen = TapGestureRecognizer()..onTap = _handlePress;
  }

  @override
  void dispose() {
    _switchToLoginScreen.dispose();
    super.dispose();
  }

  void _handlePress() {
    widget.onSwitchToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,

      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            "Register",
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
              // first name
              AuthTextField(
                controller: firstNameController,
                label: "First Name",
              ),
              SizedBox(height: 10),

              // last name
              AuthTextField(controller: lastNameController, label: "Last Name"),
              SizedBox(height: 10),

              // email
              AuthTextField(controller: emailController, label: "Email"),
              SizedBox(height: 10),

              // password
              AuthTextField(controller: passwordController, label: "Password"),
              SizedBox(height: 30),

              ListenableBuilder(
                listenable: Listenable.merge([
                  emailController,
                  passwordController,
                  firstNameController,
                  lastNameController,
                ]),
                builder: (context, child) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: .symmetric(horizontal: 16, vertical: 12),
                      // backgroundColor: Colors.red,
                    ),
                    onPressed:
                        emailController.text.isEmpty ||
                            passwordController.text.isEmpty ||
                            firstNameController.text.isEmpty ||
                            lastNameController.text.isEmpty
                        ? null
                        : () {
                            ref
                                .read(authControllerProvider.notifier)
                                .registerUser(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                  firstName: firstNameController.text.trim(),
                                  lastName: lastNameController.text.trim(),
                                );
                          },
                    child: const Text("Sign up"),
                  );
                },
              ),

              SizedBox(height: 10),

              RichText(
                text: TextSpan(
                  text: "Already have an account? ",
                  style: TextStyle(color: Colors.black),

                  children: [
                    TextSpan(
                      recognizer: _switchToLoginScreen,
                      text: "Login",
                      style: TextStyle(
                        fontStyle: .italic,
                        color: AppColors.primaryBlue,
                      ),
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
