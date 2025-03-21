import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/finished_game_display.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> _gamesFuture;

  @override
  void initState() {
    super.initState();
    _gamesFuture = _loadGames();
  }

  Future<List<Map<String, dynamic>>> _loadGames() async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve all keys that start with "saved_game_"
    final keys = prefs.getKeys().where((key) => key.startsWith('saved_game_')).toList();
    List<Map<String, dynamic>> games = [];

    for (String key in keys) {
      final String? gameJson = prefs.getString(key);
      if (gameJson != null) {
        try {
          final Map<String, dynamic> gameData = json.decode(gameJson);
          games.add(gameData);
        } catch (e) {
          // Optionally handle or log the error if JSON decoding fails.
        }
      }
    }

    // Sort games by creation date (newest first)
    games.sort((a, b) {
      final DateTime dateA = DateTime.parse(a['createdAt'] as String);
      final DateTime dateB = DateTime.parse(b['createdAt'] as String);
      return dateB.compareTo(dateA);
    });

    return games;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Povijest igara')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _gamesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Došlo je do greške pri učitavanju igara.'));
          }
          final List<Map<String, dynamic>> games = snapshot.data ?? [];
          if (games.isEmpty) {
            return const Center(child: Text('Nema spremljenih igara.'));
          }
          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final gameData = games[index];
              final String teamOneName = (gameData['teamOneName'] as String?) ?? 'Team One';
              final String teamTwoName = (gameData['teamTwoName'] as String?) ?? 'Team Two';
              final int teamOneTotal = (gameData['teamOneTotal'] as int?) ?? 0;
              final int teamTwoTotal = (gameData['teamTwoTotal'] as int?) ?? 0;

              DateTime? gameDate;
              if (gameData['createdAt'] != null) {
                gameDate = DateTime.tryParse(gameData['createdAt'] as String);
              }
              
              return FinishedGameDisplay(
                teamOneName: teamOneName,
                teamOneTotal: teamOneTotal,
                teamTwoTotal: teamTwoTotal,
                teamTwoName: teamTwoName,
                gameDate: gameDate,
              );
            },
          );
        },
      ),
    );
  }
}
