import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realtime_chat_engine/core/theme/app_theme_extension.dart';

import 'app_color_scheme.dart';
import 'app_text_styles.dart';

final class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = AppColorScheme.light;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: GoogleFonts.inter().fontFamily,
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
        menuPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        enableFeedback: true,
        position: PopupMenuPosition.under,
      ),

      textTheme: AppTextStyle.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),

      extensions: <ThemeExtension<dynamic>>[AppThemeExtension.light],
    );
  }

  static ThemeData get dark {
    final scheme = AppColorScheme.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: GoogleFonts.inter().fontFamily,
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
        menuPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        enableFeedback: true,
        position: PopupMenuPosition.under,
      ),

      textTheme: AppTextStyle.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),

      extensions: <ThemeExtension<dynamic>>[AppThemeExtension.dark],
    );
  }
}
