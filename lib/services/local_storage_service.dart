import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game.dart';
import '../models/round.dart';

class LocalStorageService {
  Future<void> saveGame(
    List<Round> rounds, {
    String teamOneName = 'Mi',
    String teamTwoName = 'Vi',
    int goalScore = 1001,
  }) async {
    final game = Game(
      teamOneName: teamOneName,
      teamTwoName: teamTwoName,
      rounds: rounds,
      createdAt: DateTime.now(),
      goalScore: goalScore,
    );
    final gameJson = json.encode(game.toJson());
    final prefs = await SharedPreferences.getInstance();
    final key = 'saved_game_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(key, gameJson);
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
}
