import 'package:bela_blok/models/game.dart';
import 'package:bela_blok/models/three_player_game.dart';
import 'package:bela_blok/providers/settings_provider.dart';
import 'package:bela_blok/screens/finished_game_screen.dart';
import 'package:bela_blok/screens/global_statistics_screen.dart';
import 'package:bela_blok/screens/three_player_finished_game_screen.dart';
import 'package:bela_blok/services/local_storage_service.dart';
import 'package:bela_blok/services/score_calculator.dart';
import 'package:bela_blok/widgets/finished_game_display.dart';
import 'package:bela_blok/widgets/three_player_finished_game_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../utils/app_localizations.dart';

// Union type to represent either game type
class HistoryGameItem {
  final Game? twoPlayerGame;
  final ThreePlayerGame? threePlayerGame;
  final DateTime createdAt;
  final bool isCanceled;
  final int goalScore;

  HistoryGameItem.twoPlayer(Game game)
    : twoPlayerGame = game,
      threePlayerGame = null,
      createdAt = game.createdAt,
      isCanceled = game.isCanceled,
      goalScore = game.goalScore;

  HistoryGameItem.threePlayer(ThreePlayerGame game)
    : twoPlayerGame = null,
      threePlayerGame = game,
      createdAt = game.createdAt,
      isCanceled = game.isCanceled,
      goalScore = game.goalScore;

  bool get isThreePlayer => threePlayerGame != null;
}

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState createState() => HistoryScreenState();
}

class HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Future<List<HistoryGameItem>> _gamesFuture;
  final LocalStorageService _localStorageService = LocalStorageService();

  // Filter states
  bool _showFinished = true;
  bool _showUnfinished = true;
  bool _showTwoPlayer = true;
  bool _showThreePlayer = true;
  Set<int> _selectedGoalScores = {501, 701, 1001};

  @override
  void initState() {
    super.initState();
    _gamesFuture = _loadAllGames();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshGames();
    }
  }

  Future<List<HistoryGameItem>> _loadAllGames() async {
    final twoPlayerGames = await _localStorageService.loadGames();
    final threePlayerGames = await _localStorageService.loadThreePlayerGames();

    final List<HistoryGameItem> allGames = [
      ...twoPlayerGames.map((g) => HistoryGameItem.twoPlayer(g)),
      ...threePlayerGames.map((g) => HistoryGameItem.threePlayer(g)),
    ];

    // Sort by date, newest first
    allGames.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allGames;
  }

  void _refreshGames() {
    setState(() {
      _gamesFuture = _loadAllGames();
    });
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final loc = AppLocalizations.of(context)!;

            return AlertDialog(
              actionsAlignment: MainAxisAlignment.spaceBetween,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.translate('gameStatus'),
                      style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    CheckboxListTile(
                      title: Text(loc.translate('finished'), style: const TextStyle(fontFamily: 'Nunito')),
                      value: _showFinished,
                      onChanged: (value) {
                        setState(() {
                          _showFinished = value ?? false;
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: Text(loc.translate('unfinished'), style: const TextStyle(fontFamily: 'Nunito')),
                      value: _showUnfinished,
                      onChanged: (value) {
                        setState(() {
                          _showUnfinished = value ?? false;
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    Divider(color: Colors.grey.withOpacity(0.8)),
                    Text(
                      loc.translate('gameType'),
                      style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    CheckboxListTile(
                      title: Text(loc.translate('twoPlayers'), style: const TextStyle(fontFamily: 'Nunito')),
                      value: _showTwoPlayer,
                      onChanged: (value) {
                        setState(() {
                          _showTwoPlayer = value ?? false;
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: Text(
                        loc.translate('threePlayers'),
                        style: const TextStyle(fontFamily: 'Nunito'),
                      ),
                      value: _showThreePlayer,
                      onChanged: (value) {
                        setState(() {
                          _showThreePlayer = value ?? false;
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    Divider(color: Colors.grey.withOpacity(0.8)),
                    Text(
                      loc.translate('gameGoal'),
                      style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    ...[501, 701, 1001].map((score) {
                      return CheckboxListTile(
                        title: Text('$score', style: const TextStyle(fontFamily: 'Nunito')),
                        value: _selectedGoalScores.contains(score),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedGoalScores.add(score);
                            } else {
                              _selectedGoalScores.remove(score);
                            }
                          });
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    this.setState(() {}); // Update the main screen
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    loc.translate('apply'),
                    style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showFinished = true;
                      _showUnfinished = true;
                      _showTwoPlayer = true;
                      _showThreePlayer = true;
                      _selectedGoalScores = {501, 701, 1001};
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    loc.translate('reset'),
                    style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<HistoryGameItem> _filterGames(List<HistoryGameItem> games) {
    return games.where((game) {
      // Filter by status
      if (game.isCanceled && !_showUnfinished) return false;
      if (!game.isCanceled && !_showFinished) return false;

      // Filter by type
      if (game.isThreePlayer && !_showThreePlayer) return false;
      if (!game.isThreePlayer && !_showTwoPlayer) return false;

      // Filter by goal score
      if (!_selectedGoalScores.contains(game.goalScore)) return false;

      return true;
    }).toList();
  }

  Widget _buildGameList(List<HistoryGameItem> games, AppLocalizations loc, int stigljaValue) {
    final filteredGames = _filterGames(games);

    if (filteredGames.isEmpty) {
      return Center(
        child: Text(
          loc.translate('noSavedGames'),
          style: const TextStyle(fontFamily: 'Nunito', fontSize: 24, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredGames.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = filteredGames[index];

        if (item.isThreePlayer) {
          return _buildThreePlayerGameCard(item.threePlayerGame!, loc, stigljaValue);
        } else {
          return _buildTwoPlayerGameCard(item.twoPlayerGame!, loc, stigljaValue);
        }
      },
    );
  }

  Widget _buildTwoPlayerGameCard(Game game, AppLocalizations loc, int stigljaValue) {
    final int teamOneTotal = ScoreCalculator(stigljaValue: stigljaValue).computeTeamOneTotal(game.rounds);
    final int teamTwoTotal = ScoreCalculator(stigljaValue: stigljaValue).computeTeamTwoTotal(game.rounds);

    String winningTeam = '';
    if (!game.isCanceled) {
      if (teamOneTotal > teamTwoTotal) {
        winningTeam = game.teamOneName;
      } else if (teamTwoTotal > teamOneTotal) {
        winningTeam = game.teamTwoName;
      } else if (teamOneTotal == teamTwoTotal && teamOneTotal > 0) {
        winningTeam = 'Remi';
      }
    }

    return FinishedGameDisplay(
      onTap: () async {
        final result = await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => FinishedGameScreen(game: game)));

        if (result == true) {
          _refreshGames();
        }
      },
      teamOneName: game.teamOneName,
      teamOneTotal: teamOneTotal,
      teamTwoTotal: teamTwoTotal,
      teamTwoName: game.teamTwoName,
      gameDate: game.createdAt,
      winningTeam: winningTeam.isNotEmpty ? winningTeam : null,
    );
  }

  Widget _buildThreePlayerGameCard(ThreePlayerGame game, AppLocalizations loc, int stigljaValue) {
    final int p1Total = game.getPlayerOneTotalScore(stigljaValue: stigljaValue);
    final int p2Total = game.getPlayerTwoTotalScore(stigljaValue: stigljaValue);
    final int p3Total = game.getPlayerThreeTotalScore(stigljaValue: stigljaValue);

    String winningPlayer = '';
    if (!game.isCanceled) {
      winningPlayer = game.getWinningPlayer(stigljaValue: stigljaValue);
    }

    return ThreePlayerFinishedGameDisplay(
      onTap: () async {
        final result = await Navigator.of(
          context,
        ).push<bool>(MaterialPageRoute(builder: (context) => ThreePlayerFinishedGameScreen(game: game)));
        if (result == true) {
          _refreshGames();
        }
      },
      playerOneName: game.playerOneName,
      playerTwoName: game.playerTwoName,
      playerThreeName: game.playerThreeName,
      playerOneTotal: p1Total,
      playerTwoTotal: p2Total,
      playerThreeTotal: p3Total,
      gameDate: game.createdAt,
      winningPlayer: winningPlayer.isNotEmpty ? winningPlayer : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final int stigljaValue = settings.stigljaValue;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: theme.colorScheme.surface,
        title: Text(
          loc.translate('historyTitle'),
          style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
        ),
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01, size: 30),
        ),
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(context),
            icon: const Icon(HugeIcons.strokeRoundedFilter),
          ),
          IconButton(
            onPressed: () async {
              final games = await _gamesFuture;
              final twoPlayerGames =
                  games.where((g) => !g.isThreePlayer).map((g) => g.twoPlayerGame!).toList();
              final threePlayerGames =
                  games.where((g) => g.isThreePlayer).map((g) => g.threePlayerGame!).toList();
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            GlobalStatisticsScreen(games: twoPlayerGames, threePlayerGames: threePlayerGames),
                  ),
                );
              }
            },
            icon: const Icon(HugeIcons.strokeRoundedAnalytics01),
          ),
        ],
      ),
      body: FutureBuilder<List<HistoryGameItem>>(
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
          final List<HistoryGameItem> games = snapshot.data ?? [];
          return _buildGameList(games, loc, stigljaValue);
        },
      ),
    );
  }
}
