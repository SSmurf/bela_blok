import 'dart:math';

import 'package:bela_blok/models/three_player_game.dart';
import 'package:bela_blok/models/three_player_round.dart';
import 'package:bela_blok/providers/settings_provider.dart';
import 'package:bela_blok/services/local_storage_service.dart';
import 'package:bela_blok/utils/app_localizations.dart';
import 'package:bela_blok/utils/player_name_utils.dart';
import 'package:bela_blok/utils/three_player_score_utils.dart';
import 'package:bela_blok/widgets/three_player_round_display.dart';
import 'package:bela_blok/widgets/three_player_total_score_display.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

int _calculateTotalPoints(List<ThreePlayerRound> rounds, int playerIndex) {
  return rounds.fold(0, (sum, round) {
    switch (playerIndex) {
      case 0:
        return sum + round.scorePlayerOne;
      case 1:
        return sum + round.scorePlayerTwo;
      case 2:
        return sum + round.scorePlayerThree;
      default:
        return sum;
    }
  });
}

int _calculateTotalDeclarations(List<ThreePlayerRound> rounds, int playerIndex, int stigljaValue) {
  return rounds.fold(0, (sum, round) {
    int declarations = 0;
    if (playerIndex == 0) {
      if (round.declStigljaPlayerOne > 0) {
        declarations =
            (round.decl20PlayerOne + round.decl20PlayerTwo + round.decl20PlayerThree) * 20 +
            (round.decl50PlayerOne + round.decl50PlayerTwo + round.decl50PlayerThree) * 50 +
            (round.decl100PlayerOne + round.decl100PlayerTwo + round.decl100PlayerThree) * 100 +
            (round.decl150PlayerOne + round.decl150PlayerTwo + round.decl150PlayerThree) * 150 +
            (round.decl200PlayerOne + round.decl200PlayerTwo + round.decl200PlayerThree) * 200 +
            (round.declStigljaPlayerOne * stigljaValue);
      } else if (round.declStigljaPlayerTwo == 0 && round.declStigljaPlayerThree == 0) {
        declarations =
            round.decl20PlayerOne * 20 +
            round.decl50PlayerOne * 50 +
            round.decl100PlayerOne * 100 +
            round.decl150PlayerOne * 150 +
            round.decl200PlayerOne * 200;
      }
    } else if (playerIndex == 1) {
      if (round.declStigljaPlayerTwo > 0) {
        declarations =
            (round.decl20PlayerOne + round.decl20PlayerTwo + round.decl20PlayerThree) * 20 +
            (round.decl50PlayerOne + round.decl50PlayerTwo + round.decl50PlayerThree) * 50 +
            (round.decl100PlayerOne + round.decl100PlayerTwo + round.decl100PlayerThree) * 100 +
            (round.decl150PlayerOne + round.decl150PlayerTwo + round.decl150PlayerThree) * 150 +
            (round.decl200PlayerOne + round.decl200PlayerTwo + round.decl200PlayerThree) * 200 +
            (round.declStigljaPlayerTwo * stigljaValue);
      } else if (round.declStigljaPlayerOne == 0 && round.declStigljaPlayerThree == 0) {
        declarations =
            round.decl20PlayerTwo * 20 +
            round.decl50PlayerTwo * 50 +
            round.decl100PlayerTwo * 100 +
            round.decl150PlayerTwo * 150 +
            round.decl200PlayerTwo * 200;
      }
    } else if (playerIndex == 2) {
      if (round.declStigljaPlayerThree > 0) {
        declarations =
            (round.decl20PlayerOne + round.decl20PlayerTwo + round.decl20PlayerThree) * 20 +
            (round.decl50PlayerOne + round.decl50PlayerTwo + round.decl50PlayerThree) * 50 +
            (round.decl100PlayerOne + round.decl100PlayerTwo + round.decl100PlayerThree) * 100 +
            (round.decl150PlayerOne + round.decl150PlayerTwo + round.decl150PlayerThree) * 150 +
            (round.decl200PlayerOne + round.decl200PlayerTwo + round.decl200PlayerThree) * 200 +
            (round.declStigljaPlayerThree * stigljaValue);
      } else if (round.declStigljaPlayerOne == 0 && round.declStigljaPlayerTwo == 0) {
        declarations =
            round.decl20PlayerThree * 20 +
            round.decl50PlayerThree * 50 +
            round.decl100PlayerThree * 100 +
            round.decl150PlayerThree * 150 +
            round.decl200PlayerThree * 200;
      }
    }
    return sum + declarations;
  });
}

int _countTotalStiglja(List<ThreePlayerRound> rounds, int playerIndex) {
  return rounds.fold(0, (sum, round) {
    switch (playerIndex) {
      case 0:
        return sum + round.declStigljaPlayerOne;
      case 1:
        return sum + round.declStigljaPlayerTwo;
      case 2:
        return sum + round.declStigljaPlayerThree;
      default:
        return sum;
    }
  });
}

int _sumDeclarationType(List<ThreePlayerRound> rounds, int Function(ThreePlayerRound) selector) {
  return rounds.fold(0, (sum, round) => sum + selector(round));
}

class ThreePlayerFinishedGameScreen extends ConsumerStatefulWidget {
  final ThreePlayerGame game;

  const ThreePlayerFinishedGameScreen({super.key, required this.game});

  @override
  ConsumerState<ThreePlayerFinishedGameScreen> createState() => _ThreePlayerFinishedGameScreenState();
}

class _ThreePlayerFinishedGameScreenState extends ConsumerState<ThreePlayerFinishedGameScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime, String languageCode) {
    final DateFormat dateFormat;
    final DateFormat timeFormat = DateFormat.Hm();

    switch (languageCode) {
      case 'hr':
        dateFormat = DateFormat('d. MMMM yyyy.', 'hr');
        break;
      case 'de':
        dateFormat = DateFormat('d. MMMM yyyy', 'de');
        break;
      default:
        dateFormat = DateFormat('MMMM d, yyyy', 'en');
    }

    return '${dateFormat.format(dateTime)} ${timeFormat.format(dateTime)}';
  }

  Future<void> _shareGame({
    required Rect shareOrigin,
    required String winningPlayer,
    required int stigljaValue,
    required AppLocalizations loc,
  }) async {
    final buffer = StringBuffer();
    final playerOneTotal = widget.game.getPlayerOneTotalScore(stigljaValue: stigljaValue);
    final playerTwoTotal = widget.game.getPlayerTwoTotalScore(stigljaValue: stigljaValue);
    final playerThreeTotal = widget.game.getPlayerThreeTotalScore(stigljaValue: stigljaValue);

    final pointsOne = _calculateTotalPoints(widget.game.rounds, 0);
    final pointsTwo = _calculateTotalPoints(widget.game.rounds, 1);
    final pointsThree = _calculateTotalPoints(widget.game.rounds, 2);

    final declOne = _calculateTotalDeclarations(widget.game.rounds, 0, stigljaValue);
    final declTwo = _calculateTotalDeclarations(widget.game.rounds, 1, stigljaValue);
    final declThree = _calculateTotalDeclarations(widget.game.rounds, 2, stigljaValue);

    final stigljaOne = _countTotalStiglja(widget.game.rounds, 0);
    final stigljaTwo = _countTotalStiglja(widget.game.rounds, 1);
    final stigljaThree = _countTotalStiglja(widget.game.rounds, 2);

    buffer.writeln(loc.translate('shareSummaryTitle'));
    buffer.writeln('\n${widget.game.playerOneName}: $playerOneTotal');
    buffer.writeln('${widget.game.playerTwoName}: $playerTwoTotal');
    buffer.writeln('${widget.game.playerThreeName}: $playerThreeTotal');
    buffer.writeln('${loc.translate('shareWinner')}: $winningPlayer');
    buffer.writeln(_formatDateTime(widget.game.createdAt, loc.locale.languageCode));

    buffer.writeln('\n${loc.translate('shareStatisticsTitle')}:');
    buffer.writeln('${loc.translate('points')}: $pointsOne - $pointsTwo - $pointsThree');
    buffer.writeln('${loc.translate('totalDeclarations')}: $declOne - $declTwo - $declThree');
    buffer.writeln('${loc.translate('totalStiglja')}: $stigljaOne - $stigljaTwo - $stigljaThree');

    buffer.writeln('\n${loc.translate('shareRoundsTitle')}');
    if (widget.game.rounds.isEmpty) {
      buffer.writeln(loc.translate('shareNoRounds'));
    } else {
      for (var i = 0; i < widget.game.rounds.length; i++) {
        final round = widget.game.rounds[i];
        final r1 = computeThreePlayerRoundTotal(round, 0, stigljaValue);
        final r2 = computeThreePlayerRoundTotal(round, 1, stigljaValue);
        final r3 = computeThreePlayerRoundTotal(round, 2, stigljaValue);
        buffer.writeln('${i + 1}. $r1 - $r2 - $r3');
      }
    }

    await Share.share(buffer.toString(), sharePositionOrigin: shareOrigin);
  }

  Future<void> _deleteGame(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 375;
    final buttonFontSize = isSmallScreen ? 16.0 : 18.0;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              loc.translate('clearGameTitle'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
            ),
            contentPadding:
                isSmallScreen
                    ? const EdgeInsets.fromLTRB(16, 16, 16, 0)
                    : const EdgeInsets.fromLTRB(24, 20, 24, 0),
            content: Text(
              loc.translate('clearGameContent'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actionsPadding:
                isSmallScreen
                    ? const EdgeInsets.symmetric(horizontal: 8, vertical: 16)
                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            actions: [
              OverflowBar(
                alignment: MainAxisAlignment.spaceEvenly,
                spacing: isSmallScreen ? 8 : 16,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                      minimumSize: isSmallScreen ? const Size(90, 40) : const Size(100, 40),
                      padding:
                          isSmallScreen
                              ? const EdgeInsets.symmetric(horizontal: 8)
                              : const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(loc.translate('cancel'), style: TextStyle(fontSize: buttonFontSize)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                      minimumSize: isSmallScreen ? const Size(90, 40) : const Size(100, 40),
                      padding:
                          isSmallScreen
                              ? const EdgeInsets.symmetric(horizontal: 8)
                              : const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(loc.translate('delete'), style: TextStyle(fontSize: buttonFontSize)),
                  ),
                ],
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      await _localStorageService.deleteThreePlayerGame(widget.game);
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final int stigljaValue = settings.stigljaValue;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth <= 375;

    final int playerOneTotal = widget.game.getPlayerOneTotalScore(stigljaValue: stigljaValue);
    final int playerTwoTotal = widget.game.getPlayerTwoTotalScore(stigljaValue: stigljaValue);
    final int playerThreeTotal = widget.game.getPlayerThreeTotalScore(stigljaValue: stigljaValue);

    final String winningPlayer =
        !widget.game.isCanceled ? widget.game.getWinningPlayer(stigljaValue: stigljaValue) : '';
    final String formattedDateTime = _formatDateTime(widget.game.createdAt, loc.locale.languageCode);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: theme.colorScheme.surface,
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: Icon(HugeIcons.strokeRoundedArrowLeft01, size: 30),
        ),
        actions: [
          Builder(
            builder: (buttonContext) {
              return IconButton(
                icon: const Icon(HugeIcons.strokeRoundedShare05, size: 26),
                tooltip: loc.translate('shareGame'),
                onPressed: () {
                  final renderBox = buttonContext.findRenderObject() as RenderBox?;
                  final shareOrigin =
                      renderBox != null ? renderBox.localToGlobal(Offset.zero) & renderBox.size : Rect.zero;
                  _shareGame(
                    shareOrigin: shareOrigin,
                    winningPlayer: winningPlayer.isNotEmpty ? winningPlayer : 'Remi',
                    stigljaValue: stigljaValue,
                    loc: loc,
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedDelete02, size: 28),
            onPressed: () => _deleteGame(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            ThreePlayerTotalScoreDisplay(
              scorePlayerOne: playerOneTotal,
              scorePlayerTwo: playerTwoTotal,
              scorePlayerThree: playerThreeTotal,
              playerOneName: widget.game.playerOneName,
              playerTwoName: widget.game.playerTwoName,
              playerThreeName: widget.game.playerThreeName,
              goalScore: widget.game.goalScore,
            ),
            const SizedBox(height: 16),
            Container(
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
                tabs: [Tab(text: loc.translate('statisticsTab')), Tab(text: loc.translate('roundsTab'))],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ThreePlayerStatisticsTab(
                    game: widget.game,
                    stigljaValue: stigljaValue,
                    winningPlayer: winningPlayer,
                  ),
                  _ThreePlayerRoundsTab(rounds: widget.game.rounds),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    HugeIcons.strokeRoundedCalendar03,
                    size: 20,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDateTime,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Nunito',
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreePlayerRoundsTab extends StatelessWidget {
  final List<ThreePlayerRound> rounds;

  const _ThreePlayerRoundsTab({required this.rounds});

  @override
  Widget build(BuildContext context) {
    if (rounds.isEmpty) {
      return Center(
        child: Text(
          'No rounds',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'Nunito',
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      itemCount: rounds.length,
      itemBuilder: (context, index) {
        return ThreePlayerRoundDisplay(round: rounds[index], roundIndex: index);
      },
    );
  }
}

class _ThreePlayerStatisticsTab extends StatelessWidget {
  final ThreePlayerGame game;
  final int stigljaValue;
  final String winningPlayer;

  const _ThreePlayerStatisticsTab({
    required this.game,
    required this.stigljaValue,
    required this.winningPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final rounds = game.rounds;

    final int pointsOne = _calculateTotalPoints(rounds, 0);
    final int pointsTwo = _calculateTotalPoints(rounds, 1);
    final int pointsThree = _calculateTotalPoints(rounds, 2);
    final int declOne = _calculateTotalDeclarations(rounds, 0, stigljaValue);
    final int declTwo = _calculateTotalDeclarations(rounds, 1, stigljaValue);
    final int declThree = _calculateTotalDeclarations(rounds, 2, stigljaValue);
    final int stigljaOne = _countTotalStiglja(rounds, 0);
    final int stigljaTwo = _countTotalStiglja(rounds, 1);
    final int stigljaThree = _countTotalStiglja(rounds, 2);

    final String winnerLabel = winningPlayer.isNotEmpty ? winningPlayer : 'Remi';
    final String displayWinner = winnerLabel == 'Remi' ? winnerLabel : winnerLabel.truncatedForThreePlayers;

    final List<FlSpot> spotsOne = [const FlSpot(0, 0)];
    final List<FlSpot> spotsTwo = [const FlSpot(0, 0)];
    final List<FlSpot> spotsThree = [const FlSpot(0, 0)];
    int cumOne = 0;
    int cumTwo = 0;
    int cumThree = 0;

    for (int i = 0; i < rounds.length; i++) {
      final round = rounds[i];
      cumOne += computeThreePlayerRoundTotal(round, 0, stigljaValue);
      cumTwo += computeThreePlayerRoundTotal(round, 1, stigljaValue);
      cumThree += computeThreePlayerRoundTotal(round, 2, stigljaValue);
      spotsOne.add(FlSpot((i + 1).toDouble(), cumOne.toDouble()));
      spotsTwo.add(FlSpot((i + 1).toDouble(), cumTwo.toDouble()));
      spotsThree.add(FlSpot((i + 1).toDouble(), cumThree.toDouble()));
    }

    final double maxScore = max(cumOne, max(cumTwo, cumThree)).toDouble();
    final double graphMaxY = max(maxScore, 1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final double fontSize =
                  winnerLabel.length <= 4
                      ? 56
                      : winnerLabel.length <= 8
                      ? 44
                      : winnerLabel.length <= 12
                      ? 36
                      : 28;
              final double iconSize = fontSize + 8;

              if (winnerLabel == 'Remi') {
                return SizedBox(
                  width: constraints.maxWidth * 0.9,
                  child: Text(
                    displayWinner,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Nunito',
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }

              return SizedBox(
                width: constraints.maxWidth * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      HugeIcons.strokeRoundedLaurelWreathLeft02,
                      size: iconSize,
                      color: theme.colorScheme.tertiary,
                    ),
                    Flexible(
                      child: Text(
                        displayWinner,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Nunito',
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      HugeIcons.strokeRoundedLaurelWreathRight02,
                      size: iconSize,
                      color: theme.colorScheme.tertiary,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                _buildStatRow(
                  context: context,
                  label: loc.translate('points'),
                  valueOne: pointsOne,
                  valueTwo: pointsTwo,
                  valueThree: pointsThree,
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                const SizedBox(height: 12),
                _buildStatRow(
                  context: context,
                  label: loc.translate('totalDeclarations'),
                  valueOne: declOne,
                  valueTwo: declTwo,
                  valueThree: declThree,
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                const SizedBox(height: 12),
                _buildStatRow(
                  context: context,
                  label: loc.translate('totalStiglja'),
                  valueOne: stigljaOne,
                  valueTwo: stigljaTwo,
                  valueThree: stigljaThree,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildDeclarationsTable(
            rounds: rounds,
            loc: loc,
            theme: theme,
            playerOneName: game.playerOneName,
            playerTwoName: game.playerTwoName,
            playerThreeName: game.playerThreeName,
            stigljaOne: stigljaOne,
            stigljaTwo: stigljaTwo,
            stigljaThree: stigljaThree,
          ),
          const SizedBox(height: 32),
          if (rounds.isNotEmpty)
            Container(
              height: 300,
              padding: const EdgeInsets.only(right: 16),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine:
                        (value) => FlLine(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        ),
                    getDrawingVerticalLine:
                        (value) => FlLine(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return Container();
                          if (rounds.length > 10 && value % 2 != 0) {
                            return Container();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: max(rounds.length.toDouble(), 1),
                  minY: 0,
                  maxY: graphMaxY * 1.1,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => theme.colorScheme.surfaceContainerHighest,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          return LineTooltipItem(
                            '${flSpot.y.toInt()}',
                            TextStyle(
                              color: barSpot.bar.color ?? theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spotsOne,
                      isCurved: false,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                    LineChartBarData(
                      spots: spotsTwo,
                      isCurved: false,
                      color: theme.colorScheme.secondary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.secondary.withOpacity(0.1),
                      ),
                    ),
                    LineChartBarData(
                      spots: spotsThree,
                      isCurved: false,
                      color: theme.colorScheme.tertiary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.tertiary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    game.playerOneName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: theme.colorScheme.secondary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    game.playerTwoName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: theme.colorScheme.tertiary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    game.playerThreeName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required BuildContext context,
    required String label,
    required int valueOne,
    required int valueTwo,
    required int valueThree,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
          ),
        ),
        Expanded(
          child: Text(
            valueOne.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            valueTwo.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            valueThree.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildDeclarationsTable({
    required List<ThreePlayerRound> rounds,
    required AppLocalizations loc,
    required ThemeData theme,
    required String playerOneName,
    required String playerTwoName,
    required String playerThreeName,
    required int stigljaOne,
    required int stigljaTwo,
    required int stigljaThree,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
              3: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2))),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
                    child: Text(
                      loc.translate('declarationsTab'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
                    child: Text(
                      playerOneName.truncatedForThreePlayers,
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
                    child: Text(
                      playerTwoName.truncatedForThreePlayers,
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
                    child: Text(
                      playerThreeName.truncatedForThreePlayers,
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.tertiary),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              _buildDeclRow(
                '20',
                _sumDeclarationType(rounds, (r) => r.decl20PlayerOne),
                _sumDeclarationType(rounds, (r) => r.decl20PlayerTwo),
                _sumDeclarationType(rounds, (r) => r.decl20PlayerThree),
                theme,
              ),
              _buildDeclRow(
                '50',
                _sumDeclarationType(rounds, (r) => r.decl50PlayerOne),
                _sumDeclarationType(rounds, (r) => r.decl50PlayerTwo),
                _sumDeclarationType(rounds, (r) => r.decl50PlayerThree),
                theme,
              ),
              _buildDeclRow(
                '100',
                _sumDeclarationType(rounds, (r) => r.decl100PlayerOne),
                _sumDeclarationType(rounds, (r) => r.decl100PlayerTwo),
                _sumDeclarationType(rounds, (r) => r.decl100PlayerThree),
                theme,
              ),
              _buildDeclRow(
                '150',
                _sumDeclarationType(rounds, (r) => r.decl150PlayerOne),
                _sumDeclarationType(rounds, (r) => r.decl150PlayerTwo),
                _sumDeclarationType(rounds, (r) => r.decl150PlayerThree),
                theme,
              ),
              _buildDeclRow(
                '200',
                _sumDeclarationType(rounds, (r) => r.decl200PlayerOne),
                _sumDeclarationType(rounds, (r) => r.decl200PlayerTwo),
                _sumDeclarationType(rounds, (r) => r.decl200PlayerThree),
                theme,
              ),
              _buildDeclRow(
                loc.translate('allTricks'),
                stigljaOne,
                stigljaTwo,
                stigljaThree,
                theme,
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildDeclRow(String label, int val1, int val2, int val3, ThemeData theme, {bool isLast = false}) {
    return TableRow(
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))),
      ),
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12, bottom: isLast ? 0 : 12, left: 8, right: 8),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12, bottom: isLast ? 0 : 12, left: 8, right: 8),
          child: Text(
            val1.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: val1 > 0 ? FontWeight.bold : FontWeight.normal,
              color: val1 > 0 ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12, bottom: isLast ? 0 : 12, left: 8, right: 8),
          child: Text(
            val2.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: val2 > 0 ? FontWeight.bold : FontWeight.normal,
              color: val2 > 0 ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12, bottom: isLast ? 0 : 12, left: 8, right: 8),
          child: Text(
            val3.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: val3 > 0 ? FontWeight.bold : FontWeight.normal,
              color: val3 > 0 ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}
