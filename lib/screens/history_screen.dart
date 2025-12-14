import 'package:bela_blok/models/game.dart';
import 'package:bela_blok/providers/settings_provider.dart';
import 'package:bela_blok/screens/finished_game_screen.dart';
import 'package:bela_blok/screens/global_statistics_screen.dart';
import 'package:bela_blok/services/local_storage_service.dart';
import 'package:bela_blok/services/score_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../widgets/finished_game_display.dart';
import '../utils/app_localizations.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState createState() => HistoryScreenState();
}

class HistoryScreenState extends ConsumerState<HistoryScreen> {
  late Future<List<Game>> _gamesFuture;
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _gamesFuture = _localStorageService.loadGames();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final int stigljaValue = settings.stigljaValue;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        title: Text(
          loc.translate('historyTitle'),
          style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
        ),
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: Icon(HugeIcons.strokeRoundedArrowLeft01, size: 30),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final games = await _gamesFuture;
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GlobalStatisticsScreen(games: games),
                  ),
                );
              }
            },
            icon: const Icon(HugeIcons.strokeRoundedAnalytics01),
          ),
        ],
      ),
      body: FutureBuilder<List<Game>>(
        future: _gamesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                loc.translate('historyError'),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }
          final List<Game> games = snapshot.data ?? [];
          if (games.isEmpty) {
            return Center(
              child: Text(
                loc.translate('noSavedGames'),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: games.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final game = games[index];

              final int teamOneTotal = ScoreCalculator(
                stigljaValue: stigljaValue,
              ).computeTeamOneTotal(game.rounds);
              final int teamTwoTotal = ScoreCalculator(
                stigljaValue: stigljaValue,
              ).computeTeamTwoTotal(game.rounds);

              String winningTeam = '';
              if (teamOneTotal > teamTwoTotal) {
                winningTeam = game.teamOneName;
              } else if (teamTwoTotal > teamOneTotal) {
                winningTeam = game.teamTwoName;
              } else if (teamOneTotal == teamTwoTotal && teamOneTotal > 0) {
                winningTeam = 'Remi';
              }

              return FinishedGameDisplay(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FinishedGameScreen(game: game),
                    ),
                  );
                },
                teamOneName: game.teamOneName,
                teamOneTotal: teamOneTotal,
                teamTwoTotal: teamTwoTotal,
                teamTwoName: game.teamTwoName,
                gameDate: game.createdAt,
                winningTeam: winningTeam.isNotEmpty ? winningTeam : null,
              );
            },
          );
        },
      ),
    );
  }
}

