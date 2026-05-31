import 'package:flutter/material.dart';

import 'app_colors.dart';

final class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.brandPrimary,
    required this.brandSecondary,
    required this.success,
    required this.warning,
    required this.info,
    required this.cardBackground,
    required this.divider,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.grayBubble,
    required this.textFieldColor,
    required this.textColorGray,
    required this.neutral500,
  });

  final Color brandPrimary;
  final Color brandSecondary;
  final Color success;
  final Color warning;
  final Color info;
  final Color cardBackground;
  final Color divider;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color grayBubble;
  final Color textFieldColor;
  final Color textColorGray;
  final Color neutral500;

  static AppThemeExtension light = AppThemeExtension(
    brandPrimary: AppColors.light.primary,
    brandSecondary: AppColors.light.secondary,
    success: AppColors.light.tertiary,
    warning: const Color(0xFFFF9800),
    info: AppColors.light.secondary,
    grayBubble: Color(0xFFEFEFEF),
    textFieldColor: Color(0xFFf6f6f6),
    textColorGray: Color(0xFFA6A6A6),
    cardBackground: AppColors.light.surface,
    divider: AppColors.light.outlineVariant,
    shimmerBase: const Color(0xFFE0E0E0),
    shimmerHighlight: const Color(0xFFF5F5F5),
    neutral500: const Color(0xFF8899A6),
  );

  static AppThemeExtension dark = AppThemeExtension(
    brandPrimary: AppColors.dark.primary,
    brandSecondary: AppColors.dark.secondary,
    success: AppColors.dark.tertiary,
    warning: const Color(0xFFFFB74D),
    info: AppColors.dark.secondary,
    grayBubble: Color(0xFFEFEFEF),
    cardBackground: AppColors.dark.surfaceContainerHighest,
    divider: AppColors.dark.outlineVariant,
    shimmerBase: const Color(0xFF424242),
    shimmerHighlight: const Color(0xFF616161),
    textFieldColor: Color(0xFFf6f6f6),
    textColorGray: Color(0xFFA6A6A6),
    neutral500: Color(0xFF8899A6),
  );

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? brandPrimary,
    Color? brandSecondary,
    Color? success,
    Color? warning,
    Color? info,
    Color? cardBackground,
    Color? divider,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? grayBubble,
    Color? textFieldColor,
    Color? textColorGray,
    Color? neutral500,
  }) {
    return AppThemeExtension(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      grayBubble: grayBubble ?? this.grayBubble,
      cardBackground: cardBackground ?? this.cardBackground,
      divider: divider ?? this.divider,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      textFieldColor: textFieldColor ?? this.textFieldColor,
      textColorGray: textColorGray ?? this.textColorGray,
      neutral500: neutral500 ?? this.neutral500,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }

    return AppThemeExtension(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandSecondary: Color.lerp(brandSecondary, other.brandSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      grayBubble: Color.lerp(grayBubble, other.grayBubble, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      textFieldColor: Color.lerp(textFieldColor, other.textFieldColor, t)!,
      textColorGray: Color.lerp(textColorGray, other.textColorGray, t)!,
      neutral500: Color.lerp(neutral500, other.neutral500, t)!,
    );
  }
}

extension AppThemeExtensionContext on BuildContext {
  AppThemeExtension get appTheme => Theme.of(this).extension<AppThemeExtension>()!;
}

extension AppTextThemeContext on BuildContext {
  TextTheme get appTextTheme => Theme.of(this).textTheme;
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
