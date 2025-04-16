import 'package:bela_blok/models/game.dart';
import 'package:bela_blok/providers/settings_provider.dart';
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth <= 375;

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
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 0.0 : 16.0),
        child: FutureBuilder<List<Game>>(
          future: _gamesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  loc.translate('historyError'),
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 24, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              );
            }
            final List<Game> games = snapshot.data ?? [];
            if (games.isEmpty) {
              return Center(
                child: Text(
                  loc.translate('noSavedGames'),
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 24, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ListView.separated(
              itemCount: games.length,
              separatorBuilder:
                  (context, index) => Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: const Divider(height: 1, thickness: 1),
                        ),
                      ),
                    ],
                  ),
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

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: FinishedGameDisplay(
                    teamOneName: game.teamOneName,
                    teamOneTotal: teamOneTotal,
                    teamTwoTotal: teamTwoTotal,
                    teamTwoName: game.teamTwoName,
                    gameDate: game.createdAt,
                    winningTeam: winningTeam.isNotEmpty ? winningTeam : null,
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
