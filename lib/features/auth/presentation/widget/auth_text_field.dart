import 'package:flutter/material.dart';
import 'package:realtime_chat_engine/core/theme/app_colors.dart';

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
        labelStyle: TextStyle(color: AppColors.neutral500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12)
        ),
      ),
    );
  }
}
