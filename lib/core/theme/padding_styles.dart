import 'package:flutter/material.dart';

class AppPaddingStyles {
  // horizontal only
  static final paddingH24 = EdgeInsets.symmetric(horizontal: 24);
  static final paddingH16 = EdgeInsets.symmetric(horizontal: 16);
  static final paddingH12 = EdgeInsets.symmetric(horizontal: 12);

  // all sides
  static final paddingA24 = EdgeInsets.all(24);
  static final paddingA12 = EdgeInsets.all(12);

  // horizontal and vertical (different)
  static final paddingH16V12 = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static final paddingH12V8 = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  static final paddingH8V4 = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
}
