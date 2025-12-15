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

class HistoryScreenState extends ConsumerState<HistoryScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Future<List<Game>> _gamesFuture;
  late TabController _tabController;
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _gamesFuture = _localStorageService.loadGames();
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

  void _refreshGames() {
    setState(() {
      _gamesFuture = _localStorageService.loadGames();
    });
  }

  Widget _buildGameList(List<Game> games, AppLocalizations loc, int stigljaValue) {
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
        final game = games[index];

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
      },
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
          icon: Icon(HugeIcons.strokeRoundedArrowLeft01, size: 30),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final games = await _gamesFuture;
              if (context.mounted) {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => GlobalStatisticsScreen(games: games)));
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
                style: const TextStyle(fontFamily: 'Nunito', fontSize: 24, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            );
          }
          final List<Game> games = snapshot.data ?? [];
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
