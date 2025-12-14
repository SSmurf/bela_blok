import 'package:bela_blok/models/round.dart';
import 'package:bela_blok/providers/game_provider.dart';
import 'package:bela_blok/providers/settings_provider.dart';
import 'package:bela_blok/screens/history_screen.dart';
import 'package:bela_blok/screens/round_screen.dart';
import 'package:bela_blok/screens/settings_screen.dart';
import 'package:bela_blok/services/local_storage_service.dart';
import 'package:bela_blok/services/score_calculator.dart';
import 'package:bela_blok/widgets/add_round_button.dart';
import 'package:bela_blok/widgets/decorative_divider.dart';
import 'package:bela_blok/widgets/landscape_total_score_display.dart';
import 'package:bela_blok/widgets/round_display.dart';
import 'package:bela_blok/widgets/total_score_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:vibration/vibration.dart';

import '../utils/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _gameSaved = false;
  bool _preventAutoSave = false;
  final LocalStorageService _localStorageService = LocalStorageService();
  bool _celebrationTriggered = false;
  int _teamOneWins = 0;
  int _teamTwoWins = 0;
  bool _victoryCounted = false;

  Future<void> _startCelebration() async {
    if (!_celebrationTriggered) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 300);
      }

      setState(() {
        _celebrationTriggered = true;
      });
    }
  }

  EdgeInsets _getDialogPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 375;

    return isSmallScreen
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 16)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  void _confirmClearGame(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 375;
    final buttonFontSize = isSmallScreen ? 16.0 : 18.0;

    showDialog(
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
            actionsPadding: _getDialogPadding(context),
            actions: [
              OverflowBar(
                alignment: MainAxisAlignment.spaceEvenly,
                spacing: isSmallScreen ? 8 : 16,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
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
                    onPressed: () {
                      ref.read(currentGameProvider.notifier).clearRounds();
                      _resetGameState(clearWins: true);
                      Navigator.of(context).pop();
                    },
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
  }

  void _addNewRound(
    BuildContext context, {
    required bool isTeamOneSelected,
    required String teamOneName,
    required String teamTwoName,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => RoundScreen(
              isTeamOneSelected: isTeamOneSelected,
              teamOneName: teamOneName,
              teamTwoName: teamTwoName,
            ),
      ),
    );
  }

  void _resetGameState({bool clearWins = false}) {
    setState(() {
      _gameSaved = false;
      _preventAutoSave = false;
      _celebrationTriggered = false;
      _victoryCounted = false;
      if (clearWins) {
        _teamOneWins = 0;
        _teamTwoWins = 0;
      }
    });
  }

  _editRound(
    BuildContext context,
    Round round,
    int index, {
    required String teamOneName,
    required String teamTwoName,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => RoundScreen(
              roundToEdit: round,
              roundIndex: index,
              isTeamOneSelected: true,
              teamOneName: teamOneName,
              teamTwoName: teamTwoName,
            ),
      ),
    );
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

  // Calculate total declaration points (excluding stiglja)
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

  // Count total stiglja
  int _countTotalStiglja(List<Round> rounds, {required bool teamOne}) {
    return rounds.fold(0, (sum, round) {
      if (teamOne) {
        return sum + round.declStigljaTeamOne;
      } else {
        return sum + round.declStigljaTeamTwo;
      }
    });
  }

  // Build a stat row with team values and label
  Widget _buildStatRow({
    required BuildContext context,
    required String label,
    required int teamOneValue,
    required int teamTwoValue,
    required String teamOneName,
    required String teamTwoName,
  }) {
    return Row(
      children: [
        // Team One Value
        Expanded(
          child: Text(
            teamOneValue.toString(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
            textAlign: TextAlign.center,
          ),
        ),
        // Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
          ),
        ),
        // Team Two Value
        Expanded(
          child: Text(
            teamTwoValue.toString(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final rounds = ref.watch(currentGameProvider);
    final settings = ref.watch(settingsProvider);
    final int currentGoal = settings.goalScore;
    final int teamOneTotal = ScoreCalculator(stigljaValue: settings.stigljaValue).computeTeamOneTotal(rounds);
    final int teamTwoTotal = ScoreCalculator(stigljaValue: settings.stigljaValue).computeTeamTwoTotal(rounds);
    final bool gameEnded = teamOneTotal >= currentGoal || teamTwoTotal >= currentGoal;
    final bool hasGameScore = teamOneTotal != 0 || teamTwoTotal != 0;
    String winningTeam = '';

    final mediaPadding = MediaQuery.of(context).padding;
    final bool hasNavigationBar = mediaPadding.bottom > 34;
    final orientation = MediaQuery.of(context).orientation;

    if (gameEnded) {
      if (teamOneTotal > teamTwoTotal) {
        winningTeam = settings.teamOneName;
      } else if (teamTwoTotal > teamOneTotal) {
        winningTeam = settings.teamTwoName;
      } else {
        winningTeam = 'Remi';
      }

      if (winningTeam != 'Remi' && !_celebrationTriggered) {
        _startCelebration();
      }
    }

    if (gameEnded && !_victoryCounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          if (teamOneTotal > teamTwoTotal) {
            _teamOneWins++;
          } else if (teamTwoTotal > teamOneTotal) {
            _teamTwoWins++;
          }
          _victoryCounted = true;
        });
      });
    }

    if (gameEnded && !_gameSaved && !_preventAutoSave) {
      _localStorageService.saveGame(
        rounds,
        goalScore: currentGoal,
        teamOneName: settings.teamOneName,
        teamTwoName: settings.teamTwoName,
      );
      setState(() {
        _gameSaved = true;
      });
    }

    void _handleTeamButtonPress(bool isTeamOneSelected) {
      if (gameEnded) {
        ref.read(currentGameProvider.notifier).clearRounds();
        _resetGameState();
      }

      _addNewRound(
        context,
        isTeamOneSelected: isTeamOneSelected,
        teamOneName: settings.teamOneName,
        teamTwoName: settings.teamTwoName,
      );
    }

    if (orientation == Orientation.landscape) {
      double horizontalPadding = MediaQuery.of(context).size.width <= 640 ? 16 : 64;
      return Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 64, horizontal: horizontalPadding),
          child: Center(
            child: LandscapeTotalScoreDisplay(
              scoreTeamOne: teamOneTotal,
              scoreTeamTwo: teamTwoTotal,
              teamOneName: settings.teamOneName,
              teamTwoName: settings.teamTwoName,
              teamOneWins: _teamOneWins,
              teamTwoWins: _teamTwoWins,
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      bottom: hasNavigationBar,
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Theme.of(context).colorScheme.surface,
          leading: IconButton(
            icon: const Icon(HugeIcons.strokeRoundedSettings02),
            iconSize: 32,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(HugeIcons.strokeRoundedCancel01),
              iconSize: 32,
              // onPressed: hasGameScore && !gameEnded ? () => _confirmClearGame(context) : null,
              onPressed: hasGameScore ? () => _confirmClearGame(context) : null,
            ),
            IconButton(
              icon: const Icon(HugeIcons.strokeRoundedClock02),
              iconSize: 32,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              child: Column(
                children: [
                  TotalScoreDisplay(
                    scoreTeamOne: teamOneTotal,
                    scoreTeamTwo: teamTwoTotal,
                    teamOneName: settings.teamOneName,
                    teamTwoName: settings.teamTwoName,
                    teamOneWins: _teamOneWins,
                    teamTwoWins: _teamTwoWins,
                  ),
                  const SizedBox(height: 6),

                  // Row(
                  //   children: [
                  //     Expanded(child: const Divider(height: 1, thickness: 1)),
                  //     Icon(HugeIcons.strokeRoundedRecord, size: 16),
                  //     Expanded(child: const Divider(height: 1, thickness: 1)),
                  //   ],
                  // ),
                  const DecorativeDivider(),
                  const SizedBox(height: 12),
                  Expanded(
                    child:
                        gameEnded
                            ? Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 24),
                                    // Winner display with dynamic text size
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final double fontSize =
                                            winningTeam.length <= 4
                                                ? 56
                                                : winningTeam.length <= 8
                                                ? 44
                                                : winningTeam.length <= 12
                                                ? 36
                                                : 28;
                                        final double iconSize = fontSize + 8;

                                        if (winningTeam == 'Remi') {
                                          return SizedBox(
                                            width: constraints.maxWidth * 0.9,
                                            child: Text(
                                              winningTeam,
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
                                        } else {
                                          return SizedBox(
                                            width: constraints.maxWidth * 0.9,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  HugeIcons.strokeRoundedLaurelWreathLeft02,
                                                  size: iconSize,
                                                  color: Theme.of(context).colorScheme.tertiary,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    winningTeam,
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
                                                  color: Theme.of(context).colorScheme.tertiary,
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 32),
                                    // Game stats summary
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          _buildStatRow(
                                            context: context,
                                            label: loc.translate('points'),
                                            teamOneValue: _calculateTotalPoints(rounds, teamOne: true),
                                            teamTwoValue: _calculateTotalPoints(rounds, teamOne: false),
                                            teamOneName: settings.teamOneName,
                                            teamTwoName: settings.teamTwoName,
                                          ),
                                          const SizedBox(height: 12),
                                          Divider(
                                            height: 1,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                          ),
                                          const SizedBox(height: 12),
                                          _buildStatRow(
                                            context: context,
                                            label: loc.translate('totalDeclarations'),
                                            teamOneValue: _calculateTotalDeclarations(rounds, teamOne: true),
                                            teamTwoValue: _calculateTotalDeclarations(rounds, teamOne: false),
                                            teamOneName: settings.teamOneName,
                                            teamTwoName: settings.teamTwoName,
                                          ),
                                          const SizedBox(height: 12),
                                          Divider(
                                            height: 1,
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                          ),
                                          const SizedBox(height: 12),
                                          _buildStatRow(
                                            context: context,
                                            label: loc.translate('totalStiglja'),
                                            teamOneValue: _countTotalStiglja(rounds, teamOne: true),
                                            teamTwoValue: _countTotalStiglja(rounds, teamOne: false),
                                            teamOneName: settings.teamOneName,
                                            teamTwoName: settings.teamTwoName,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    if (rounds.isNotEmpty)
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          if (gameEnded && _gameSaved) {
                                            _localStorageService.deleteLatestGame().then((success) {
                                              if (success) {
                                                setState(() {
                                                  _gameSaved = false;
                                                  _preventAutoSave = true;
                                                });
                                              }
                                            });
                                          }

                                          final int lastIndex = rounds.length - 1;
                                          Navigator.of(context)
                                              .push(
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) => RoundScreen(
                                                        roundToEdit: rounds[lastIndex],
                                                        roundIndex: lastIndex,
                                                        isTeamOneSelected: true,
                                                        teamOneName: settings.teamOneName,
                                                        teamTwoName: settings.teamTwoName,
                                                      ),
                                                ),
                                              )
                                              .then((_) {
                                                if (_preventAutoSave) {
                                                  setState(() {
                                                    _preventAutoSave = false;
                                                  });
                                                }
                                              });
                                        },
                                        icon: const Icon(HugeIcons.strokeRoundedUndo),
                                        label: Text(
                                          loc.translate('undoLastRound'),
                                          style: const TextStyle(fontFamily: 'Nunito'),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                            : rounds.isEmpty
                            ? Center(
                              child: Text(
                                loc.translate('respectTheCards'),
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                            : FadingEdgeScrollView(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: ListView.builder(
                                  itemCount: rounds.length,
                                  itemBuilder: (context, index) {
                                    return Dismissible(
                                      key: ValueKey('round_${rounds[index].hashCode}'),
                                      background: Container(
                                        color: Colors.red.withOpacity(0.7),
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(right: 20),
                                        child: const Icon(Icons.delete, color: Colors.white),
                                      ),
                                      direction: DismissDirection.endToStart,
                                      confirmDismiss: (_) async {
                                        final screenWidth = MediaQuery.of(context).size.width;
                                        final isSmallScreen = screenWidth <= 375;
                                        final buttonFontSize = isSmallScreen ? 16.0 : 18.0;

                                        return await showDialog<bool>(
                                              context: context,
                                              builder:
                                                  (context) => AlertDialog(
                                                    title: Text(
                                                      loc.translate('deleteRoundTitle'),
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w500,
                                                        fontFamily: 'Nunito',
                                                      ),
                                                    ),
                                                    contentPadding:
                                                        isSmallScreen
                                                            ? const EdgeInsets.fromLTRB(16, 16, 16, 0)
                                                            : const EdgeInsets.fromLTRB(24, 20, 24, 0),
                                                    content: Text(
                                                      loc.translate('deleteRoundContent'),
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w500,
                                                        fontFamily: 'Nunito',
                                                      ),
                                                    ),
                                                    actionsAlignment: MainAxisAlignment.spaceEvenly,
                                                    actionsPadding: _getDialogPadding(context),
                                                    actions: [
                                                      OverflowBar(
                                                        alignment: MainAxisAlignment.spaceEvenly,
                                                        spacing: isSmallScreen ? 8 : 16,
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed: () => Navigator.of(context).pop(false),
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Theme.of(context).colorScheme.primary,
                                                              foregroundColor: Colors.white,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              elevation: 0,
                                                              minimumSize:
                                                                  isSmallScreen
                                                                      ? const Size(90, 40)
                                                                      : const Size(100, 40),
                                                              padding:
                                                                  isSmallScreen
                                                                      ? const EdgeInsets.symmetric(
                                                                        horizontal: 8,
                                                                      )
                                                                      : const EdgeInsets.symmetric(
                                                                        horizontal: 16,
                                                                      ),
                                                            ),
                                                            child: Text(
                                                              loc.translate('cancel'),
                                                              style: TextStyle(fontSize: buttonFontSize),
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () => Navigator.of(context).pop(true),
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Theme.of(context).colorScheme.secondary,
                                                              foregroundColor: Colors.white,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              elevation: 0,
                                                              minimumSize:
                                                                  isSmallScreen
                                                                      ? const Size(90, 40)
                                                                      : const Size(100, 40),
                                                              padding:
                                                                  isSmallScreen
                                                                      ? const EdgeInsets.symmetric(
                                                                        horizontal: 8,
                                                                      )
                                                                      : const EdgeInsets.symmetric(
                                                                        horizontal: 16,
                                                                      ),
                                                            ),
                                                            child: Text(
                                                              loc.translate('delete'),
                                                              style: TextStyle(fontSize: buttonFontSize),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                            ) ??
                                            false;
                                      },
                                      onDismissed: (_) {
                                        ref.read(currentGameProvider.notifier).removeRound(index);
                                      },
                                      child: GestureDetector(
                                        onTap:
                                            () => _editRound(
                                              context,
                                              rounds[index],
                                              index,
                                              teamOneName: settings.teamOneName,
                                              teamTwoName: settings.teamTwoName,
                                            ),
                                        child: RoundDisplay(round: rounds[index], roundIndex: index),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AddRoundButton(
                          fullWidth: true,
                          text: settings.teamOneName,
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: () => _handleTeamButtonPress(true),
                          onLongPress: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => RoundScreen(
                                      teamOneName: settings.teamOneName,
                                      teamTwoName: settings.teamTwoName,
                                      isTeamOneSelected: true,
                                      initialTabIndex: 1,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AddRoundButton(
                          fullWidth: true,
                          text: settings.teamTwoName,
                          color: Theme.of(context).colorScheme.secondary,
                          onPressed: () => _handleTeamButtonPress(false),
                          onLongPress: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => RoundScreen(
                                      teamOneName: settings.teamOneName,
                                      teamTwoName: settings.teamTwoName,
                                      isTeamOneSelected: false,
                                      initialTabIndex: 1,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FadingEdgeScrollView extends StatelessWidget {
  final Widget child;
  final double fadeHeight;

  const FadingEdgeScrollView({super.key, required this.child, this.fadeHeight = 20.0});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
          stops: [0.0, fadeHeight / rect.height, 1.0 - (fadeHeight / rect.height), 1.0],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}
