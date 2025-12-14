import 'package:bela_blok/models/game.dart';
import 'package:bela_blok/models/round.dart';
import 'package:bela_blok/providers/settings_provider.dart';
import 'package:bela_blok/services/score_calculator.dart';
import 'package:bela_blok/widgets/game_summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/app_localizations.dart';

class FinishedGameScreen extends ConsumerStatefulWidget {
  final Game game;

  const FinishedGameScreen({super.key, required this.game});

  @override
  ConsumerState<FinishedGameScreen> createState() => _FinishedGameScreenState();
}

class _FinishedGameScreenState extends ConsumerState<FinishedGameScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

  int _calculateTotalPoints(List<Round> rounds, {required bool teamOne}) {
    return rounds.fold(0, (sum, round) {
      if (teamOne) {
        return sum + round.scoreTeamOne;
      } else {
        return sum + round.scoreTeamTwo;
      }
    });
  }

  int _calculateTotalDeclarations(List<Round> rounds, {required bool teamOne}) {
    return rounds.fold(0, (sum, round) {
      // If Team One has stiglja, they get all declarations from both teams
      if (round.declStigljaTeamOne > 0 && teamOne) {
        return sum +
            round.decl20TeamOne * 20 +
            round.decl50TeamOne * 50 +
            round.decl100TeamOne * 100 +
            round.decl150TeamOne * 150 +
            round.decl200TeamOne * 200 +
            round.decl20TeamTwo * 20 +
            round.decl50TeamTwo * 50 +
            round.decl100TeamTwo * 100 +
            round.decl150TeamTwo * 150 +
            round.decl200TeamTwo * 200;
      }
      // If Team Two has stiglja, they get all declarations from both teams
      else if (round.declStigljaTeamTwo > 0 && !teamOne) {
        return sum +
            round.decl20TeamOne * 20 +
            round.decl50TeamOne * 50 +
            round.decl100TeamOne * 100 +
            round.decl150TeamOne * 150 +
            round.decl200TeamOne * 200 +
            round.decl20TeamTwo * 20 +
            round.decl50TeamTwo * 50 +
            round.decl100TeamTwo * 100 +
            round.decl150TeamTwo * 150 +
            round.decl200TeamTwo * 200;
      }
      // If Team One has stiglja but we're calculating Team Two's declarations, return 0 for this round
      else if (round.declStigljaTeamOne > 0 && !teamOne) {
        return sum;
      }
      // If Team Two has stiglja but we're calculating Team One's declarations, return 0 for this round
      else if (round.declStigljaTeamTwo > 0 && teamOne) {
        return sum;
      }
      // Normal case (no stiglja)
      else if (teamOne) {
        return sum +
            round.decl20TeamOne * 20 +
            round.decl50TeamOne * 50 +
            round.decl100TeamOne * 100 +
            round.decl150TeamOne * 150 +
            round.decl200TeamOne * 200;
      } else {
        return sum +
            round.decl20TeamTwo * 20 +
            round.decl50TeamTwo * 50 +
            round.decl100TeamTwo * 100 +
            round.decl150TeamTwo * 150 +
            round.decl200TeamTwo * 200;
      }
    });
  }

  int _countTotalStiglja(List<Round> rounds, {required bool teamOne}) {
    return rounds.fold(0, (sum, round) {
      if (teamOne) {
        return sum + round.declStigljaTeamOne;
      } else {
        return sum + round.declStigljaTeamTwo;
      }
    });
  }

  Future<void> _shareGame({
    required int teamOneTotal,
    required int teamTwoTotal,
    required String winningTeam,
    required String formattedDateTime,
    required int stigljaValue,
    required Rect shareOrigin,
    required AppLocalizations loc,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln(loc.translate('shareSummaryTitle'));
    buffer.writeln('\n${widget.game.teamOneName} $teamOneTotal - $teamTwoTotal ${widget.game.teamTwoName}');
    buffer.writeln('${loc.translate('shareWinner')}: $winningTeam');
    buffer.writeln(_formatDateTime(widget.game.createdAt, loc.locale.languageCode));

    buffer.writeln('\n${loc.translate('shareStatisticsTitle')}:');
    final teamOnePoints = _calculateTotalPoints(widget.game.rounds, teamOne: true);
    final teamTwoPoints = _calculateTotalPoints(widget.game.rounds, teamOne: false);
    final teamOneDeclarations = _calculateTotalDeclarations(widget.game.rounds, teamOne: true);
    final teamTwoDeclarations = _calculateTotalDeclarations(widget.game.rounds, teamOne: false);
    final teamOneStiglja = _countTotalStiglja(widget.game.rounds, teamOne: true);
    final teamTwoStiglja = _countTotalStiglja(widget.game.rounds, teamOne: false);

    buffer.writeln('${loc.translate('points')}: $teamOnePoints - $teamTwoPoints');
    buffer.writeln('${loc.translate('totalDeclarations')}: $teamOneDeclarations - $teamTwoDeclarations');
    buffer.writeln('${loc.translate('totalStiglja')}: $teamOneStiglja - $teamTwoStiglja');

    buffer.writeln('\n${loc.translate('shareRoundsTitle')}');

    if (widget.game.rounds.isEmpty) {
      buffer.writeln(loc.translate('shareNoRounds'));
    } else {
      final calculator = ScoreCalculator(stigljaValue: stigljaValue);
      for (var i = 0; i < widget.game.rounds.length; i++) {
        final round = widget.game.rounds[i];
        final one = calculator.computeTeamOneRoundTotal(round);
        final two = calculator.computeTeamTwoRoundTotal(round);
        buffer.writeln('${i + 1}. $one - $two');
      }
    }

    await Share.share(buffer.toString(), sharePositionOrigin: shareOrigin);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final int stigljaValue = settings.stigljaValue;
    final theme = Theme.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth <= 375;

    final int teamOneTotal = ScoreCalculator(
      stigljaValue: stigljaValue,
    ).computeTeamOneTotal(widget.game.rounds);
    final int teamTwoTotal = ScoreCalculator(
      stigljaValue: stigljaValue,
    ).computeTeamTwoTotal(widget.game.rounds);

    String winningTeam = '';
    if (teamOneTotal > teamTwoTotal) {
      winningTeam = widget.game.teamOneName;
    } else if (teamTwoTotal > teamOneTotal) {
      winningTeam = widget.game.teamTwoName;
    } else if (teamOneTotal == teamTwoTotal && teamOneTotal > 0) {
      winningTeam = 'Remi';
    }

    final formattedDateTime = _formatDateTime(widget.game.createdAt, loc.locale.languageCode);

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
                icon: const Icon(HugeIcons.strokeRoundedShare05),
                tooltip: loc.translate('shareGame'),
                onPressed: () {
                  final renderBox = buttonContext.findRenderObject() as RenderBox?;
                  final shareOrigin =
                      renderBox != null ? renderBox.localToGlobal(Offset.zero) & renderBox.size : Rect.zero;
                  _shareGame(
                    teamOneTotal: teamOneTotal,
                    teamTwoTotal: teamTwoTotal,
                    winningTeam: winningTeam.isNotEmpty ? winningTeam : 'Remi',
                    formattedDateTime: formattedDateTime,
                    stigljaValue: stigljaValue,
                    shareOrigin: shareOrigin,
                    loc: loc,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            _SimpleScoreDisplay(
              teamOneName: widget.game.teamOneName,
              teamTwoName: widget.game.teamTwoName,
              scoreTeamOne: teamOneTotal,
              scoreTeamTwo: teamTwoTotal,
            ),
            const SizedBox(height: 16),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
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
                  Tab(text: loc.translate('summaryTab')),
                  Tab(text: loc.translate('roundsTab')),
                  Tab(text: loc.translate('statisticsTab')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: GameSummaryWidget(
                      teamOneName: widget.game.teamOneName,
                      teamTwoName: widget.game.teamTwoName,
                      winningTeam: winningTeam.isNotEmpty ? winningTeam : 'Remi',
                      rounds: widget.game.rounds,
                    ),
                  ),
                  _RoundsTab(rounds: widget.game.rounds, stigljaValue: stigljaValue),
                  const _StatisticsTab(),
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

class _SimpleScoreDisplay extends StatelessWidget {
  final String teamOneName;
  final String teamTwoName;
  final int scoreTeamOne;
  final int scoreTeamTwo;

  const _SimpleScoreDisplay({
    required this.teamOneName,
    required this.teamTwoName,
    required this.scoreTeamOne,
    required this.scoreTeamTwo,
  });

  double _getFontSizeForName(String name) {
    if (name.length <= 4) return 24.0;
    if (name.length <= 8) return 20.0;
    if (name.length <= 12) return 18.0;
    return 16.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                teamOneName,
                style: TextStyle(
                  fontSize: _getFontSizeForName(teamOneName),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito',
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                scoreTeamOne.toString(),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontFamily: 'Nunito',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Text(
          '-',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontFamily: 'Nunito',
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                teamTwoName,
                style: TextStyle(
                  fontSize: _getFontSizeForName(teamTwoName),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito',
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                scoreTeamTwo.toString(),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontFamily: 'Nunito',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundsTab extends StatelessWidget {
  final List<Round> rounds;
  final int stigljaValue;

  const _RoundsTab({required this.rounds, required this.stigljaValue});

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
        final round = rounds[index];
        final calculator = ScoreCalculator(stigljaValue: stigljaValue);
        final teamOneTotal = calculator.computeTeamOneRoundTotal(round);
        final teamTwoTotal = calculator.computeTeamTwoRoundTotal(round);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  '${index + 1}.',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Nunito'),
                ),
              ),
              Expanded(
                child: Text(
                  teamOneTotal.toString(),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                  textAlign: TextAlign.center,
                ),
              ),
              const Expanded(
                child: Text(
                  '-',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, fontFamily: 'Nunito'),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  teamTwoTotal.toString(),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 32),
            ],
          ),
        );
      },
    );
  }
}

class _StatisticsTab extends StatelessWidget {
  const _StatisticsTab();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Center(
      child: Text(
        loc.translate('comingSoon'),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          fontFamily: 'Nunito',
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}
