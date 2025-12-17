import 'package:bela_blok/models/app_settings.dart';
import 'package:bela_blok/models/three_player_game.dart';
import 'package:bela_blok/models/three_player_round.dart';
import 'package:bela_blok/providers/settings_provider.dart';
import 'package:bela_blok/providers/three_player_game_provider.dart';
import 'package:bela_blok/screens/history_screen.dart';
import 'package:bela_blok/screens/settings_screen.dart';
import 'package:bela_blok/screens/three_player_round_screen.dart';
import 'package:bela_blok/services/local_storage_service.dart';
import 'package:bela_blok/widgets/add_round_button.dart';
import 'package:bela_blok/widgets/decorative_divider.dart';
import 'package:bela_blok/widgets/fading_edge_scroll_view.dart';
import 'package:bela_blok/widgets/three_player_round_display.dart';
import 'package:bela_blok/widgets/three_player_total_score_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:vibration/vibration.dart';

import '../utils/app_localizations.dart';
import '../utils/player_name_utils.dart';

class ThreePlayerHomeScreen extends ConsumerStatefulWidget {
  const ThreePlayerHomeScreen({super.key});

  @override
  ConsumerState<ThreePlayerHomeScreen> createState() => _ThreePlayerHomeScreenState();
}

class _ThreePlayerHomeScreenState extends ConsumerState<ThreePlayerHomeScreen> {
  bool _gameSaved = false;
  bool _preventAutoSave = false;
  final LocalStorageService _localStorageService = LocalStorageService();
  bool _celebrationTriggered = false;
  int _playerOneWins = 0;
  int _playerTwoWins = 0;
  int _playerThreeWins = 0;
  bool _victoryCounted = false;
  DateTime? _currentGameCreatedAt;

  @override
  void initState() {
    super.initState();
    _restoreCurrentGame();
  }

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
    final AppSettings settings = ref.read(settingsProvider);
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
                    onPressed: () async {
                      final rounds = ref.read(currentThreePlayerGameProvider);
                      await _saveCanceledGame(rounds, settings);
                      ref.read(currentThreePlayerGameProvider.notifier).clearRounds();
                      await _localStorageService.clearCurrentThreePlayerGame();
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

  void _addNewRound(BuildContext context, AppSettings settings) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ThreePlayerRoundScreen(
              playerOneName: settings.playerOneName,
              playerTwoName: settings.playerTwoName,
              playerThreeName: settings.playerThreeName,
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
      _currentGameCreatedAt = null;
      if (clearWins) {
        _playerOneWins = 0;
        _playerTwoWins = 0;
        _playerThreeWins = 0;
      }
    });
  }

  void _persistCurrentGame(List<ThreePlayerRound> rounds) {
    _persistCurrentGameAsync(rounds);
  }

  Future<void> _persistCurrentGameAsync(List<ThreePlayerRound> rounds) async {
    if (rounds.isEmpty) {
      await _localStorageService.clearCurrentThreePlayerGame();
      if (!mounted) return;
      if (_currentGameCreatedAt != null) {
        setState(() {
          _currentGameCreatedAt = null;
        });
      }
      return;
    }

    final settings = ref.read(settingsProvider);
    final DateTime createdAt = _currentGameCreatedAt ?? DateTime.now();
    final game = ThreePlayerGame(
      playerOneName: settings.playerOneName,
      playerTwoName: settings.playerTwoName,
      playerThreeName: settings.playerThreeName,
      rounds: rounds,
      goalScore: settings.goalScore,
      createdAt: createdAt,
    );

    final savedGame = await _localStorageService.saveCurrentThreePlayerGame(game);
    if (!mounted) return;
    if (_currentGameCreatedAt != savedGame.createdAt) {
      setState(() {
        _currentGameCreatedAt = savedGame.createdAt;
      });
    }
  }

  Future<void> _restoreCurrentGame() async {
    final savedGame = await _localStorageService.loadCurrentThreePlayerGame();
    if (!mounted || savedGame == null || savedGame.isCanceled || savedGame.rounds.isEmpty) return;

    ref.read(currentThreePlayerGameProvider.notifier).setRounds(savedGame.rounds);
    if (!mounted) return;
    setState(() {
      _currentGameCreatedAt = savedGame.createdAt;
    });
  }

  Future<void> _saveCanceledGame(List<ThreePlayerRound> rounds, AppSettings settings) async {
    if (rounds.isEmpty) return;

    await _localStorageService.saveThreePlayerGame(
      rounds,
      playerOneName: settings.playerOneName,
      playerTwoName: settings.playerTwoName,
      playerThreeName: settings.playerThreeName,
      goalScore: settings.goalScore,
      createdAt: _currentGameCreatedAt,
      isCanceled: true,
    );
  }

  void _editRound(BuildContext context, ThreePlayerRound round, int index, AppSettings settings) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ThreePlayerRoundScreen(
              roundToEdit: round,
              roundToEditIndex: index,
              playerOneName: settings.playerOneName,
              playerTwoName: settings.playerTwoName,
              playerThreeName: settings.playerThreeName,
            ),
      ),
    );
  }

  int _computePlayerTotal(List<ThreePlayerRound> rounds, int playerIndex, int stigljaValue) {
    return rounds.fold(0, (sum, round) {
      int baseScore;
      int declarations;

      if (playerIndex == 0) {
        baseScore = round.scorePlayerOne;
        if (round.declStigljaPlayerOne > 0) {
          declarations =
              (round.decl20PlayerOne + round.decl20PlayerTwo + round.decl20PlayerThree) * 20 +
              (round.decl50PlayerOne + round.decl50PlayerTwo + round.decl50PlayerThree) * 50 +
              (round.decl100PlayerOne + round.decl100PlayerTwo + round.decl100PlayerThree) * 100 +
              (round.decl150PlayerOne + round.decl150PlayerTwo + round.decl150PlayerThree) * 150 +
              (round.decl200PlayerOne + round.decl200PlayerTwo + round.decl200PlayerThree) * 200 +
              (round.declStigljaPlayerOne * stigljaValue);
        } else if (round.declStigljaPlayerTwo > 0 || round.declStigljaPlayerThree > 0) {
          declarations = 0;
        } else {
          declarations =
              round.decl20PlayerOne * 20 +
              round.decl50PlayerOne * 50 +
              round.decl100PlayerOne * 100 +
              round.decl150PlayerOne * 150 +
              round.decl200PlayerOne * 200;
        }
      } else if (playerIndex == 1) {
        baseScore = round.scorePlayerTwo;
        if (round.declStigljaPlayerTwo > 0) {
          declarations =
              (round.decl20PlayerOne + round.decl20PlayerTwo + round.decl20PlayerThree) * 20 +
              (round.decl50PlayerOne + round.decl50PlayerTwo + round.decl50PlayerThree) * 50 +
              (round.decl100PlayerOne + round.decl100PlayerTwo + round.decl100PlayerThree) * 100 +
              (round.decl150PlayerOne + round.decl150PlayerTwo + round.decl150PlayerThree) * 150 +
              (round.decl200PlayerOne + round.decl200PlayerTwo + round.decl200PlayerThree) * 200 +
              (round.declStigljaPlayerTwo * stigljaValue);
        } else if (round.declStigljaPlayerOne > 0 || round.declStigljaPlayerThree > 0) {
          declarations = 0;
        } else {
          declarations =
              round.decl20PlayerTwo * 20 +
              round.decl50PlayerTwo * 50 +
              round.decl100PlayerTwo * 100 +
              round.decl150PlayerTwo * 150 +
              round.decl200PlayerTwo * 200;
        }
      } else {
        baseScore = round.scorePlayerThree;
        if (round.declStigljaPlayerThree > 0) {
          declarations =
              (round.decl20PlayerOne + round.decl20PlayerTwo + round.decl20PlayerThree) * 20 +
              (round.decl50PlayerOne + round.decl50PlayerTwo + round.decl50PlayerThree) * 50 +
              (round.decl100PlayerOne + round.decl100PlayerTwo + round.decl100PlayerThree) * 100 +
              (round.decl150PlayerOne + round.decl150PlayerTwo + round.decl150PlayerThree) * 150 +
              (round.decl200PlayerOne + round.decl200PlayerTwo + round.decl200PlayerThree) * 200 +
              (round.declStigljaPlayerThree * stigljaValue);
        } else if (round.declStigljaPlayerOne > 0 || round.declStigljaPlayerTwo > 0) {
          declarations = 0;
        } else {
          declarations =
              round.decl20PlayerThree * 20 +
              round.decl50PlayerThree * 50 +
              round.decl100PlayerThree * 100 +
              round.decl150PlayerThree * 150 +
              round.decl200PlayerThree * 200;
        }
      }

      return sum + baseScore + declarations;
    });
  }

  int _calculateTotalPoints(List<ThreePlayerRound> rounds, int playerIndex) {
    return rounds.fold(0, (sum, round) {
      if (playerIndex == 0) return sum + round.scorePlayerOne;
      if (playerIndex == 1) return sum + round.scorePlayerTwo;
      return sum + round.scorePlayerThree;
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
      } else {
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
      if (playerIndex == 0) return sum + round.declStigljaPlayerOne;
      if (playerIndex == 1) return sum + round.declStigljaPlayerTwo;
      return sum + round.declStigljaPlayerThree;
    });
  }

  Widget _buildStatRow({
    required BuildContext context,
    required String label,
    required int playerOneValue,
    required int playerTwoValue,
    required int playerThreeValue,
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
            playerOneValue.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            playerTwoValue.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            playerThreeValue.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    ref.listen<List<ThreePlayerRound>>(currentThreePlayerGameProvider, (previous, rounds) {
      if (_preventAutoSave) return;
      _persistCurrentGame(rounds);
    });
    final rounds = ref.watch(currentThreePlayerGameProvider);
    final settings = ref.watch(settingsProvider);
    final int currentGoal = settings.goalScore;
    final int stigljaValue = settings.stigljaValue;

    final int playerOneTotal = _computePlayerTotal(rounds, 0, stigljaValue);
    final int playerTwoTotal = _computePlayerTotal(rounds, 1, stigljaValue);
    final int playerThreeTotal = _computePlayerTotal(rounds, 2, stigljaValue);

    final bool gameEnded =
        playerOneTotal >= currentGoal || playerTwoTotal >= currentGoal || playerThreeTotal >= currentGoal;
    final bool hasGameScore = playerOneTotal != 0 || playerTwoTotal != 0 || playerThreeTotal != 0;
    String winningPlayer = '';

    final mediaPadding = MediaQuery.of(context).padding;
    final bool hasNavigationBar = mediaPadding.bottom > 34;

    if (gameEnded) {
      if (playerOneTotal >= currentGoal &&
          playerOneTotal >= playerTwoTotal &&
          playerOneTotal >= playerThreeTotal) {
        winningPlayer = settings.playerOneName;
      } else if (playerTwoTotal >= currentGoal &&
          playerTwoTotal >= playerOneTotal &&
          playerTwoTotal >= playerThreeTotal) {
        winningPlayer = settings.playerTwoName;
      } else if (playerThreeTotal >= currentGoal &&
          playerThreeTotal >= playerOneTotal &&
          playerThreeTotal >= playerTwoTotal) {
        winningPlayer = settings.playerThreeName;
      } else {
        winningPlayer = 'Remi';
      }

      if (winningPlayer != 'Remi' && !_celebrationTriggered) {
        _startCelebration();
      }
    }

    final String displayWinningPlayer =
        winningPlayer == 'Remi' ? winningPlayer : winningPlayer.truncatedForThreePlayers;

    if (gameEnded && !_victoryCounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          if (winningPlayer == settings.playerOneName) {
            _playerOneWins++;
          } else if (winningPlayer == settings.playerTwoName) {
            _playerTwoWins++;
          } else if (winningPlayer == settings.playerThreeName) {
            _playerThreeWins++;
          }
          _victoryCounted = true;
        });
      });
    }

    if (gameEnded && !_gameSaved && !_preventAutoSave) {
      _localStorageService
          .saveThreePlayerGame(
            rounds,
            goalScore: currentGoal,
            playerOneName: settings.playerOneName,
            playerTwoName: settings.playerTwoName,
            playerThreeName: settings.playerThreeName,
            createdAt: _currentGameCreatedAt,
          )
          .then((_) => _localStorageService.clearCurrentThreePlayerGame());
      setState(() {
        _gameSaved = true;
        _preventAutoSave = true;
        _currentGameCreatedAt = null;
      });
    }

    void handleAddRoundPress() {
      if (gameEnded) {
        ref.read(currentThreePlayerGameProvider.notifier).clearRounds();
        _resetGameState();
      }
      _addNewRound(context, settings);
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          child: Column(
            children: [
              ThreePlayerTotalScoreDisplay(
                scorePlayerOne: playerOneTotal,
                scorePlayerTwo: playerTwoTotal,
                scorePlayerThree: playerThreeTotal,
                playerOneName: settings.playerOneName,
                playerTwoName: settings.playerTwoName,
                playerThreeName: settings.playerThreeName,
                playerOneWins: _playerOneWins,
                playerTwoWins: _playerTwoWins,
                playerThreeWins: _playerThreeWins,
                goalScore: currentGoal,
              ),
              const SizedBox(height: 6),
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
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final int nameLength = displayWinningPlayer.length;
                                    final double fontSize =
                                        nameLength <= 4
                                            ? 56
                                            : nameLength <= 8
                                            ? 44
                                            : nameLength <= 12
                                            ? 36
                                            : 28;
                                    final double iconSize = fontSize + 8;

                                    if (winningPlayer == 'Remi') {
                                      return SizedBox(
                                        width: constraints.maxWidth * 0.9,
                                        child: Text(
                                          displayWinningPlayer,
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
                                                displayWinningPlayer,
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
                                        playerOneValue: _calculateTotalPoints(rounds, 0),
                                        playerTwoValue: _calculateTotalPoints(rounds, 1),
                                        playerThreeValue: _calculateTotalPoints(rounds, 2),
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
                                        playerOneValue: _calculateTotalDeclarations(rounds, 0, stigljaValue),
                                        playerTwoValue: _calculateTotalDeclarations(rounds, 1, stigljaValue),
                                        playerThreeValue: _calculateTotalDeclarations(
                                          rounds,
                                          2,
                                          stigljaValue,
                                        ),
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
                                        playerOneValue: _countTotalStiglja(rounds, 0),
                                        playerTwoValue: _countTotalStiglja(rounds, 1),
                                        playerThreeValue: _countTotalStiglja(rounds, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (rounds.isNotEmpty)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      if (gameEnded && _gameSaved) {
                                        _localStorageService.deleteLatestThreePlayerGame().then((success) {
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
                                                  (context) => ThreePlayerRoundScreen(
                                                    roundToEdit: rounds[lastIndex],
                                                    roundToEditIndex: lastIndex,
                                                    playerOneName: settings.playerOneName,
                                                    playerTwoName: settings.playerTwoName,
                                                    playerThreeName: settings.playerThreeName,
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
                            padding: const EdgeInsets.only(left: 8, right: 24),
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
                                                                  ? const EdgeInsets.symmetric(horizontal: 8)
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
                                                                  ? const EdgeInsets.symmetric(horizontal: 8)
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
                                    ref.read(currentThreePlayerGameProvider.notifier).removeRound(index);
                                  },
                                  child: GestureDetector(
                                    onTap: () => _editRound(context, rounds[index], index, settings),
                                    child: ThreePlayerRoundDisplay(round: rounds[index], roundIndex: index),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
              ),
              const SizedBox(height: 24),
              AddRoundButton(
                fullWidth: true,
                text: loc.translate('addRound'),
                color: Theme.of(context).colorScheme.primary,
                onPressed: handleAddRoundPress,
                onLongPress: () {
                  if (gameEnded) {
                    ref.read(currentThreePlayerGameProvider.notifier).clearRounds();
                    _resetGameState();
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => ThreePlayerRoundScreen(
                            playerOneName: settings.playerOneName,
                            playerTwoName: settings.playerTwoName,
                            playerThreeName: settings.playerThreeName,
                            initialTabIndex: 1,
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
