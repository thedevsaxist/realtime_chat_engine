// ignore_for_file: prefer-match-file-name, public_member_api_docs
import 'package:flutter/material.dart';

class AppRadiusStyles {
  static final full = BorderRadius.circular(99);

  static final borderRadius4 = BorderRadius.circular(4);
  static final borderRadius8 = BorderRadius.circular(8);
  static final borderRadius12 = BorderRadius.circular(12);
  static final borderRadius14 = BorderRadius.circular(14);
  static final borderRadius16 = BorderRadius.circular(16);
  static final borderRadius18 = BorderRadius.circular(18);
  static final borderRadius24 = BorderRadius.circular(24);
  static final borderRadius32 = BorderRadius.circular(32);

  static final borderRadiusTB14 = BorderRadius.only(
    topLeft: Radius.circular(14),
    bottomLeft: Radius.circular(14),
  );

  static final borderRadiusLR8 = BorderRadius.only(
    topLeft: Radius.circular(8),
    topRight: Radius.circular(8),
  );

  static final bottomSheetRadius = BorderRadius.only(
    topLeft: Radius.circular(16),
    topRight: Radius.circular(16),
  );
}
