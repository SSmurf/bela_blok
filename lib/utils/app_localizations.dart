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
      'general': 'Općenito',
      'aboutDesc1':
          'Bela Blok je aplikacija namijenjena ljubiteljima igre bele. Aplikacija omogućuje jednostavno vođenje rezultata, pregled povijesti partija te prilagodbu izgleda prema vašem ukusu. Sve je osmišljeno s lakoćom korištenja, a dizajn koristi moderne principe kako bi vam pružio ugodno iskustvo.',
      'aboutDesc2':
          'Aplikacija koristi lokalnu pohranu kako bi zadržala vaše postavke i podatke o igri. Svi podaci ostaju privatni i pohranjuju se unutar uređaja.',
      'otherAppsTitle': 'Ostali bela blokovi',
      'otherAppsDesc':
          'Isprobajte i ostale aplikacije za praćenje rezultata u beli. One su bile inspiracija ovoj aplikaciji.',
      'developer': 'Developer',
      'historyTitle': 'Povijest igara',
      'historyError': 'Došlo je do greške pri učitavanju igara.',
      'noSavedGames': 'Nema spremljenih igara.',
      'ferStudent': 'Student FER-a',
      'firstTeam': 'Prvi tim',
      'secondTeam': 'Drugi tim',
      'resetTeamNames': 'Postavi na Mi / Vi',
      'we': 'Mi',
      'you': 'Vi',
      'emptyTeamName': 'Ime tima ne može biti prazno',
      'clearGameTitle': 'Brisanje igre',
      'clearGameContent': 'Jesi li siguran da želiš obrisati ovu igru?',
      'totalDeclarations': 'Zvanja',
      'totalStiglja': 'Štiglje',
      'undoLastRound': 'Poništi zadnju rundu',
      'respectTheCards': '"Poštuj karte i karte će poštovati tebe."',
      'deleteRoundTitle': 'Brisanje runde',
      'deleteRoundContent': 'Jesi li siguran da želiš obrisati ovu rundu?',
      'newGame': 'Nova igra',
      'newRound': 'Nova runda',
      'pointsTab': 'Bodovi',
      'declarationsTab': 'Zvanja',
      'allTricks': "Štiglja",
      'saveRound': 'Spremi rundu',
      'points': 'Bodovi',
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
      'themeSettings': 'Theme settings',
      'systemTheme': 'Use system theme',
      'systemThemeSubtitle': 'Follow device settings',
      'darkMode': 'Dark mode',
      'colorPalette': 'App color palette',
      'apply': 'Apply',
      'colorGreen': 'Green',
      'colorBlue': 'Blue',
      'colorRed': 'Red',
      'colorPurple': 'Purple',
      'colorGold': 'Gold',
      'general': 'General',
      'aboutDesc1':
          'Bela Blok is an app for lovers of belote. It makes score keeping, reviewing game history, and customizing the appearance very easy. The design is based on modern principles to provide you a pleasant experience.',
      'aboutDesc2':
          'The app uses local storage to save your settings and game data. All data remains private and is stored on your device.',
      'otherAppsTitle': 'Other Bela Apps',
      'otherAppsDesc': 'Try other belote score tracking apps. They inspired this one.',
      'developer': 'Developer',
      'historyTitle': 'Game history',
      'historyError': 'An error occurred while loading games.',
      'noSavedGames': 'No saved games.',
      'ferStudent': 'FER student',
      'firstTeam': 'First team',
      'secondTeam': 'Second team',
      'resetTeamNames': 'Reset to We / You',
      'we': 'We',
      'you': 'You',
      'emptyTeamName': 'Team name cannot be empty',
      'clearGameTitle': 'Delete game',
      'clearGameContent': 'Are you sure you want to delete this game?',
      'totalDeclarations': 'Declarations',
      'totalStiglja': 'All tricks',
      'undoLastRound': 'Undo last round',
      'respectTheCards': '"Respect the cards and the cards will respect you."',
      'deleteRoundTitle': 'Delete round',
      'deleteRoundContent': 'Are you sure you want to delete this round?',
      'newGame': 'New game',
      'newRound': 'New round',
      'pointsTab': 'Points',
      'declarationsTab': 'Declarations',
      'allTricks': "All tricks",
      'saveRound': 'Save round',
      'points': 'Points',
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
      'general': 'Allgemein',
      'aboutDesc1':
          'Bela Blok ist eine App für Liebhaber von Belote. Sie ermöglicht die einfache Punkteverwaltung, die Überprüfung der Spielhistorie und die Anpassung des Designs entsprechend Ihrem Geschmack. Alles ist so gestaltet, dass es leicht zu bedienen ist, und das Design folgt modernen Prinzipien, um Ihnen ein angenehmes Erlebnis zu bieten.',
      'aboutDesc2':
          'Die App verwendet lokalen Speicher, um Ihre Einstellungen und Spieldaten zu speichern. Alle Daten bleiben privat und werden auf Ihrem Gerät gespeichert.',
      'otherAppsTitle': 'Weitere Bela Apps',
      'otherAppsDesc':
          'Probieren Sie auch unsere anderen Apps zur Punktverfolgung bei Belote aus, die diese App inspiriert haben.',
      'developer': 'Entwickler',
      'historyTitle': 'Spielhistorie',
      'historyError': 'Beim Laden der Spiele ist ein Fehler aufgetreten.',
      'noSavedGames': 'Keine gespeicherten Spiele.',
      'ferStudent': 'FER Student',
      'firstTeam': 'Erstes Team',
      'secondTeam': 'Zweites Team',
      'resetTeamNames': 'Auf Wir / Ihr zurücksetzen',
      'we': 'Wir',
      'you': 'Ihr',
      'emptyTeamName': 'Der Teamname darf nicht leer sein',
      'clearGameTitle': 'Spiel löschen',
      'clearGameContent': 'Sind Sie sicher, dass Sie dieses Spiel löschen möchten?',
      'totalDeclarations': 'Gesamte Deklarationen',
      'totalStiglja': 'Gesamte Stiglja',
      'undoLastRound': 'Letzte Runde rückgängig machen',
      'respectTheCards': '"Respektiere die Karten, und die Karten werden dich respektieren."',
      'deleteRoundTitle': 'Runde löschen',
      'deleteRoundContent': 'Sind Sie sicher, dass Sie diese Runde löschen möchten?',
      'newGame': 'Neues Spiel',
      'newRound': 'Neue Runde',
      'pointsTab': 'Points',
      'declarationsTab': 'Declarations',
      'allTricks': 'All tricks',
      'saveRound': 'Spiele Runde',
      'points': 'Punkte',
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
