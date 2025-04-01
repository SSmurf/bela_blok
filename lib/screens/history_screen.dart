import 'package:bela_blok/models/game.dart';
import 'package:bela_blok/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../widgets/finished_game_display.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Game>> _gamesFuture;
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _gamesFuture = _localStorageService.loadGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Povijest igara',
          style: TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
        ),
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: Icon(HugeIcons.strokeRoundedArrowLeft01, size: 30),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FutureBuilder<List<Game>>(
          future: _gamesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Došlo je do greške pri učitavanju igara.',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 24, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              );
            }
            final List<Game> games = snapshot.data ?? [];
            if (games.isEmpty) {
              return const Center(
                child: Text(
                  'Nema spremljenih igara.',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 24, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              );
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
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: FinishedGameDisplay(
                    teamOneName: game.teamOneName,
                    teamOneTotal: game.teamOneTotalScore,
                    teamTwoTotal: game.teamTwoTotalScore,
                    teamTwoName: game.teamTwoName,
                    gameDate: game.createdAt,
                    winningTeam: game.winningTeam.isNotEmpty ? game.winningTeam : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
