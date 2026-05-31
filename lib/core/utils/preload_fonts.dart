import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realtime_chat_engine/core/theme/font_weights.dart';

Future<void> preloadFonts() async {
  await GoogleFonts.pendingFonts([
    _loadFontFile('assets/fonts/SF Pro Rounded/SF-Pro-Rounded-Regular.otf'),
    _loadFontFile('assets/fonts/SF Pro Rounded/SF-Pro-Rounded-Semibold.otf'),
    GoogleFonts.inter(fontWeight: AppFontWeight.regular),
    GoogleFonts.inter(fontWeight: AppFontWeight.semiBold),
  ]);

  _preloadOtherFonts();
}

Future<void> _loadFontFile(String path) async {
  final fontLoader = FontLoader('SFProRounded');
  fontLoader.addFont(rootBundle.load(path));
  await fontLoader.load();
}

Future<void> _preloadOtherFonts() async {
  await GoogleFonts.pendingFonts([
    GoogleFonts.inter(fontWeight: AppFontWeight.bold),
    _loadFontFile('assets/fonts/SF Pro Rounded/SF-Pro-Rounded-Bold.otf'),
  ]);
}
