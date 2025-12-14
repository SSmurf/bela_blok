import 'package:bela_blok/models/game.dart';
import 'package:bela_blok/utils/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class GlobalStatisticsScreen extends StatelessWidget {
  final List<Game> games;

  const GlobalStatisticsScreen({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (games.isEmpty) {
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

    // Calculations
    int totalGames = games.length;
    int totalTeamOneScore = 0;
    int totalTeamTwoScore = 0;
    int totalScoreNoDecl = 0;
    int totalDeclValue = 0;
    int totalStigljaCount = 0;

    int totalDecl20 = 0;
    int totalDecl50 = 0;
    int totalDecl100 = 0;
    int totalDecl150 = 0;
    int totalDecl200 = 0;
    int totalDeclStiglja = 0;

    for (var game in games) {
      // Use game getters for total score including decls
      totalTeamOneScore += game.teamOneTotalScore;
      totalTeamTwoScore += game.teamTwoTotalScore;

      for (var round in game.rounds) {
        // Points without declarations
        totalScoreNoDecl += round.scoreTeamOne + round.scoreTeamTwo;

        // Declarations value
        int roundDeclValue =
            round.decl20TeamOne * 20 +
            round.decl50TeamOne * 50 +
            round.decl100TeamOne * 100 +
            round.decl150TeamOne * 150 +
            round.decl200TeamOne * 200 +
            round.declStigljaTeamOne * 90 +
            round.decl20TeamTwo * 20 +
            round.decl50TeamTwo * 50 +
            round.decl100TeamTwo * 100 +
            round.decl150TeamTwo * 150 +
            round.decl200TeamTwo * 200 +
            round.declStigljaTeamTwo * 90;
        
        totalDeclValue += roundDeclValue;

        // Stiglja count
        totalStigljaCount += round.declStigljaTeamOne + round.declStigljaTeamTwo;

        // Total declarations counts
        totalDecl20 += round.decl20TeamOne + round.decl20TeamTwo;
        totalDecl50 += round.decl50TeamOne + round.decl50TeamTwo;
        totalDecl100 += round.decl100TeamOne + round.decl100TeamTwo;
        totalDecl150 += round.decl150TeamOne + round.decl150TeamTwo;
        totalDecl200 += round.decl200TeamOne + round.decl200TeamTwo;
        totalDeclStiglja += round.declStigljaTeamOne + round.declStigljaTeamTwo;
      }
    }

    double avgTeamPoints = (totalTeamOneScore + totalTeamTwoScore) / (2 * totalGames);
    double avgTotalPoints = (totalTeamOneScore + totalTeamTwoScore) / totalGames;
    double avgPointsNoDecl = totalScoreNoDecl / totalGames;
    double avgDeclValue = totalDeclValue / totalGames;
    double avgStiglja = totalStigljaCount / totalGames;
    double declPercentage =
        (totalTeamOneScore + totalTeamTwoScore) > 0
            ? (totalDeclValue / (totalTeamOneScore + totalTeamTwoScore)) * 100
            : 0;

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
          _StatCard(
            title: loc.translate('gamesPlayed'),
            value: totalGames.toString(),
            theme: theme,
          ),
          const SizedBox(height: 12),
          _StatCard(
            title: loc.translate('avgTeamPoints'),
            value: avgTeamPoints.toStringAsFixed(1),
            theme: theme,
          ),
          const SizedBox(height: 12),
          _StatCard(
            title: loc.translate('avgTotalPoints'),
            value: avgTotalPoints.toStringAsFixed(1),
            theme: theme,
          ),
          const SizedBox(height: 12),
          _StatCard(
            title: loc.translate('avgPointsNoDecl'),
            value: avgPointsNoDecl.toStringAsFixed(1),
            theme: theme,
          ),
          const SizedBox(height: 12),
          _StatCard(
            title: loc.translate('avgDeclValue'),
            value: avgDeclValue.toStringAsFixed(1),
            theme: theme,
          ),
          const SizedBox(height: 12),
          _StatCard(
            title: loc.translate('avgStiglja'),
            value: avgStiglja.toStringAsFixed(2),
            theme: theme,
          ),
          const SizedBox(height: 12),
          _StatCard(
            title: loc.translate('declPercentage'),
            value: '${declPercentage.toStringAsFixed(1)}%',
            theme: theme,
          ),
          const SizedBox(height: 32),
          Text(
            loc.translate('totalDeclarations'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
            ),
            child: Table(
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                _buildDeclRow('20', totalDecl20, theme),
                _buildDeclRow('50', totalDecl50, theme),
                _buildDeclRow('100', totalDecl100, theme),
                _buildDeclRow('150', totalDecl150, theme),
                _buildDeclRow('200', totalDecl200, theme),
                _buildDeclRow(loc.translate('allTricks'), totalDeclStiglja, theme, isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  TableRow _buildDeclRow(String label, int value, ThemeData theme, {bool isLast = false}) {
    return TableRow(
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))),
      ),
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12, bottom: isLast ? 0 : 12),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Nunito')),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12, bottom: isLast ? 0 : 12),
          child: Text(
            value.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: value > 0 ? FontWeight.bold : FontWeight.normal,
              color: value > 0 ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.5),
              fontFamily: 'Nunito',
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final ThemeData theme;

  const _StatCard({required this.title, required this.value, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

