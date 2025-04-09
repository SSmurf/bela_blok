import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'hr': {
      'settings': 'Postavke',
      'gameTo': 'Igra se do',
      'stigljaValue': 'Vrijednost štiglje',
      'teamNames': 'Imena timova',
      'language': 'Jezik',
      'keepScreenOn': 'Drži zaslon upaljen',
      'design': 'Dizajn',
      'rules': 'Pravila bele',
      'unspokenRules': 'Nepisana pravila bele',
      'aboutApp': 'O aplikaciji',
      'cancel': 'Odbaci',
      'save': 'Spremi',
      'deleteHistoryTileTitle': 'Izbriši povijest igara',
      'deleteHistoryDialogTitle': 'Brisanje povijesti',
      'deleteHistoryDialogContent': 'Jeste li sigurni da želite izbrisati povijest igara?',
      'delete': 'Obriši',
      'themeSettings': 'Postavke teme',
      'systemTheme': 'Koristi sistemsku temu',
      'systemThemeSubtitle': 'Prati postavke uređaja',
      'darkMode': 'Tamni način rada',
      'colorPalette': 'Izbor boje aplikacije',
      'apply': 'Primijeni',
      'colorGreen': 'Zelena',
      'colorBlue': 'Plava',
      'colorRed': 'Crvena',
      'colorPurple': 'Ljubičasta',
      'colorGold': 'Zlatna',
    },
    'en': {
      'settings': 'Settings',
      'gameTo': 'Game goal',
      'stigljaValue': 'All tricks value',
      'teamNames': 'Team names',
      'language': 'Language',
      'keepScreenOn': 'Keep screen awake',
      'design': 'Design',
      'rules': 'Belote rules',
      'unspokenRules': 'Unwritten Belote rules',
      'aboutApp': 'About app',
      'cancel': 'Cancel',
      'save': 'Save',
      'deleteHistoryTileTitle': 'Delete game history',
      'deleteHistoryDialogTitle': 'Delete History',
      'deleteHistoryDialogContent': 'Are you sure you want to delete the game history?',
      'delete': 'Delete',
      'themeSettings': 'Theme Settings',
      'systemTheme': 'Use system theme',
      'systemThemeSubtitle': 'Follow device settings',
      'darkMode': 'Dark mode',
      'colorPalette': 'App Color Palette',
      'apply': 'Apply',
      'colorGreen': 'Green',
      'colorBlue': 'Blue',
      'colorRed': 'Red',
      'colorPurple': 'Purple',
      'colorGold': 'Gold',
    },
    'de': {
      'settings': 'Einstellungen',
      'gameTo': 'Spiel bis',
      'stigljaValue': 'Stiglja-Wert',
      'teamNames': 'Teamnamen',
      'language': 'Sprache',
      'keepScreenOn': 'Bildschirm anlassen',
      'design': 'Design',
      'rules': 'Belote Regeln',
      'unspokenRules': 'Unschriftliche Belote Regeln',
      'aboutApp': 'Über App',
      'cancel': 'Abbrechen',
      'save': 'Speichern',
      'deleteHistoryTileTitle': 'Spielhistorie löschen',
      'deleteHistoryDialogTitle': 'Historie löschen',
      'deleteHistoryDialogContent': 'Sind Sie sicher, dass Sie die Spielhistorie löschen wollen?',
      'delete': 'Löschen',
      'themeSettings': 'Themen-Einstellungen',
      'systemTheme': 'Systemthema verwenden',
      'systemThemeSubtitle': 'Geräteeinstellungen folgen',
      'darkMode': 'Dunkelmodus',
      'colorPalette': 'App-Farbpalette',
      'apply': 'Anwenden',
      'colorGreen': 'Grün',
      'colorBlue': 'Blau',
      'colorRed': 'Rot',
      'colorPurple': 'Lila',
      'colorGold': 'Gold',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['hr', 'en', 'de'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
