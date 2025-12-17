import 'dart:convert';
import 'package:bela_blok/services/review_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game.dart';
import '../models/round.dart';
import '../models/three_player_game.dart';
import '../models/three_player_round.dart';

class LocalStorageService {
  static const String _currentGameKey = 'current_game';
  static const String _currentThreePlayerGameKey = 'current_three_player_game';
  Future<void> saveGame(
    List<Round> rounds, {
    required String teamOneName,
    required String teamTwoName,
    int goalScore = 1001,
    DateTime? createdAt,
    bool isCanceled = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final game = Game(
      teamOneName: teamOneName,
      teamTwoName: teamTwoName,
      rounds: rounds,
      createdAt: createdAt ?? DateTime.now(),
      goalScore: goalScore,
      isCanceled: isCanceled,
    );
    final gameJson = json.encode(game.toJson());
    final key = 'saved_game_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(key, gameJson);
    await prefs.setString('latest_game_key', key);
    print('Game saved under key: $key');

    if (!isCanceled) {
      await ReviewService.incrementCompletedGames();
    }
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

  Future<bool> deleteGame(Game gameToDelete) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('saved_game_')).toList();

    for (final key in keys) {
      final String? gameJson = prefs.getString(key);
      if (gameJson != null) {
        try {
          final Map<String, dynamic> gameData = json.decode(gameJson);
          // Compare IDs
          if (gameData['id'] == gameToDelete.id) {
            await prefs.remove(key);
            print('Deleted game with key: $key');
            return true;
          }
        } catch (e) {
          print('Error checking game for deletion: $e');
        }
      }
    }
    return false;
  }

  Future<Game?> loadCurrentGame() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_currentGameKey);
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> gameData = json.decode(jsonString);
      return Game.fromJson(gameData);
    } catch (e) {
      print('Error decoding current game: $e');
      return null;
    }
  }

  Future<Game> saveCurrentGame(Game game) async {
    final prefs = await SharedPreferences.getInstance();
    Game gameToSave = game;
    // We want to preserve the createdAt if it's an existing current game,
    // but here we are saving a specific game object which should already have the correct createdAt.
    // However, logic in HomeScreen might rely on existing current game logic.
    // Let's trust the passed 'game' object's properties.
    // BUT, the existing logic checked _currentGameKey to preserve createdAt.
    // Since we are overwriting with a specific game (e.g. from history), we should probably respect its createdAt.

    final existingJson = prefs.getString(_currentGameKey);
    if (existingJson != null) {
      // If we are continuing a game, we might want to keep ITs created at, not the one currently in storage (if any).
      // If we are just updating the current game, we want to keep the current game's created at.
      // The calling code handles providing the correct game object.
      // The check below was likely for when we pass a NEW game object but want to keep the session.
    }

    await prefs.setString(_currentGameKey, json.encode(gameToSave.toJson()));
    return gameToSave;
  }

  Future<void> clearCurrentGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentGameKey);
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

  // Three-player game methods

  Future<void> saveThreePlayerGame(
    List<ThreePlayerRound> rounds, {
    required String playerOneName,
    required String playerTwoName,
    required String playerThreeName,
    int goalScore = 1001,
    DateTime? createdAt,
    bool isCanceled = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final game = ThreePlayerGame(
      playerOneName: playerOneName,
      playerTwoName: playerTwoName,
      playerThreeName: playerThreeName,
      rounds: rounds,
      createdAt: createdAt ?? DateTime.now(),
      goalScore: goalScore,
      isCanceled: isCanceled,
    );
    final gameJson = json.encode(game.toJson());
    final key = 'saved_three_player_game_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(key, gameJson);
    await prefs.setString('latest_three_player_game_key', key);
    print('Three-player game saved under key: $key');

    if (!isCanceled) {
      await ReviewService.incrementCompletedGames();
    }
  }

  Future<List<ThreePlayerGame>> loadThreePlayerGames() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('saved_three_player_game_')).toList();
    List<ThreePlayerGame> games = [];
    for (final key in keys) {
      final String? gameJson = prefs.getString(key);
      if (gameJson != null) {
        try {
          final Map<String, dynamic> gameData = json.decode(gameJson);
          final game = ThreePlayerGame.fromJson(gameData);
          games.add(game);
        } catch (e) {
          print('Error decoding three-player game for key $key: $e');
        }
      }
    }
    games.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return games;
  }

  Future<bool> deleteLatestThreePlayerGame() async {
    final prefs = await SharedPreferences.getInstance();
    final latestKey = prefs.getString('latest_three_player_game_key');

    if (latestKey != null) {
      final result = await prefs.remove(latestKey);
      if (result) {
        print('Deleted latest three-player game with key: $latestKey');
        await prefs.remove('latest_three_player_game_key');
        return true;
      }
    }
    return false;
  }

  Future<bool> deleteThreePlayerGame(ThreePlayerGame gameToDelete) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('saved_three_player_game_')).toList();

    for (final key in keys) {
      final String? gameJson = prefs.getString(key);
      if (gameJson != null) {
        try {
          final Map<String, dynamic> gameData = json.decode(gameJson);
          if (gameData['id'] == gameToDelete.id) {
            await prefs.remove(key);
            print('Deleted three-player game with key: $key');
            return true;
          }
        } catch (e) {
          print('Error checking three-player game for deletion: $e');
        }
      }
    }
    return false;
  }

  Future<ThreePlayerGame?> loadCurrentThreePlayerGame() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_currentThreePlayerGameKey);
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> gameData = json.decode(jsonString);
      return ThreePlayerGame.fromJson(gameData);
    } catch (e) {
      print('Error decoding current three-player game: $e');
      return null;
    }
  }

  Future<ThreePlayerGame> saveCurrentThreePlayerGame(ThreePlayerGame game) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentThreePlayerGameKey, json.encode(game.toJson()));
    return game;
  }

  Future<void> clearCurrentThreePlayerGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentThreePlayerGameKey);
  }
}
