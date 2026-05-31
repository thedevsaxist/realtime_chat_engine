import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final class AppTextStyle {
  AppTextStyle._();

  static final _isIOS = Platform.isIOS;
  static final _fallbackFontFamily = GoogleFonts.inter().fontFamily;
  static final String? fontFamily = _isIOS ? 'SFProRounded' : _fallbackFontFamily;

  static final TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w900, // Black
    fontSize: 57,
    height: 1.1,
    letterSpacing: .1,
  );

  static final TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w900, // Black
    fontSize: 45,
    height: 1.1,
  );

  static final TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w900, // Black
    fontSize: 36,
    height: 1.2,
  );

  static final TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600, // Bold
    fontSize: 32,
    height: 1.2,
  );

  static final TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600, // Bold
    fontSize: 28,
    height: 1.2,
  );

  static final TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600, // Bold
    fontSize: 24,
    height: 1.2,
  );

  static final TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 22,
    height: 1.2,
  );

  static final TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 18,
    height: 1.2,
    letterSpacing: .1,
  );

  static final TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 14,
    height: 1.2,
    letterSpacing: .1,
  );

  static final TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 14,
    height: 1.2,
    letterSpacing: .1,
  );

  static final TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 12,
    height: 1.2,
    letterSpacing: .1,
  );

  static final TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500, // Medium
    fontSize: 11,
    height: 1.2,
    letterSpacing: .1,
  );

  static final TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 16,
    height: 1.1,
    letterSpacing: 0,
  );

  static final TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 14,
    height: 1.1,
    letterSpacing: 0,
  );

  static final TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400, // Regular
    fontSize: 12,
    height: 1.1,
    letterSpacing: 0,
  );

  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
