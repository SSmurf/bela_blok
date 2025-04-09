import 'package:bela_blok/models/theme_settings.dart';
import 'package:bela_blok/providers/theme_provider.dart';
import 'package:bela_blok/providers/language_provider.dart';
import 'package:bela_blok/screens/home_screen.dart';
import 'package:bela_blok/services/local_storage_service.dart';
import 'package:bela_blok/utils/app_localizations.dart';
import 'package:bela_blok/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BelaBlokApp extends ConsumerStatefulWidget {
  const BelaBlokApp({super.key});

  @override
  ConsumerState<BelaBlokApp> createState() => _BelaBlokAppState();
}

class _BelaBlokAppState extends ConsumerState<BelaBlokApp> {
  late Future<void> _loadSettingsFuture;

  @override
  void initState() {
    super.initState();
    _loadSettingsFuture = Future.wait([_loadThemeSettings(), _loadLanguageSetting()]);
  }

  Future<void> _loadThemeSettings() async {
    final localStorage = LocalStorageService();
    final data = await localStorage.loadThemeSettings();
    if (data.isNotEmpty) {
      final loadedSettings = ThemeSettings.fromJson(data);
      ref.read(themeSettingsProvider.notifier).updateThemeSettings(loadedSettings);
    }
  }

  Future<void> _loadLanguageSetting() async {
    final localStorage = LocalStorageService();
    final settingsMap = await localStorage.loadSettings();
    if (settingsMap.isNotEmpty && settingsMap.containsKey('selectedLanguage')) {
      final savedLang = settingsMap['selectedLanguage'] as String;
      Locale newLocale;
      if (savedLang == 'English') {
        newLocale = const Locale('en');
      } else if (savedLang == 'Deutsch') {
        newLocale = const Locale('de');
      } else {
        newLocale = const Locale('hr');
      }
      ref.read(languageProvider.notifier).state = newLocale;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadSettingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }

        final themeSettings = ref.watch(themeSettingsProvider);
        final language = ref.watch(languageProvider);
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
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
              child: child!,
            );
          },
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('hr'), Locale('en'), Locale('de')],
          locale: language,
          home: const HomeScreen(),
        );
      },
    );
  }
}
