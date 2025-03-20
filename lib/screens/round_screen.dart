import 'package:bela_blok/widgets/declaration_button.dart';
import 'package:bela_blok/widgets/numeric_keyboard.dart';
import 'package:bela_blok/widgets/total_score_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/round.dart';
import '../providers/game_provider.dart';
import '../widgets/add_round_button.dart';

class RoundScreen extends ConsumerStatefulWidget {
  final bool isTeamOneSelected;
  final Round? roundToEdit;
  final int? roundIndex;

  const RoundScreen({super.key, this.isTeamOneSelected = true, this.roundToEdit, this.roundIndex});

  @override
  ConsumerState<RoundScreen> createState() => _RoundScreenState();
}

class _RoundScreenState extends ConsumerState<RoundScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String activeScore = '0';
  late bool isTeamOneSelected;
  bool hasStartedInput = false;
  static const int totalPoints = 162;

  // Declaration counters for each declaration value
  int decl20TeamOne = 0, decl20TeamTwo = 0;
  int decl50TeamOne = 0, decl50TeamTwo = 0;
  int decl100TeamOne = 0, decl100TeamTwo = 0;
  int decl150TeamOne = 0, decl150TeamTwo = 0;
  int decl200TeamOne = 0, decl200TeamTwo = 0;
  int declStigljaTeamOne = 0, declStigljaTeamTwo = 0;

  // Maximum allowed declarations per team
  static const int max20 = 5;
  static const int max50 = 4;
  static const int max100 = 4;
  static const int max150 = 1;
  static const int max200 = 1;
  static const int maxStiglja = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    isTeamOneSelected = widget.isTeamOneSelected;

    // If we're editing an existing round, initialize the scores.
    if (widget.roundToEdit != null) {
      if (isTeamOneSelected) {
        activeScore = widget.roundToEdit!.scoreTeamOne.toString();
      } else {
        activeScore = widget.roundToEdit!.scoreTeamTwo.toString();
      }
      if (activeScore != '0') {
        hasStartedInput = true;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateScore(String digit) {
    setState(() {
      hasStartedInput = true;
      if (activeScore == '0') {
        activeScore = digit;
      } else {
        final newValue = activeScore + digit;
        if (int.parse(newValue) <= totalPoints) {
          activeScore = newValue;
        }
      }
    });
  }

  void _deleteDigit() {
    setState(() {
      if (activeScore.length > 1) {
        activeScore = activeScore.substring(0, activeScore.length - 1);
      } else {
        activeScore = '0';
        if (activeScore == '0') {
          hasStartedInput = false;
        }
      }
    });
  }

  void _clearScore() {
    setState(() {
      activeScore = '0';
      hasStartedInput = false;
    });
  }

  int get teamOneScore {
    if (!hasStartedInput) return 0;
    return isTeamOneSelected ? int.parse(activeScore) : totalPoints - int.parse(activeScore);
  }

  int get teamTwoScore {
    if (!hasStartedInput) return 0;
    return isTeamOneSelected ? totalPoints - int.parse(activeScore) : int.parse(activeScore);
  }

  void _saveRound() {
    final round = Round(scoreTeamOne: teamOneScore, scoreTeamTwo: teamTwoScore);
    if (widget.roundIndex != null) {
      ref.read(currentGameProvider.notifier).updateRound(widget.roundIndex!, round);
    } else {
      ref.read(currentGameProvider.notifier).addRound(round);
    }
    Navigator.of(context).pop();
  }

  void _setTeamSelection(bool selectTeamOne) {
    if (isTeamOneSelected != selectTeamOne) {
      setState(() {
        isTeamOneSelected = selectTeamOne;
        // Invert the score if input has already started.
        if (hasStartedInput) {
          int current = int.parse(activeScore);
          activeScore = (totalPoints - current).toString();
        }
      });
    }
  }

  // Helper method to build each declaration row.
  // Layout:
  // [Team One Undo] [Fixed-width Team One Counter] [Declaration Button] [Fixed-width Team Two Counter] [Team Two Undo]
  // The declaration button adds a declaration to the team that is currently selected.
  Widget _buildDeclarationRow({
    required String label,
    double fontSize = 28,
    required int teamOneCount,
    required int teamTwoCount,
    required VoidCallback onTeamOneIncrement,
    required VoidCallback onTeamTwoIncrement,
    required VoidCallback onTeamOneUndo,
    required VoidCallback onTeamTwoUndo,
  }) {
    const double fixedWidth = 48;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Undo button for Team One.
        SizedBox(
          width: fixedWidth,
          child:
              teamOneCount > 0
                  ? IconButton(
                    icon: const Icon(HugeIcons.strokeRoundedRemoveSquare),
                    onPressed: onTeamOneUndo,
                  )
                  : const SizedBox.shrink(),
        ),
        // Team One counter.
        SizedBox(
          width: fixedWidth,
          child: Center(
            child: Text(
              teamOneCount > 0 ? 'x$teamOneCount' : '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        // Declaration button.
        DeclarationButton(
          text: label,
          fontSize: fontSize,
          onPressed: () {
            if (isTeamOneSelected) {
              onTeamOneIncrement();
            } else {
              onTeamTwoIncrement();
            }
          },
        ),
        // Team Two counter.
        SizedBox(
          width: fixedWidth,
          child: Center(
            child: Text(
              teamTwoCount > 0 ? 'x$teamTwoCount' : '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        // Undo button for Team Two.
        SizedBox(
          width: fixedWidth,
          child:
              teamTwoCount > 0
                  ? IconButton(
                    icon: const Icon(HugeIcons.strokeRoundedRemoveSquare),
                    onPressed: onTeamTwoUndo,
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the declaration scores for each team.
    final int declScoreTeamOne =
        decl20TeamOne * 20 +
        decl50TeamOne * 50 +
        decl100TeamOne * 100 +
        decl150TeamOne * 150 +
        decl200TeamOne * 200 +
        declStigljaTeamOne * 90;

    final int declScoreTeamTwo =
        decl20TeamTwo * 20 +
        decl50TeamTwo * 50 +
        decl100TeamTwo * 100 +
        decl150TeamTwo * 150 +
        decl200TeamTwo * 200 +
        declStigljaTeamTwo * 90;

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        child: Column(
          children: [
            TotalScoreDisplay(
              scoreTeamOne: teamOneScore,
              scoreTeamTwo: teamTwoScore,
              declarationScoreTeamOne: declScoreTeamOne,
              declarationScoreTeamTwo: declScoreTeamTwo,
              isTeamOneSelected: isTeamOneSelected,
              interactable: true,
              onTeamOneTap: () => _setTeamSelection(true),
              onTeamTwoTap: () => _setTeamSelection(false),
            ),
            const SizedBox(height: 24),
            Container(
              height: 48,
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
                unselectedLabelColor: theme.colorScheme.onSurface,
                tabs: const [Tab(text: 'Bodovi'), Tab(text: 'Zvanja')],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Bodovi tab
                  NumericKeyboard(onKeyPressed: _updateScore, onDelete: _deleteDigit, onClear: _clearScore),
                  // Zvanja tab with declaration rows
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDeclarationRow(
                        label: '20',
                        teamOneCount: decl20TeamOne,
                        teamTwoCount: decl20TeamTwo,
                        onTeamOneIncrement: () {
                          setState(() {
                            if (decl20TeamOne < max20) decl20TeamOne++;
                          });
                        },
                        onTeamTwoIncrement: () {
                          setState(() {
                            if (decl20TeamTwo < max20) decl20TeamTwo++;
                          });
                        },
                        onTeamOneUndo: () {
                          setState(() {
                            if (decl20TeamOne > 0) decl20TeamOne--;
                          });
                        },
                        onTeamTwoUndo: () {
                          setState(() {
                            if (decl20TeamTwo > 0) decl20TeamTwo--;
                          });
                        },
                      ),
                      _buildDeclarationRow(
                        label: '50',
                        teamOneCount: decl50TeamOne,
                        teamTwoCount: decl50TeamTwo,
                        onTeamOneIncrement: () {
                          setState(() {
                            if (decl50TeamOne < max50) decl50TeamOne++;
                          });
                        },
                        onTeamTwoIncrement: () {
                          setState(() {
                            if (decl50TeamTwo < max50) decl50TeamTwo++;
                          });
                        },
                        onTeamOneUndo: () {
                          setState(() {
                            if (decl50TeamOne > 0) decl50TeamOne--;
                          });
                        },
                        onTeamTwoUndo: () {
                          setState(() {
                            if (decl50TeamTwo > 0) decl50TeamTwo--;
                          });
                        },
                      ),
                      _buildDeclarationRow(
                        label: '100',
                        teamOneCount: decl100TeamOne,
                        teamTwoCount: decl100TeamTwo,
                        onTeamOneIncrement: () {
                          setState(() {
                            if (decl100TeamOne < max100) decl100TeamOne++;
                          });
                        },
                        onTeamTwoIncrement: () {
                          setState(() {
                            if (decl100TeamTwo < max100) decl100TeamTwo++;
                          });
                        },
                        onTeamOneUndo: () {
                          setState(() {
                            if (decl100TeamOne > 0) decl100TeamOne--;
                          });
                        },
                        onTeamTwoUndo: () {
                          setState(() {
                            if (decl100TeamTwo > 0) decl100TeamTwo--;
                          });
                        },
                      ),
                      _buildDeclarationRow(
                        label: '150',
                        teamOneCount: decl150TeamOne,
                        teamTwoCount: decl150TeamTwo,
                        onTeamOneIncrement: () {
                          setState(() {
                            if (decl150TeamOne < max150) decl150TeamOne++;
                          });
                        },
                        onTeamTwoIncrement: () {
                          setState(() {
                            if (decl150TeamTwo < max150) decl150TeamTwo++;
                          });
                        },
                        onTeamOneUndo: () {
                          setState(() {
                            if (decl150TeamOne > 0) decl150TeamOne--;
                          });
                        },
                        onTeamTwoUndo: () {
                          setState(() {
                            if (decl150TeamTwo > 0) decl150TeamTwo--;
                          });
                        },
                      ),
                      _buildDeclarationRow(
                        label: '200',
                        teamOneCount: decl200TeamOne,
                        teamTwoCount: decl200TeamTwo,
                        onTeamOneIncrement: () {
                          setState(() {
                            if (decl200TeamOne < max200) decl200TeamOne++;
                          });
                        },
                        onTeamTwoIncrement: () {
                          setState(() {
                            if (decl200TeamTwo < max200) decl200TeamTwo++;
                          });
                        },
                        onTeamOneUndo: () {
                          setState(() {
                            if (decl200TeamOne > 0) decl200TeamOne--;
                          });
                        },
                        onTeamTwoUndo: () {
                          setState(() {
                            if (decl200TeamTwo > 0) decl200TeamTwo--;
                          });
                        },
                      ),
                      _buildDeclarationRow(
                        label: 'Štiglja',
                        fontSize: 24,
                        teamOneCount: declStigljaTeamOne,
                        teamTwoCount: declStigljaTeamTwo,
                        onTeamOneIncrement: () {
                          setState(() {
                            if (declStigljaTeamOne < maxStiglja) declStigljaTeamOne++;
                          });
                        },
                        onTeamTwoIncrement: () {
                          setState(() {
                            if (declStigljaTeamTwo < maxStiglja) declStigljaTeamTwo++;
                          });
                        },
                        onTeamOneUndo: () {
                          setState(() {
                            if (declStigljaTeamOne > 0) declStigljaTeamOne--;
                          });
                        },
                        onTeamTwoUndo: () {
                          setState(() {
                            if (declStigljaTeamTwo > 0) declStigljaTeamTwo--;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AddRoundButton(
                  text: 'Spremi',
                  color: theme.colorScheme.primary,
                  onPressed: hasStartedInput ? _saveRound : () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
