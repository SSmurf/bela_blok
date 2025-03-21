import 'dart:convert';
import 'package:bela_blok/models/game.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/finished_game_display.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Game>> _gamesFuture;

  @override
  void initState() {
    super.initState();
    _gamesFuture = _loadGames();
  }

  Future<List<Game>> _loadGames() async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve all keys that start with "saved_game_"
    final keys = prefs.getKeys().where((key) => key.startsWith('saved_game_')).toList();
    List<Game> games = [];

    for (String key in keys) {
      final String? gameJson = prefs.getString(key);
      if (gameJson != null) {
        try {
          // Decode JSON and instantiate a Game model.
          final Map<String, dynamic> gameData = json.decode(gameJson);
          final game = Game.fromJson(gameData);
          games.add(game);
        } catch (e) {
          // Optionally handle or log the error if JSON decoding fails.
        }
      }
    }

    // Sort games by creation date (newest first)
    games.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return games;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Povijest igara')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FutureBuilder<List<Game>>(
          future: _gamesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Došlo je do greške pri učitavanju igara.'));
            }
            final List<Game> games = snapshot.data ?? [];
            if (games.isEmpty) {
              return const Center(child: Text('Nema spremljenih igara.'));
            }
            return ListView.separated(
              itemCount: games.length,
              separatorBuilder:
                  (context, index) => Row(
                    children: [
                      Expanded(child: const Divider(height: 1, thickness: 1)),
                      Icon(HugeIcons.strokeRoundedRecord, size: 16),
                      Expanded(child: const Divider(height: 1, thickness: 1)),
                    ],
                  ),
              itemBuilder: (context, index) {
                final game = games[index];
                return FinishedGameDisplay(
                  teamOneName: game.teamOneName,
                  teamOneTotal: game.teamOneTotalScore,
                  teamTwoTotal: game.teamTwoTotalScore,
                  teamTwoName: game.teamTwoName,
                  gameDate: game.createdAt,
                  winningTeam: game.winningTeam.isNotEmpty ? game.winningTeam : null,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
