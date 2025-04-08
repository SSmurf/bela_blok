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
    },
    'en': {
      'settings': 'Settings',
      'gameTo': 'Game goal',
      'stigljaValue': 'Stiglja value',
      'teamNames': 'Team names',
      'language': 'Language',
      'keepScreenOn': 'Keep screen on',
      'design': 'Design',
      'rules': 'Belote rules',
      'unspokenRules': 'Unwritten Belote rules',
      'aboutApp': 'About app',
      'cancel': 'Cancel',
      'save': 'Save',
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
