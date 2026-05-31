import 'package:flutter/material.dart';
import 'package:realtime_chat_engine/core/theme/app_theme_extension.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: context.appTheme.neutral500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12)
        ),
      ),
    );
  }
}
