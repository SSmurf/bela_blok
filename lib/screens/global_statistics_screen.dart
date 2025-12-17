import 'package:bela_blok/models/game.dart';
import 'package:bela_blok/models/three_player_game.dart';
import 'package:bela_blok/utils/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class GlobalStatisticsScreen extends StatelessWidget {
  final List<Game> games;
  final List<ThreePlayerGame> threePlayerGames;

  const GlobalStatisticsScreen({super.key, required this.games, this.threePlayerGames = const []});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final completedGames = games.where((game) => !game.isCanceled).toList();
    final finishedGames = completedGames.where((game) => game.isFinished).toList();
    final unfinishedGames = games.where((game) => game.isCanceled || !game.isFinished).toList();

    final hasAnyGames = games.isNotEmpty || threePlayerGames.isNotEmpty;

    if (!hasAnyGames) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            loc.translate('globalStatisticsTitle'),
            style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
          ),
          leading: IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(HugeIcons.strokeRoundedArrowLeft01, size: 30),
          ),
        ),
        body: Center(
          child: Text(
            loc.translate('noSavedGames'),
            style: const TextStyle(fontFamily: 'Nunito', fontSize: 18),
          ),
        ),
      );
    }

    // Three-player game stats
    final completedThreePlayerGames = threePlayerGames.where((g) => !g.isCanceled).toList();
    int threePlayerFinishedCount = completedThreePlayerGames.where((g) => g.isFinished()).length;
    int threePlayerUnfinishedCount = threePlayerGames.length - threePlayerFinishedCount;

    // Three-player declaration counters
    int threePlayerDecl20 = 0;
    int threePlayerDecl50 = 0;
    int threePlayerDecl100 = 0;
    int threePlayerDecl150 = 0;
    int threePlayerDecl200 = 0;
    int threePlayerDeclStiglja = 0;

    for (var game in completedThreePlayerGames) {
      for (var round in game.rounds) {
        threePlayerDecl20 += round.decl20PlayerOne + round.decl20PlayerTwo + round.decl20PlayerThree;
        threePlayerDecl50 += round.decl50PlayerOne + round.decl50PlayerTwo + round.decl50PlayerThree;
        threePlayerDecl100 += round.decl100PlayerOne + round.decl100PlayerTwo + round.decl100PlayerThree;
        threePlayerDecl150 += round.decl150PlayerOne + round.decl150PlayerTwo + round.decl150PlayerThree;
        threePlayerDecl200 += round.decl200PlayerOne + round.decl200PlayerTwo + round.decl200PlayerThree;
        threePlayerDeclStiglja +=
            round.declStigljaPlayerOne + round.declStigljaPlayerTwo + round.declStigljaPlayerThree;
      }
    }

    // Accumulators
    final _StatsAccumulator winnerStats = _StatsAccumulator();
    final _StatsAccumulator loserStats = _StatsAccumulator();
    final _StatsAccumulator combinedStats = _StatsAccumulator();

    // Global declaration counters
    int totalDecl20 = 0;
    int totalDecl50 = 0;
    int totalDecl100 = 0;
    int totalDecl150 = 0;
    int totalDecl200 = 0;
    int totalDeclStiglja = 0;

    for (var game in completedGames) {
      int gameTeamOneScore = game.teamOneTotalScore;
      int gameTeamTwoScore = game.teamTwoTotalScore;

      // Per-team accumulation for this game
      int teamOneNoDecl = 0;
      int teamOneDeclVal = 0;
      int teamOneStiglja = 0;

      int teamTwoNoDecl = 0;
      int teamTwoDeclVal = 0;
      int teamTwoStiglja = 0;

      for (var round in game.rounds) {
        // Points without declarations
        teamOneNoDecl += round.scoreTeamOne;
        teamTwoNoDecl += round.scoreTeamTwo;

        // Declarations value Team 1
        // Note: scoreTeamOne already excludes declarations.
        // We need to sum up declarations carefully.
        // Logic from Game.dart used fold on rounds.
        // Here we do it manually or helper.

        int rDecl1 =
            round.decl20TeamOne * 20 +
            round.decl50TeamOne * 50 +
            round.decl100TeamOne * 100 +
            round.decl150TeamOne * 150 +
            round.decl200TeamOne * 200 +
            round.declStigljaTeamOne * 90;
        teamOneDeclVal += rDecl1;
        teamOneStiglja += round.declStigljaTeamOne;

        int rDecl2 =
            round.decl20TeamTwo * 20 +
            round.decl50TeamTwo * 50 +
            round.decl100TeamTwo * 100 +
            round.decl150TeamTwo * 150 +
            round.decl200TeamTwo * 200 +
            round.declStigljaTeamTwo * 90;
        teamTwoDeclVal += rDecl2;
        teamTwoStiglja += round.declStigljaTeamTwo;

        // Global Decl Counts
        totalDecl20 += round.decl20TeamOne + round.decl20TeamTwo;
        totalDecl50 += round.decl50TeamOne + round.decl50TeamTwo;
        totalDecl100 += round.decl100TeamOne + round.decl100TeamTwo;
        totalDecl150 += round.decl150TeamOne + round.decl150TeamTwo;
        totalDecl200 += round.decl200TeamOne + round.decl200TeamTwo;
        totalDeclStiglja += round.declStigljaTeamOne + round.declStigljaTeamTwo;
      }

      // Identify Winner/Loser
      if (gameTeamOneScore > gameTeamTwoScore) {
        winnerStats.add(gameTeamOneScore, teamOneNoDecl, teamOneDeclVal, teamOneStiglja);
        loserStats.add(gameTeamTwoScore, teamTwoNoDecl, teamTwoDeclVal, teamTwoStiglja);
      } else if (gameTeamTwoScore > gameTeamOneScore) {
        winnerStats.add(gameTeamTwoScore, teamTwoNoDecl, teamTwoDeclVal, teamTwoStiglja);
        loserStats.add(gameTeamOneScore, teamOneNoDecl, teamOneDeclVal, teamOneStiglja);
      } else {
        // Draw - maybe add both to combined but neither to winner/loser?
        // Or skip for winner/loser.
        // Let's skip winner/loser stats for draws to avoid skewing "Winning Team" stats with draws.
      }

      // Combined (Game Totals)
      combinedStats.add(
        gameTeamOneScore + gameTeamTwoScore,
        teamOneNoDecl + teamTwoNoDecl,
        teamOneDeclVal + teamTwoDeclVal,
        teamOneStiglja + teamTwoStiglja,
      );
    }

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: theme.colorScheme.surface,
        title: Text(
          loc.translate('globalStatisticsTitle'),
          style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
        ),
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(HugeIcons.strokeRoundedArrowLeft01, size: 30),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(
            title: loc.translate('numberOfGames'),
            theme: theme,
            color: theme.colorScheme.primary,
          ),
          _GamesCountSection(
            finishedCount: finishedGames.length,
            unfinishedCount: unfinishedGames.length,
            loc: loc,
            theme: theme,
          ),

          const SizedBox(height: 24),

          _SectionHeader(
            title: loc.translate('winningTeamStats'),
            theme: theme,
            color: theme.colorScheme.primary,
          ),
          _StatisticsSection(stats: winnerStats, loc: loc, theme: theme),

          const SizedBox(height: 24),

          _SectionHeader(
            title: loc.translate('losingTeamStats'),
            theme: theme,
            color: theme.colorScheme.error,
          ),
          _StatisticsSection(stats: loserStats, loc: loc, theme: theme),

          const SizedBox(height: 24),

          _SectionHeader(
            title: loc.translate('combinedStats'),
            theme: theme,
            color: theme.colorScheme.secondary,
          ),
          _StatisticsSection(stats: combinedStats, loc: loc, theme: theme),

          const SizedBox(height: 32),
          _SectionHeader(
            title: loc.translate('totalDeclarations'),
            theme: theme,
            color: theme.colorScheme.tertiary,
          ),
          _DeclarationsSection(
            totalDecl20: totalDecl20,
            totalDecl50: totalDecl50,
            totalDecl100: totalDecl100,
            totalDecl150: totalDecl150,
            totalDecl200: totalDecl200,
            totalDeclStiglja: totalDeclStiglja,
            loc: loc,
            theme: theme,
          ),

          // Three-player games section
          if (threePlayerGames.isNotEmpty) ...[
            const SizedBox(height: 32),
            _SectionHeader(
              title: loc.translate('threePlayerGames'),
              theme: theme,
              color: theme.colorScheme.tertiary,
            ),
            _GamesCountSection(
              finishedCount: threePlayerFinishedCount,
              unfinishedCount: threePlayerUnfinishedCount,
              loc: loc,
              theme: theme,
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: loc.translate('threePlayerDeclarations'),
              theme: theme,
              color: theme.colorScheme.tertiary,
            ),
            _DeclarationsSection(
              totalDecl20: threePlayerDecl20,
              totalDecl50: threePlayerDecl50,
              totalDecl100: threePlayerDecl100,
              totalDecl150: threePlayerDecl150,
              totalDecl200: threePlayerDecl200,
              totalDeclStiglja: threePlayerDeclStiglja,
              loc: loc,
              theme: theme,
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _DeclarationsSection extends StatelessWidget {
  final int totalDecl20;
  final int totalDecl50;
  final int totalDecl100;
  final int totalDecl150;
  final int totalDecl200;
  final int totalDeclStiglja;
  final AppLocalizations loc;
  final ThemeData theme;

  const _DeclarationsSection({
    required this.totalDecl20,
    required this.totalDecl50,
    required this.totalDecl100,
    required this.totalDecl150,
    required this.totalDecl200,
    required this.totalDeclStiglja,
    required this.loc,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          _buildDeclRow('20', totalDecl20, theme, isFirst: true),
          _buildDeclRow('50', totalDecl50, theme),
          _buildDeclRow('100', totalDecl100, theme),
          _buildDeclRow('150', totalDecl150, theme),
          _buildDeclRow('200', totalDecl200, theme),
          _buildDeclRow(loc.translate('allTricks'), totalDeclStiglja, theme, isLast: true),
        ],
      ),
    );
  }

  TableRow _buildDeclRow(
    String label,
    int value,
    ThemeData theme, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))),
      ),
      children: [
        Padding(
          padding: EdgeInsets.only(top: isFirst ? 0 : 12, bottom: isLast ? 0 : 12),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Nunito')),
        ),
        Padding(
          padding: EdgeInsets.only(top: isFirst ? 0 : 12, bottom: isLast ? 0 : 12),
          child: Text(
            value.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
          ),
        ),
      ],
    );
  }
}

class _StatsAccumulator {
  int count = 0;
  int totalScore = 0;
  int totalScoreNoDecl = 0;
  int totalDeclValue = 0;
  int totalStiglja = 0;

  void add(int score, int scoreNoDecl, int declValue, int stiglja) {
    count++;
    totalScore += score;
    totalScoreNoDecl += scoreNoDecl;
    totalDeclValue += declValue;
    totalStiglja += stiglja;
  }

  double get avgTotalScore => count > 0 ? totalScore / count : 0;
  double get avgScoreNoDecl => count > 0 ? totalScoreNoDecl / count : 0;
  double get avgDeclValue => count > 0 ? totalDeclValue / count : 0;
  double get avgStiglja => count > 0 ? totalStiglja / count : 0;
  double get declPercentage => totalScore > 0 ? (totalDeclValue / totalScore) * 100 : 0;
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;
  final Color color;

  const _SectionHeader({required this.title, required this.theme, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8, left: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Nunito',
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _StatisticsSection extends StatelessWidget {
  final _StatsAccumulator stats;
  final AppLocalizations loc;
  final ThemeData theme;

  const _StatisticsSection({required this.stats, required this.loc, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(1)},
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          _buildStatRow(
            loc.translate('avgTotalPoints'),
            stats.avgTotalScore.toStringAsFixed(1),
            theme,
            isFirst: true,
          ),
          _buildStatRow(loc.translate('avgPointsNoDecl'), stats.avgScoreNoDecl.toStringAsFixed(1), theme),
          _buildStatRow(loc.translate('avgDeclValue'), stats.avgDeclValue.toStringAsFixed(1), theme),
          _buildStatRow(loc.translate('avgStiglja'), stats.avgStiglja.toStringAsFixed(2), theme),
          _buildStatRow(
            loc.translate('declPercentage'),
            '${stats.declPercentage.toStringAsFixed(1)}%',
            theme,
            isLast: true,
          ),
        ],
      ),
    );
  }

  TableRow _buildStatRow(
    String label,
    String value,
    ThemeData theme, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))),
      ),
      children: [
        Padding(
          padding: EdgeInsets.only(top: isFirst ? 0 : 12, bottom: isLast ? 0 : 12),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Nunito')),
        ),
        Padding(
          padding: EdgeInsets.only(top: isFirst ? 0 : 12, bottom: isLast ? 0 : 12),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
          ),
        ),
      ],
    );
  }
}

class _GamesCountSection extends StatelessWidget {
  final int finishedCount;
  final int unfinishedCount;
  final AppLocalizations loc;
  final ThemeData theme;

  const _GamesCountSection({
    required this.finishedCount,
    required this.unfinishedCount,
    required this.loc,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          _buildCountRow(loc.translate('finishedGames'), finishedCount, theme, isFirst: true),
          _buildCountRow(loc.translate('unfinishedGames'), unfinishedCount, theme, isLast: true),
        ],
      ),
    );
  }

  TableRow _buildCountRow(
    String label,
    int value,
    ThemeData theme, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))),
      ),
      children: [
        Padding(
          padding: EdgeInsets.only(top: isFirst ? 0 : 12, bottom: isLast ? 0 : 12),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Nunito')),
        ),
        Padding(
          padding: EdgeInsets.only(top: isFirst ? 0 : 12, bottom: isLast ? 0 : 12),
          child: Text(
            value.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
          ),
        ),
      ],
    );
  }
}
