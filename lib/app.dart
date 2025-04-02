import 'package:bela_blok/models/theme_settings.dart';
import 'package:bela_blok/providers/theme_provider.dart';
import 'package:bela_blok/screens/home_screen.dart';
import 'package:bela_blok/services/local_storage_service.dart';
import 'package:bela_blok/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BelaBlokApp extends ConsumerStatefulWidget {
  const BelaBlokApp({super.key});

  @override
  ConsumerState<BelaBlokApp> createState() => _BelaBlokAppState();
}

class _BelaBlokAppState extends ConsumerState<BelaBlokApp> {
  late Future<void> _themeLoadFuture;

  @override
  void initState() {
    super.initState();
    _themeLoadFuture = _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    final localStorage = LocalStorageService();
    final data = await localStorage.loadThemeSettings();
    if (data.isNotEmpty) {
      final loadedSettings = ThemeSettings.fromJson(data);
      ref.read(themeSettingsProvider.notifier).updateThemeSettings(loadedSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _themeLoadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }

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
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            print("Screen width: ${mediaQuery.size.width}, Screen height: ${mediaQuery.size.height}");
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
          home: const HomeScreen(),
        );
      },
    );
  }
}
