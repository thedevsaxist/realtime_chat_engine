import 'package:flutter/widgets.dart';

final class AppSpacing extends SizedBox {
  const AppSpacing.height2({super.key}) : super(height: _spacingXXXs);
  const AppSpacing.height4({super.key}) : super(height: _spacingXXs);
  const AppSpacing.height8({super.key}) : super(height: _spacingXs);
  const AppSpacing.height10({super.key}) : super(height: _spacingS);
  const AppSpacing.height16({super.key}) : super(height: _spacingM);
  const AppSpacing.height20({super.key}) : super(height: _spacingL);
  const AppSpacing.height24({super.key}) : super(height: _spacingXl);
  const AppSpacing.height32({super.key}) : super(height: _spacingXXl);

  const AppSpacing.width2({super.key}) : super(width: _spacingXXXs);
  const AppSpacing.width4({super.key}) : super(width: _spacingXXs);
  const AppSpacing.width8({super.key}) : super(width: _spacingXs);
  const AppSpacing.width10({super.key}) : super(width: _spacingS);
  const AppSpacing.width16({super.key}) : super(width: _spacingM);
  const AppSpacing.width20({super.key}) : super(width: _spacingL);
  const AppSpacing.width24({super.key}) : super(width: _spacingXl);
  const AppSpacing.width32({super.key}) : super(width: _spacingXXl);

  static const double _spacingXXXs = 2;
  static const double _spacingXXs = 4;
  static const double _spacingXs = 8;
  static const double _spacingS = 10;
  static const double _spacingM = 16;
  static const double _spacingL = 20;
  static const double _spacingXl = 24;
  static const double _spacingXXl = 32;
}
