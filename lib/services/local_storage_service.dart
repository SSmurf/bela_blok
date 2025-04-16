import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game.dart';
import '../models/round.dart';

class LocalStorageService {
  Future<void> saveGame(
    List<Round> rounds, {
    required String teamOneName,
    required String teamTwoName,
    int goalScore = 1001,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final game = Game(
      teamOneName: teamOneName,
      teamTwoName: teamTwoName,
      rounds: rounds,
      createdAt: DateTime.now(),
      goalScore: goalScore,
    );
    final gameJson = json.encode(game.toJson());
    final key = 'saved_game_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(key, gameJson);
    await prefs.setString('latest_game_key', key);
    print('Game saved under key: $key');
  }

  Future<List<Game>> loadGames() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('saved_game_')).toList();
    List<Game> games = [];
    for (final key in keys) {
      final String? gameJson = prefs.getString(key);
      if (gameJson != null) {
        try {
          final Map<String, dynamic> gameData = json.decode(gameJson);
          final game = Game.fromJson(gameData);
          games.add(game);
        } catch (e) {
          print('Error decoding game for key $key: $e');
        }
      }
    }
    games.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return games;
  }

  Future<bool> deleteLatestGame() async {
    final prefs = await SharedPreferences.getInstance();
    final latestKey = prefs.getString('latest_game_key');

    if (latestKey != null) {
      final result = await prefs.remove(latestKey);
      if (result) {
        print('Deleted latest game with key: $latestKey');
        await prefs.remove('latest_game_key');
        return true;
      }
    }
    return false;
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = json.encode(settings);
    await prefs.setString('app_settings', settingsJson);
    print('Settings saved: $settingsJson');
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('app_settings');
    if (settingsJson != null) {
      try {
        return json.decode(settingsJson) as Map<String, dynamic>;
      } catch (e) {
        print('Error decoding settings: $e');
        return {};
      }
    }
    return {};
  }

  Future<void> saveThemeSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = json.encode(settings);
    await prefs.setString('theme_settings', settingsJson);
  }

  Future<Map<String, dynamic>> loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('theme_settings');
    if (settingsJson != null) {
      try {
        return json.decode(settingsJson) as Map<String, dynamic>;
      } catch (e) {
        print('Error decoding theme settings: $e');
        return {};
      }
    }
    return {};
  }
}
