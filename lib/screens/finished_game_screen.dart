import 'dart:math';
import 'package:bela_blok/models/game.dart';
import 'package:bela_blok/models/round.dart';
import 'package:bela_blok/providers/game_provider.dart';
import 'package:bela_blok/providers/settings_provider.dart';
import 'package:bela_blok/screens/home_screen.dart';
import 'package:bela_blok/services/local_storage_service.dart';
import 'package:bela_blok/services/score_calculator.dart';
import 'package:bela_blok/widgets/game_summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_localizations.dart';

class FinishedGameScreen extends ConsumerStatefulWidget {
  final Game game;

  const FinishedGameScreen({super.key, required this.game});

  @override
  ConsumerState<FinishedGameScreen> createState() => _FinishedGameScreenState();
}

class _FinishedGameScreenState extends ConsumerState<FinishedGameScreen> with SingleTickerProviderStateMixin {
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

  Future<void> _continueGame(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;

    // Check if there's an active game
    final currentRounds = ref.read(currentGameProvider);
    final currentGame = await _localStorageService.loadCurrentGame();
    final hasActiveGame =
        currentRounds.isNotEmpty ||
        (currentGame != null && !currentGame.isCanceled && currentGame.rounds.isNotEmpty);

    if (hasActiveGame) {
      // Show confirmation dialog
      final screenWidth = MediaQuery.of(context).size.width;
      final isSmallScreen = screenWidth <= 375;
      final buttonFontSize = isSmallScreen ? 16.0 : 18.0;

      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                loc.translate('resumeGameTitle'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
              ),
              contentPadding:
                  isSmallScreen
                      ? const EdgeInsets.fromLTRB(16, 16, 16, 0)
                      : const EdgeInsets.fromLTRB(24, 20, 24, 0),
              content: Text(
                loc.translate('resumeGameContent'),
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
                      onPressed: () => Navigator.of(context).pop(true),
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
                      child: Text(loc.translate('continue'), style: TextStyle(fontSize: buttonFontSize)),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
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
                      child: Text(loc.translate('cancel'), style: TextStyle(fontSize: buttonFontSize)),
                    ),
                  ],
                ),
              ],
            ),
      );

      if (confirmed != true || !context.mounted) {
        return;
      }
    }

    // 1. Update Settings Provider
    ref.read(settingsProvider.notifier).state = ref
        .read(settingsProvider)
        .copyWith(
          teamOneName: widget.game.teamOneName,
          teamTwoName: widget.game.teamTwoName,
          goalScore: widget.game.goalScore,
          // stigljaValue isn't in Game model, so we keep current stiglja value
        );
    // Also save settings to local storage so they persist
    await _localStorageService.saveSettings(ref.read(settingsProvider).toJson());

    // 2. Update Current Game Provider (Rounds)
    ref.read(currentGameProvider.notifier).setRounds(widget.game.rounds);

    // 3. Save as current game in local storage
    // We use the game object from history, which has the correct createdAt.
    // We update it to NOT be canceled (since we are continuing it).
    final gameToContinue = widget.game.copyWith(isCanceled: false);
    await _localStorageService.saveCurrentGame(gameToContinue);

    // 4. Delete from history (unfinished list)
    await _localStorageService.deleteGame(widget.game);

    if (context.mounted) {
      // 5. Navigate to Home Screen
      // clear stack and go to home
      Navigator.of(
        context,
      ).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
    }
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
      await _localStorageService.deleteGame(widget.game);
      if (context.mounted) {
        Navigator.of(context).pop(true); // Return to previous screen with deletion signal
      }
    }
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

    String? winningTeam;
    if (!widget.game.isCanceled) {
      if (teamOneTotal > teamTwoTotal) {
        winningTeam = widget.game.teamOneName;
      } else if (teamTwoTotal > teamOneTotal) {
        winningTeam = widget.game.teamTwoName;
      } else if (teamOneTotal == teamTwoTotal && teamOneTotal > 0) {
        winningTeam = 'Remi';
      }
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
          if (widget.game.isCanceled)
            IconButton(
              icon: const Icon(HugeIcons.strokeRoundedPlay, size: 30),
              onPressed: () => _continueGame(context),
            ),
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
                    teamOneTotal: teamOneTotal,
                    teamTwoTotal: teamTwoTotal,
                    winningTeam: winningTeam ?? 'Remi',
                    formattedDateTime: formattedDateTime,
                    stigljaValue: stigljaValue,
                    shareOrigin: shareOrigin,
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
                  _StatisticsTab(game: widget.game, stigljaValue: stigljaValue, winningTeam: winningTeam),
                  _RoundsTab(rounds: widget.game.rounds, stigljaValue: stigljaValue),
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
  final Game game;
  final int stigljaValue;
  final String? winningTeam;

  const _StatisticsTab({required this.game, required this.stigljaValue, this.winningTeam});

  int _sumDeclarations(bool teamOne, int Function(Round) selector) {
    return game.rounds.fold(0, (sum, round) => sum + selector(round));
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final calculator = ScoreCalculator(stigljaValue: stigljaValue);

    // Declaration counts
    final decl20T1 = _sumDeclarations(true, (r) => r.decl20TeamOne);
    final decl20T2 = _sumDeclarations(false, (r) => r.decl20TeamTwo);
    final decl50T1 = _sumDeclarations(true, (r) => r.decl50TeamOne);
    final decl50T2 = _sumDeclarations(false, (r) => r.decl50TeamTwo);
    final decl100T1 = _sumDeclarations(true, (r) => r.decl100TeamOne);
    final decl100T2 = _sumDeclarations(false, (r) => r.decl100TeamTwo);
    final decl150T1 = _sumDeclarations(true, (r) => r.decl150TeamOne);
    final decl150T2 = _sumDeclarations(false, (r) => r.decl150TeamTwo);
    final decl200T1 = _sumDeclarations(true, (r) => r.decl200TeamOne);
    final decl200T2 = _sumDeclarations(false, (r) => r.decl200TeamTwo);
    final declStigljaT1 = _sumDeclarations(true, (r) => r.declStigljaTeamOne);
    final declStigljaT2 = _sumDeclarations(false, (r) => r.declStigljaTeamTwo);

    // Graph data
    final List<FlSpot> spotsT1 = [];
    final List<FlSpot> spotsT2 = [];
    int cumT1 = 0;
    int cumT2 = 0;

    spotsT1.add(const FlSpot(0, 0));
    spotsT2.add(const FlSpot(0, 0));

    for (int i = 0; i < game.rounds.length; i++) {
      final round = game.rounds[i];
      cumT1 += calculator.computeTeamOneRoundTotal(round);
      cumT2 += calculator.computeTeamTwoRoundTotal(round);
      spotsT1.add(FlSpot((i + 1).toDouble(), cumT1.toDouble()));
      spotsT2.add(FlSpot((i + 1).toDouble(), cumT2.toDouble()));
    }

    final currentMaxScore = max(cumT1, cumT2);
    final graphMaxY = currentMaxScore.toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GameSummaryWidget(
            teamOneName: game.teamOneName,
            teamTwoName: game.teamTwoName,
            winningTeam: winningTeam,
            rounds: game.rounds,
          ),
          const SizedBox(height: 32),
          // Declarations Table
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ),
            child: Table(
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2))),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
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
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        game.teamOneName,
                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        game.teamTwoName,
                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                _buildDeclRow('20', decl20T1, decl20T2, theme),
                _buildDeclRow('50', decl50T1, decl50T2, theme),
                _buildDeclRow('100', decl100T1, decl100T2, theme),
                _buildDeclRow('150', decl150T1, decl150T2, theme),
                _buildDeclRow('200', decl200T1, decl200T2, theme),
                _buildDeclRow(loc.translate('allTricks'), declStigljaT1, declStigljaT2, theme, isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Graph
          if (game.rounds.isNotEmpty)
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
                          // Don't show every round if there are too many
                          if (game.rounds.length > 10 && value % 2 != 0) {
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
                  maxX: game.rounds.length.toDouble(),
                  minY: 0,
                  maxY: graphMaxY * 1.1,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) {
                        return theme.colorScheme.surfaceContainerHighest;
                      },
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
                      spots: spotsT1,
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
                      spots: spotsT2,
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
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Legend
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
                    game.teamOneName,
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
                    game.teamTwoName,
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

  TableRow _buildDeclRow(String label, int val1, int val2, ThemeData theme, {bool isLast = false}) {
    return TableRow(
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))),
      ),
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12, bottom: isLast ? 0 : 12),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12, bottom: isLast ? 0 : 12),
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
          padding: EdgeInsets.only(top: 12, bottom: isLast ? 0 : 12),
          child: Text(
            val2.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: val2 > 0 ? FontWeight.bold : FontWeight.normal,
              color: val2 > 0 ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}
