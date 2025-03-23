import 'package:bela_blok/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

class BelaBlokApp extends ConsumerWidget {
  const BelaBlokApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeSettingsProvider);

    return MaterialApp(
      title: 'Bela Blok',
      debugShowCheckedModeBanner: false,
      theme: getTheme(ThemeType.light, themeSettings.colorPalette),
      darkTheme: getTheme(ThemeType.dark, themeSettings.colorPalette),
      themeMode:
          themeSettings.useSystemTheme
              ? ThemeMode.system
              : (themeSettings.themeType == ThemeType.light ? ThemeMode.light : ThemeMode.dark),
      home: const HomeScreen(),
    );
  }
}
