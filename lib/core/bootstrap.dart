import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:realtime_chat_engine/core/utils/preload_fonts.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await preloadFonts();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // For Android
      statusBarBrightness: Brightness.dark, // For iOS
    ),
  );

  if (kReleaseMode) {
    try {
      // FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      await dotenv.load(fileName: ".env.prod");
    } catch (e) {
      debugPrint('Warning: .env.prod not found or failed to load: $e');
    }
  }

  if (kDebugMode) {
    try {
      await dotenv.load(fileName: ".env.dev");
    } catch (e) {
      debugPrint('Warning: .env.dev not found or failed to load: $e');
    }
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
}
