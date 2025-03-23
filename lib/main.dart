import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'app.dart';

Future<void> initGoogleFonts() async {
  await GoogleFonts.pendingFonts([GoogleFonts.getFont('Nunito')]);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();

  try {
    await initGoogleFonts();
  } catch (e) {
    debugPrint('Google Fonts initialization error: $e');
    // Continue with the app even if fonts fail to load
  }

  runApp(const ProviderScope(child: BelaBlokApp()));
}
