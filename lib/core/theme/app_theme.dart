import 'package:flutter/material.dart';
import 'package:realtime_chat_engine/core/theme/app_colors.dart';

import 'text_styles.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryBlue500,
      scaffoldBackgroundColor: AppColors.neutral100,
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryBlue500,
        onPrimary: AppColors.neutral100,
        outline: AppColors.neutral500,
      ),

      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
        menuPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2), 
        enableFeedback: true,
        position: PopupMenuPosition.under,
        color: AppColors.neutral100,
      ),

      textTheme: TextTheme(
        titleLarge: AppTextStyle.titleLarge,
        titleMedium: AppTextStyle.titleMedium,
        titleSmall: AppTextStyle.titleSmall,
        bodyLarge: AppTextStyle.bodyLarge,
        bodyMedium: AppTextStyle.bodyMedium,
        bodySmall: AppTextStyle.bodySmall,
        displayLarge: AppTextStyle.displayLarge,
        displayMedium: AppTextStyle.displayMedium,
        displaySmall: AppTextStyle.displaySmall,
        headlineLarge: AppTextStyle.headlineLarge,
        headlineMedium: AppTextStyle.headlineMedium,
        headlineSmall: AppTextStyle.headlineSmall,
        labelLarge: AppTextStyle.labelLarge,
        labelMedium: AppTextStyle.labelMedium,
        labelSmall: AppTextStyle.labelSmall,
      ),
    );
  }

  
}
