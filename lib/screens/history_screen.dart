import 'package:bela_blok/models/game.dart';
import 'package:bela_blok/models/three_player_game.dart';
import 'package:bela_blok/providers/settings_provider.dart';
import 'package:bela_blok/screens/finished_game_screen.dart';
import 'package:bela_blok/screens/global_statistics_screen.dart';
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

  HistoryGameItem.twoPlayer(Game game)
      : twoPlayerGame = game,
        threePlayerGame = null,
        createdAt = game.createdAt,
        isCanceled = game.isCanceled;

  HistoryGameItem.threePlayer(ThreePlayerGame game)
      : twoPlayerGame = null,
        threePlayerGame = game,
        createdAt = game.createdAt,
        isCanceled = game.isCanceled;

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
  late TabController _tabController;
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _gamesFuture = _loadAllGames();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
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

  Widget _buildGameList(List<HistoryGameItem> games, AppLocalizations loc, int stigljaValue) {
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
      padding: const EdgeInsets.all(16),
      itemCount: games.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = games[index];

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
        final result = await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => FinishedGameScreen(game: game)),
        );

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
        // TODO: Navigate to ThreePlayerFinishedGameScreen
        // For now, just show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.translate('threePlayerGameDetails'))),
        );
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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth <= 375;

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
            onPressed: () async {
              final games = await _gamesFuture;
              final twoPlayerGames = games
                  .where((g) => !g.isThreePlayer)
                  .map((g) => g.twoPlayerGame!)
                  .toList();
              final threePlayerGames = games
                  .where((g) => g.isThreePlayer)
                  .map((g) => g.threePlayerGame!)
                  .toList();
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GlobalStatisticsScreen(
                      games: twoPlayerGames,
                      threePlayerGames: threePlayerGames,
                    ),
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
          final finishedGames = games.where((game) => !game.isCanceled).toList();
          final unfinishedGames = games.where((game) => game.isCanceled).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.colorScheme.primary,
                    ),
                    labelColor: theme.colorScheme.onPrimary,
                    labelStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    unselectedLabelColor: theme.colorScheme.onSurface,
                    tabs: [
                      Tab(text: loc.translate('finishedGamesTab')),
                      Tab(text: loc.translate('unfinishedGamesTab')),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGameList(finishedGames, loc, stigljaValue),
                    _buildGameList(unfinishedGames, loc, stigljaValue),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
