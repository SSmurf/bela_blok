import 'package:bela_blok/providers/settings_provider.dart';
import 'package:bela_blok/widgets/three_player_add_round_score_display.dart';
import 'package:bela_blok/widgets/declaration_button.dart';
import 'package:bela_blok/widgets/numeric_keyboard.dart';
import 'package:bela_blok/widgets/save_round_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/three_player_round.dart';
import '../providers/three_player_game_provider.dart';
import '../utils/app_localizations.dart';

class ThreePlayerRoundScreen extends ConsumerStatefulWidget {
  final int? roundToEditIndex;
  final ThreePlayerRound? roundToEdit;
  final String playerOneName;
  final String playerTwoName;
  final String playerThreeName;
  final int initialTabIndex;
  final int initialPlayerIndex;

  const ThreePlayerRoundScreen({
    super.key,
    this.roundToEditIndex,
    this.roundToEdit,
    required this.playerOneName,
    required this.playerTwoName,
    required this.playerThreeName,
    this.initialTabIndex = 0,
    this.initialPlayerIndex = 0,
  });

  @override
  ConsumerState<ThreePlayerRoundScreen> createState() => _ThreePlayerRoundScreenState();
}

class _ThreePlayerRoundScreenState extends ConsumerState<ThreePlayerRoundScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String activeScorePlayerOne = '0';
  String activeScorePlayerTwo = '0';
  String activeScorePlayerThree = '0';
  late int selectedPlayerIndex; // 0, 1, or 2
  bool hasStartedInput = false;
  static const int totalPoints = 162;

  // Declaration counters
  int decl20PlayerOne = 0, decl20PlayerTwo = 0, decl20PlayerThree = 0;
  int decl50PlayerOne = 0, decl50PlayerTwo = 0, decl50PlayerThree = 0;
  int decl100PlayerOne = 0, decl100PlayerTwo = 0, decl100PlayerThree = 0;
  int decl150PlayerOne = 0, decl150PlayerTwo = 0, decl150PlayerThree = 0;
  int decl200PlayerOne = 0, decl200PlayerTwo = 0, decl200PlayerThree = 0;
  int declStigljaPlayerOne = 0, declStigljaPlayerTwo = 0, declStigljaPlayerThree = 0;

  // Maximum allowed declarations
  static const int max20 = 5;
  static const int max50 = 4;
  static const int max100 = 4;
  static const int max150 = 1;
  static const int max200 = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    selectedPlayerIndex = widget.initialPlayerIndex;

    if (widget.roundToEdit != null) {
      activeScorePlayerOne = widget.roundToEdit!.scorePlayerOne.toString();
      activeScorePlayerTwo = widget.roundToEdit!.scorePlayerTwo.toString();
      activeScorePlayerThree = widget.roundToEdit!.scorePlayerThree.toString();
      hasStartedInput = true;

      decl20PlayerOne = widget.roundToEdit!.decl20PlayerOne;
      decl20PlayerTwo = widget.roundToEdit!.decl20PlayerTwo;
      decl20PlayerThree = widget.roundToEdit!.decl20PlayerThree;
      decl50PlayerOne = widget.roundToEdit!.decl50PlayerOne;
      decl50PlayerTwo = widget.roundToEdit!.decl50PlayerTwo;
      decl50PlayerThree = widget.roundToEdit!.decl50PlayerThree;
      decl100PlayerOne = widget.roundToEdit!.decl100PlayerOne;
      decl100PlayerTwo = widget.roundToEdit!.decl100PlayerTwo;
      decl100PlayerThree = widget.roundToEdit!.decl100PlayerThree;
      decl150PlayerOne = widget.roundToEdit!.decl150PlayerOne;
      decl150PlayerTwo = widget.roundToEdit!.decl150PlayerTwo;
      decl150PlayerThree = widget.roundToEdit!.decl150PlayerThree;
      decl200PlayerOne = widget.roundToEdit!.decl200PlayerOne;
      decl200PlayerTwo = widget.roundToEdit!.decl200PlayerTwo;
      decl200PlayerThree = widget.roundToEdit!.decl200PlayerThree;
      declStigljaPlayerOne = widget.roundToEdit!.declStigljaPlayerOne;
      declStigljaPlayerTwo = widget.roundToEdit!.declStigljaPlayerTwo;
      declStigljaPlayerThree = widget.roundToEdit!.declStigljaPlayerThree;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get activeScore {
    if (selectedPlayerIndex == 0) return activeScorePlayerOne;
    if (selectedPlayerIndex == 1) return activeScorePlayerTwo;
    return activeScorePlayerThree;
  }

  void _setActiveScore(String score) {
    if (selectedPlayerIndex == 0) {
      activeScorePlayerOne = score;
    } else if (selectedPlayerIndex == 1) {
      activeScorePlayerTwo = score;
    } else {
      activeScorePlayerThree = score;
    }
  }

  void _updateScore(String digit) {
    if (isScoreEditingDisabled) return;
    setState(() {
      hasStartedInput = true;
      String currentScore = activeScore;
      if (currentScore == '0') {
        currentScore = digit;
      } else {
        final newValue = currentScore + digit;
        if (int.parse(newValue) <= totalPoints) {
          currentScore = newValue;
        }
      }
      _setActiveScore(currentScore);
    });
  }

  void _deleteDigit() {
    if (isScoreEditingDisabled) return;
    setState(() {
      String currentScore = activeScore;
      if (currentScore.length > 1) {
        currentScore = currentScore.substring(0, currentScore.length - 1);
      } else {
        currentScore = '0';
      }
      _setActiveScore(currentScore);
      _checkIfInputStarted();
    });
  }

  void _clearScore() {
    if (isScoreEditingDisabled) return;
    setState(() {
      _setActiveScore('0');
      _checkIfInputStarted();
    });
  }

  void _checkIfInputStarted() {
    if (activeScorePlayerOne == '0' && activeScorePlayerTwo == '0' && activeScorePlayerThree == '0') {
      hasStartedInput = false;
    }
  }

  int get playerOneScore => int.parse(activeScorePlayerOne);
  int get playerTwoScore => int.parse(activeScorePlayerTwo);
  int get playerThreeScore => int.parse(activeScorePlayerThree);

  bool get isScoreEditingDisabled {
    return declStigljaPlayerOne > 0 || declStigljaPlayerTwo > 0 || declStigljaPlayerThree > 0;
  }

  bool _canDeclare200(int playerIndex) {
    // Only one player can have 200
    int total200 = decl200PlayerOne + decl200PlayerTwo + decl200PlayerThree;
    if (total200 >= 1) {
      // Can only increment for the player who already has it
      if (playerIndex == 0) return decl200PlayerOne > 0 && decl200PlayerOne < max200;
      if (playerIndex == 1) return decl200PlayerTwo > 0 && decl200PlayerTwo < max200;
      return decl200PlayerThree > 0 && decl200PlayerThree < max200;
    }
    // No one has stiglja from other players
    if (playerIndex == 0) return declStigljaPlayerTwo == 0 && declStigljaPlayerThree == 0;
    if (playerIndex == 1) return declStigljaPlayerOne == 0 && declStigljaPlayerThree == 0;
    return declStigljaPlayerOne == 0 && declStigljaPlayerTwo == 0;
  }

  bool _canDeclareStiglja(int playerIndex) {
    // Only one player can have stiglja
    int totalStiglja = declStigljaPlayerOne + declStigljaPlayerTwo + declStigljaPlayerThree;
    if (totalStiglja >= 1) return false;
    // No 200 from other players
    if (playerIndex == 0) return decl200PlayerTwo == 0 && decl200PlayerThree == 0;
    if (playerIndex == 1) return decl200PlayerOne == 0 && decl200PlayerThree == 0;
    return decl200PlayerOne == 0 && decl200PlayerTwo == 0;
  }

  void _saveRound() {
    final round = ThreePlayerRound(
      scorePlayerOne: playerOneScore,
      scorePlayerTwo: playerTwoScore,
      scorePlayerThree: playerThreeScore,
      decl20PlayerOne: decl20PlayerOne,
      decl20PlayerTwo: decl20PlayerTwo,
      decl20PlayerThree: decl20PlayerThree,
      decl50PlayerOne: decl50PlayerOne,
      decl50PlayerTwo: decl50PlayerTwo,
      decl50PlayerThree: decl50PlayerThree,
      decl100PlayerOne: decl100PlayerOne,
      decl100PlayerTwo: decl100PlayerTwo,
      decl100PlayerThree: decl100PlayerThree,
      decl150PlayerOne: decl150PlayerOne,
      decl150PlayerTwo: decl150PlayerTwo,
      decl150PlayerThree: decl150PlayerThree,
      decl200PlayerOne: decl200PlayerOne,
      decl200PlayerTwo: decl200PlayerTwo,
      decl200PlayerThree: decl200PlayerThree,
      declStigljaPlayerOne: declStigljaPlayerOne,
      declStigljaPlayerTwo: declStigljaPlayerTwo,
      declStigljaPlayerThree: declStigljaPlayerThree,
    );

    if (widget.roundToEditIndex != null) {
      ref.read(currentThreePlayerGameProvider.notifier).updateRound(widget.roundToEditIndex!, round);
    } else {
      ref.read(currentThreePlayerGameProvider.notifier).addRound(round);
    }
    Navigator.of(context).pop();
  }

  void _setPlayerSelection(int playerIndex) {
    if (selectedPlayerIndex != playerIndex) {
      setState(() {
        selectedPlayerIndex = playerIndex;
      });
    }
  }

  Widget _buildPlayerCountCell(int count, VoidCallback onUndo) {
    final theme = Theme.of(context);
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (count > 0) ...[
            Text('x$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onUndo,
              child: Icon(HugeIcons.strokeRoundedRemoveSquare, size: 20, color: theme.colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeclarationRow({
    required String label,
    required int playerOneCount,
    required int playerTwoCount,
    required int playerThreeCount,
    required VoidCallback onPlayerOneIncrement,
    required VoidCallback onPlayerTwoIncrement,
    required VoidCallback onPlayerThreeIncrement,
    required VoidCallback onPlayerOneUndo,
    required VoidCallback onPlayerTwoUndo,
    required VoidCallback onPlayerThreeUndo,
    required double buttonFontSize,
    double? fontSizeOverride,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(horizontal: 2),
  }) {
    final double baseFontSize = fontSizeOverride ?? buttonFontSize;
    double adjustedFontSize = baseFontSize;
    if (label.length > 8) {
      adjustedFontSize *= 0.7;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // Declaration button on the LEFT - clickable to add to active player
          SizedBox(
            width: 90,
            child: DeclarationButton(
              text: label,
              width: 90,
              fontSize: adjustedFontSize,
              contentPadding: contentPadding,
              onPressed: () {
                if (selectedPlayerIndex == 0) {
                  onPlayerOneIncrement();
                } else if (selectedPlayerIndex == 1) {
                  onPlayerTwoIncrement();
                } else {
                  onPlayerThreeIncrement();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          // Player columns to the right
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPlayerCountCell(playerOneCount, onPlayerOneUndo),
                _buildPlayerCountCell(playerTwoCount, onPlayerTwoUndo),
                _buildPlayerCountCell(playerThreeCount, onPlayerThreeUndo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth <= 375;
    final horizontalPadding = isSmallScreen ? 16.0 : 32.0;
    final verticalSpacing = isSmallScreen ? 10.0 : 24.0;

    final mediaPadding = MediaQuery.of(context).padding;
    final bool hasNavigationBar = mediaPadding.bottom > 34;

    int stigljaValue = ref.watch(settingsProvider).stigljaValue;

    // Calculate declaration scores
    final int declScorePlayerOne;
    final int declScorePlayerTwo;
    final int declScorePlayerThree;

    int totalDecl20 = decl20PlayerOne + decl20PlayerTwo + decl20PlayerThree;
    int totalDecl50 = decl50PlayerOne + decl50PlayerTwo + decl50PlayerThree;
    int totalDecl100 = decl100PlayerOne + decl100PlayerTwo + decl100PlayerThree;
    int totalDecl150 = decl150PlayerOne + decl150PlayerTwo + decl150PlayerThree;
    int totalDecl200 = decl200PlayerOne + decl200PlayerTwo + decl200PlayerThree;

    if (declStigljaPlayerOne > 0) {
      declScorePlayerOne =
          totalDecl20 * 20 +
          totalDecl50 * 50 +
          totalDecl100 * 100 +
          totalDecl150 * 150 +
          totalDecl200 * 200 +
          (declStigljaPlayerOne * stigljaValue);
      declScorePlayerTwo = 0;
      declScorePlayerThree = 0;
    } else if (declStigljaPlayerTwo > 0) {
      declScorePlayerTwo =
          totalDecl20 * 20 +
          totalDecl50 * 50 +
          totalDecl100 * 100 +
          totalDecl150 * 150 +
          totalDecl200 * 200 +
          (declStigljaPlayerTwo * stigljaValue);
      declScorePlayerOne = 0;
      declScorePlayerThree = 0;
    } else if (declStigljaPlayerThree > 0) {
      declScorePlayerThree =
          totalDecl20 * 20 +
          totalDecl50 * 50 +
          totalDecl100 * 100 +
          totalDecl150 * 150 +
          totalDecl200 * 200 +
          (declStigljaPlayerThree * stigljaValue);
      declScorePlayerOne = 0;
      declScorePlayerTwo = 0;
    } else {
      declScorePlayerOne =
          decl20PlayerOne * 20 +
          decl50PlayerOne * 50 +
          decl100PlayerOne * 100 +
          decl150PlayerOne * 150 +
          decl200PlayerOne * 200;
      declScorePlayerTwo =
          decl20PlayerTwo * 20 +
          decl50PlayerTwo * 50 +
          decl100PlayerTwo * 100 +
          decl150PlayerTwo * 150 +
          decl200PlayerTwo * 200;
      declScorePlayerThree =
          decl20PlayerThree * 20 +
          decl50PlayerThree * 50 +
          decl100PlayerThree * 100 +
          decl150PlayerThree * 150 +
          decl200PlayerThree * 200;
    }

    final int totalScoreSum = playerOneScore + playerTwoScore + playerThreeScore;
    // Score is valid if: sum <= 162 OR sum == 162 (when exceeding limit)
    // Also allow if all zeros (no input yet)
    bool isScoreValid =
        totalScoreSum <= totalPoints ||
        (totalScoreSum > 0 && playerOneScore + playerTwoScore + playerThreeScore == totalPoints);
    bool isSaveEnabled = hasStartedInput && isScoreValid;
    final double declarationButtonFontSize = isSmallScreen ? 20 : 24;

    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      bottom: hasNavigationBar,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: Navigator.of(context).pop,
            icon: Icon(HugeIcons.strokeRoundedArrowLeft01, size: 30),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
          child: Column(
            children: [
              ThreePlayerAddRoundScoreDisplay(
                scorePlayerOne: playerOneScore,
                scorePlayerTwo: playerTwoScore,
                scorePlayerThree: playerThreeScore,
                declarationScorePlayerOne: declScorePlayerOne,
                declarationScorePlayerTwo: declScorePlayerTwo,
                declarationScorePlayerThree: declScorePlayerThree,
                selectedPlayerIndex: selectedPlayerIndex,
                onPlayerOneTap: () => _setPlayerSelection(0),
                onPlayerTwoTap: () => _setPlayerSelection(1),
                onPlayerThreeTap: () => _setPlayerSelection(2),
                playerOneName: widget.playerOneName,
                playerTwoName: widget.playerTwoName,
                playerThreeName: widget.playerThreeName,
              ),
              SizedBox(height: verticalSpacing),
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
                    fontSize: isSmallScreen ? 18 : 22,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w500,
                    fontSize: isSmallScreen ? 18 : 22,
                  ),
                  unselectedLabelColor: theme.colorScheme.onSurface,
                  tabs: [Tab(text: loc.translate('pointsTab')), Tab(text: loc.translate('declarationsTab'))],
                ),
              ),
              SizedBox(height: verticalSpacing),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    // Points tab
                    AbsorbPointer(
                      absorbing: isScoreEditingDisabled,
                      child: Transform.scale(
                        scale: isSmallScreen ? 0.9 : 1.0,
                        child: NumericKeyboard(
                          onKeyPressed: _updateScore,
                          onDelete: _deleteDigit,
                          onClear: _clearScore,
                          keysEnabled: !isScoreEditingDisabled,
                        ),
                      ),
                    ),
                    // Declarations tab
                    Scrollbar(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildDeclarationsContent(loc, stigljaValue, declarationButtonFontSize),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing / 2),
              Row(
                children: [
                  Expanded(
                    child: SaveRoundButton(
                      text: loc.translate('saveRound'),
                      color: theme.colorScheme.primary,
                      isEnabled: isSaveEnabled,
                      onPressed: isSaveEnabled ? _saveRound : () {},
                      fullWidth: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: verticalSpacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeclarationsContent(AppLocalizations loc, int stigljaValue, double buttonFontSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDeclarationRow(
          label: '20',
          playerOneCount: decl20PlayerOne,
          playerTwoCount: decl20PlayerTwo,
          playerThreeCount: decl20PlayerThree,
          onPlayerOneIncrement:
              () => setState(() {
                if (decl20PlayerOne < max20) decl20PlayerOne++;
              }),
          onPlayerTwoIncrement:
              () => setState(() {
                if (decl20PlayerTwo < max20) decl20PlayerTwo++;
              }),
          onPlayerThreeIncrement:
              () => setState(() {
                if (decl20PlayerThree < max20) decl20PlayerThree++;
              }),
          onPlayerOneUndo:
              () => setState(() {
                if (decl20PlayerOne > 0) decl20PlayerOne--;
              }),
          onPlayerTwoUndo:
              () => setState(() {
                if (decl20PlayerTwo > 0) decl20PlayerTwo--;
              }),
          onPlayerThreeUndo:
              () => setState(() {
                if (decl20PlayerThree > 0) decl20PlayerThree--;
              }),
          buttonFontSize: buttonFontSize,
        ),
        _buildDeclarationRow(
          label: '50',
          playerOneCount: decl50PlayerOne,
          playerTwoCount: decl50PlayerTwo,
          playerThreeCount: decl50PlayerThree,
          onPlayerOneIncrement:
              () => setState(() {
                if (decl50PlayerOne < max50) decl50PlayerOne++;
              }),
          onPlayerTwoIncrement:
              () => setState(() {
                if (decl50PlayerTwo < max50) decl50PlayerTwo++;
              }),
          onPlayerThreeIncrement:
              () => setState(() {
                if (decl50PlayerThree < max50) decl50PlayerThree++;
              }),
          onPlayerOneUndo:
              () => setState(() {
                if (decl50PlayerOne > 0) decl50PlayerOne--;
              }),
          onPlayerTwoUndo:
              () => setState(() {
                if (decl50PlayerTwo > 0) decl50PlayerTwo--;
              }),
          onPlayerThreeUndo:
              () => setState(() {
                if (decl50PlayerThree > 0) decl50PlayerThree--;
              }),
          buttonFontSize: buttonFontSize,
        ),
        _buildDeclarationRow(
          label: '100',
          playerOneCount: decl100PlayerOne,
          playerTwoCount: decl100PlayerTwo,
          playerThreeCount: decl100PlayerThree,
          onPlayerOneIncrement:
              () => setState(() {
                if (decl100PlayerOne < max100) decl100PlayerOne++;
              }),
          onPlayerTwoIncrement:
              () => setState(() {
                if (decl100PlayerTwo < max100) decl100PlayerTwo++;
              }),
          onPlayerThreeIncrement:
              () => setState(() {
                if (decl100PlayerThree < max100) decl100PlayerThree++;
              }),
          onPlayerOneUndo:
              () => setState(() {
                if (decl100PlayerOne > 0) decl100PlayerOne--;
              }),
          onPlayerTwoUndo:
              () => setState(() {
                if (decl100PlayerTwo > 0) decl100PlayerTwo--;
              }),
          onPlayerThreeUndo:
              () => setState(() {
                if (decl100PlayerThree > 0) decl100PlayerThree--;
              }),
          buttonFontSize: buttonFontSize,
        ),
        _buildDeclarationRow(
          label: '150',
          playerOneCount: decl150PlayerOne,
          playerTwoCount: decl150PlayerTwo,
          playerThreeCount: decl150PlayerThree,
          onPlayerOneIncrement: () {
            setState(() {
              if (decl150PlayerOne < max150 && decl150PlayerTwo == 0 && decl150PlayerThree == 0)
                decl150PlayerOne++;
            });
          },
          onPlayerTwoIncrement: () {
            setState(() {
              if (decl150PlayerTwo < max150 && decl150PlayerOne == 0 && decl150PlayerThree == 0)
                decl150PlayerTwo++;
            });
          },
          onPlayerThreeIncrement: () {
            setState(() {
              if (decl150PlayerThree < max150 && decl150PlayerOne == 0 && decl150PlayerTwo == 0)
                decl150PlayerThree++;
            });
          },
          onPlayerOneUndo:
              () => setState(() {
                if (decl150PlayerOne > 0) decl150PlayerOne--;
              }),
          onPlayerTwoUndo:
              () => setState(() {
                if (decl150PlayerTwo > 0) decl150PlayerTwo--;
              }),
          onPlayerThreeUndo:
              () => setState(() {
                if (decl150PlayerThree > 0) decl150PlayerThree--;
              }),
          buttonFontSize: buttonFontSize,
        ),
        _buildDeclarationRow(
          label: '200',
          playerOneCount: decl200PlayerOne,
          playerTwoCount: decl200PlayerTwo,
          playerThreeCount: decl200PlayerThree,
          onPlayerOneIncrement:
              () => setState(() {
                if (_canDeclare200(0)) decl200PlayerOne++;
              }),
          onPlayerTwoIncrement:
              () => setState(() {
                if (_canDeclare200(1)) decl200PlayerTwo++;
              }),
          onPlayerThreeIncrement:
              () => setState(() {
                if (_canDeclare200(2)) decl200PlayerThree++;
              }),
          onPlayerOneUndo:
              () => setState(() {
                if (decl200PlayerOne > 0) decl200PlayerOne--;
              }),
          onPlayerTwoUndo:
              () => setState(() {
                if (decl200PlayerTwo > 0) decl200PlayerTwo--;
              }),
          onPlayerThreeUndo:
              () => setState(() {
                if (decl200PlayerThree > 0) decl200PlayerThree--;
              }),
          buttonFontSize: buttonFontSize,
        ),
        _buildDeclarationRow(
          label: loc.translate('allTricks'),
          playerOneCount: declStigljaPlayerOne,
          playerTwoCount: declStigljaPlayerTwo,
          playerThreeCount: declStigljaPlayerThree,
          onPlayerOneIncrement: () {
            setState(() {
              if (_canDeclareStiglja(0)) {
                declStigljaPlayerOne = 1;
                activeScorePlayerOne = totalPoints.toString();
                activeScorePlayerTwo = '0';
                activeScorePlayerThree = '0';
                hasStartedInput = true;
              }
            });
          },
          onPlayerTwoIncrement: () {
            setState(() {
              if (_canDeclareStiglja(1)) {
                declStigljaPlayerTwo = 1;
                activeScorePlayerOne = '0';
                activeScorePlayerTwo = totalPoints.toString();
                activeScorePlayerThree = '0';
                hasStartedInput = true;
              }
            });
          },
          onPlayerThreeIncrement: () {
            setState(() {
              if (_canDeclareStiglja(2)) {
                declStigljaPlayerThree = 1;
                activeScorePlayerOne = '0';
                activeScorePlayerTwo = '0';
                activeScorePlayerThree = totalPoints.toString();
                hasStartedInput = true;
              }
            });
          },
          onPlayerOneUndo: () {
            setState(() {
              if (declStigljaPlayerOne > 0) {
                declStigljaPlayerOne = 0;
                activeScorePlayerOne = '0';
                activeScorePlayerTwo = '0';
                activeScorePlayerThree = '0';
                hasStartedInput = false;
              }
            });
          },
          onPlayerTwoUndo: () {
            setState(() {
              if (declStigljaPlayerTwo > 0) {
                declStigljaPlayerTwo = 0;
                activeScorePlayerOne = '0';
                activeScorePlayerTwo = '0';
                activeScorePlayerThree = '0';
                hasStartedInput = false;
              }
            });
          },
          onPlayerThreeUndo: () {
            setState(() {
              if (declStigljaPlayerThree > 0) {
                declStigljaPlayerThree = 0;
                activeScorePlayerOne = '0';
                activeScorePlayerTwo = '0';
                activeScorePlayerThree = '0';
                hasStartedInput = false;
              }
            });
          },
          buttonFontSize: buttonFontSize,
          fontSizeOverride: buttonFontSize * 0.8,
        ),
      ],
    );
  }
}
