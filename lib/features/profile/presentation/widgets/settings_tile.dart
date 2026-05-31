import 'package:flutter/material.dart';
import 'package:realtime_chat_engine/core/theme/app_theme_extension.dart';
import 'package:realtime_chat_engine/core/theme/font_weights.dart';
import 'package:realtime_chat_engine/core/theme/app_text_styles.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData icon;

  const SettingsTile({super.key, required this.title, required this.subTitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      titleAlignment: .titleHeight,
      contentPadding: .zero,
      leading: Icon(icon, size: 28),
      title: Text(
        title,
        style: AppTextStyle.bodyLarge.copyWith(
          fontWeight: AppFontWeight.semiBold,
          letterSpacing: 0,
        ),
      ),
      subtitle: Text(
        subTitle,
        style: AppTextStyle.labelLarge.copyWith(
          color: context.appTheme.neutral500,
          fontWeight: AppFontWeight.light,
        ),
      ),
    );
  }
}
