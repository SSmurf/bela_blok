import 'package:bela_blok/providers/settings_provider.dart';
import 'package:bela_blok/widgets/add_round_score_display.dart';
import 'package:bela_blok/widgets/declaration_button.dart';
import 'package:bela_blok/widgets/numeric_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/round.dart';
import '../providers/game_provider.dart';
import '../widgets/add_round_button.dart';

// Constant font sizes for declarations and štiglja (independent of screen size).
const double declarationFontSize = 28.0;
const double stigljaFontSize = 26.0;

class RoundScreen extends ConsumerStatefulWidget {
  final bool isTeamOneSelected;
  final Round? roundToEdit;
  final int? roundIndex;
  final String teamOneName;
  final String teamTwoName;

  const RoundScreen({
    super.key,
    this.isTeamOneSelected = true,
    this.roundToEdit,
    this.roundIndex,
    required this.teamOneName,
    required this.teamTwoName,
  });

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

    // If we're editing an existing round, initialize the scores and declarations.
    if (widget.roundToEdit != null) {
      // Set the active score.
      if (isTeamOneSelected) {
        activeScore = widget.roundToEdit!.scoreTeamOne.toString();
      } else {
        activeScore = widget.roundToEdit!.scoreTeamTwo.toString();
      }
      if (activeScore != '0') {
        hasStartedInput = true;
      }
      // Load declaration counters.
      decl20TeamOne = widget.roundToEdit!.decl20TeamOne;
      decl20TeamTwo = widget.roundToEdit!.decl20TeamTwo;
      decl50TeamOne = widget.roundToEdit!.decl50TeamOne;
      decl50TeamTwo = widget.roundToEdit!.decl50TeamTwo;
      decl100TeamOne = widget.roundToEdit!.decl100TeamOne;
      decl100TeamTwo = widget.roundToEdit!.decl100TeamTwo;
      decl150TeamOne = widget.roundToEdit!.decl150TeamOne;
      decl150TeamTwo = widget.roundToEdit!.decl150TeamTwo;
      decl200TeamOne = widget.roundToEdit!.decl200TeamOne;
      decl200TeamTwo = widget.roundToEdit!.decl200TeamTwo;
      declStigljaTeamOne = widget.roundToEdit!.declStigljaTeamOne;
      declStigljaTeamTwo = widget.roundToEdit!.declStigljaTeamTwo;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateScore(String digit) {
    if (isScoreEditingDisabled) return;
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
    if (isScoreEditingDisabled) return;
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
    if (isScoreEditingDisabled) return;
    setState(() {
      activeScore = '0';
      hasStartedInput = false;
    });
  }

  int get teamOneScore {
    if (declStigljaTeamOne > 0) {
      return totalPoints;
    }
    if (declStigljaTeamTwo > 0) {
      return 0;
    }
    if (!hasStartedInput) return 0;
    return isTeamOneSelected ? int.parse(activeScore) : totalPoints - int.parse(activeScore);
  }

  int get teamTwoScore {
    if (declStigljaTeamTwo > 0) {
      return totalPoints;
    }
    if (declStigljaTeamOne > 0) {
      return 0;
    }
    if (!hasStartedInput) return 0;
    return isTeamOneSelected ? totalPoints - int.parse(activeScore) : int.parse(activeScore);
  }

  bool get isScoreEditingDisabled {
    return declStigljaTeamOne > 0 || declStigljaTeamTwo > 0;
  }

  void _saveRound() {
    final round = Round(
      scoreTeamOne: teamOneScore,
      scoreTeamTwo: teamTwoScore,
      decl20TeamOne: decl20TeamOne,
      decl20TeamTwo: decl20TeamTwo,
      decl50TeamOne: decl50TeamOne,
      decl50TeamTwo: decl50TeamTwo,
      decl100TeamOne: decl100TeamOne,
      decl100TeamTwo: decl100TeamTwo,
      decl150TeamOne: decl150TeamOne,
      decl150TeamTwo: decl150TeamTwo,
      decl200TeamOne: decl200TeamOne,
      decl200TeamTwo: decl200TeamTwo,
      declStigljaTeamOne: declStigljaTeamOne,
      declStigljaTeamTwo: declStigljaTeamTwo,
    );

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

  Widget _buildDeclarationRow({
    required String label,
    double fontSize = declarationFontSize,
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
        SizedBox(
          width: fixedWidth,
          child: Center(
            child: Text(
              teamOneCount > 0 ? 'x$teamOneCount' : '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
          ),
        ),
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
        SizedBox(
          width: fixedWidth,
          child: Center(
            child: Text(
              teamTwoCount > 0 ? 'x$teamTwoCount' : '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
          ),
        ),
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
    // Using screen size only for padding and layout dimensions.
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth <= 360;
    final horizontalPadding = isSmallScreen ? 16.0 : 32.0;
    final verticalSpacing = isSmallScreen ? 10.0 : 24.0;

    int stigljaValue = ref.watch(settingsProvider).stigljaValue;

    final int declScoreTeamOne;
    final int declScoreTeamTwo;
    if (declStigljaTeamOne > 0) {
      declScoreTeamOne =
          (decl20TeamOne + decl20TeamTwo) * 20 +
          (decl50TeamOne + decl50TeamTwo) * 50 +
          (decl100TeamOne + decl100TeamTwo) * 100 +
          (decl150TeamOne + decl150TeamTwo) * 150 +
          (decl200TeamOne + decl200TeamTwo) * 200 +
          (declStigljaTeamOne * stigljaValue);
      declScoreTeamTwo = 0;
    } else if (declStigljaTeamTwo > 0) {
      declScoreTeamTwo =
          (decl20TeamOne + decl20TeamTwo) * 20 +
          (decl50TeamOne + decl50TeamTwo) * 50 +
          (decl100TeamOne + decl100TeamTwo) * 100 +
          (decl150TeamOne + decl150TeamTwo) * 150 +
          (decl200TeamOne + decl200TeamTwo) * 200 +
          (declStigljaTeamTwo * stigljaValue);
      declScoreTeamOne = 0;
    } else {
      declScoreTeamOne =
          decl20TeamOne * 20 +
          decl50TeamOne * 50 +
          decl100TeamOne * 100 +
          decl150TeamOne * 150 +
          decl200TeamOne * 200 +
          (declStigljaTeamOne * stigljaValue);
      declScoreTeamTwo =
          decl20TeamTwo * 20 +
          decl50TeamTwo * 50 +
          decl100TeamTwo * 100 +
          decl150TeamTwo * 150 +
          decl200TeamTwo * 200 +
          (declStigljaTeamTwo * stigljaValue);
    }

    final int finalTotalTeamOne = teamOneScore + declScoreTeamOne;
    final int finalTotalTeamTwo = teamTwoScore + declScoreTeamTwo;
    bool isSaveEnabled = hasStartedInput && (finalTotalTeamOne != finalTotalTeamTwo);

    final theme = Theme.of(context);
    return SafeArea(
      top: false,
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
              AddRoundScoreDisplay(
                scoreTeamOne: teamOneScore,
                scoreTeamTwo: teamTwoScore,
                declarationScoreTeamOne: declScoreTeamOne,
                declarationScoreTeamTwo: declScoreTeamTwo,
                isTeamOneSelected: isTeamOneSelected,
                onTeamOneTap: () => _setTeamSelection(true),
                onTeamTwoTap: () => _setTeamSelection(false),
                teamOneName: widget.teamOneName,
                teamTwoName: widget.teamTwoName,
              ),
              SizedBox(height: verticalSpacing),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
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
                    fontSize: isSmallScreen ? 20 : 24,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w500,
                    fontSize: isSmallScreen ? 20 : 24,
                  ),
                  unselectedLabelColor: theme.colorScheme.onSurface,
                  tabs: const [Tab(text: 'Bodovi'), Tab(text: 'Zvanja')],
                ),
              ),
              SizedBox(height: verticalSpacing),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    AbsorbPointer(
                      absorbing: isScoreEditingDisabled,
                      child: Transform.scale(
                        scale: isSmallScreen ? 0.9 : 1.0,
                        child: NumericKeyboard(
                          onKeyPressed: _updateScore,
                          onDelete: _deleteDigit,
                          onClear: _clearScore,
                        ),
                      ),
                    ),
                    isSmallScreen
                        ? SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildDeclarationRow(
                                label: '20',
                                fontSize: declarationFontSize,
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
                                fontSize: declarationFontSize,
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
                                fontSize: declarationFontSize,
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
                                fontSize: declarationFontSize,
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
                                fontSize: declarationFontSize,
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
                                fontSize: stigljaFontSize,
                                teamOneCount: declStigljaTeamOne,
                                teamTwoCount: declStigljaTeamTwo,
                                onTeamOneIncrement: () {
                                  setState(() {
                                    if (declStigljaTeamOne < maxStiglja && declStigljaTeamTwo == 0) {
                                      declStigljaTeamOne = 1;
                                      // Force score: team one gets full points, team two 0.
                                      activeScore = totalPoints.toString();
                                      hasStartedInput = true;
                                    }
                                  });
                                },
                                onTeamTwoIncrement: () {
                                  setState(() {
                                    if (declStigljaTeamTwo < maxStiglja && declStigljaTeamOne == 0) {
                                      declStigljaTeamTwo = 1;
                                      // Force score: team two gets full points, team one 0.
                                      activeScore = '0';
                                      hasStartedInput = true;
                                    }
                                  });
                                },
                                onTeamOneUndo: () {
                                  setState(() {
                                    if (declStigljaTeamOne > 0) {
                                      declStigljaTeamOne = 0;
                                      _clearScore();
                                    }
                                  });
                                },
                                onTeamTwoUndo: () {
                                  setState(() {
                                    if (declStigljaTeamTwo > 0) {
                                      declStigljaTeamTwo = 0;
                                      _clearScore();
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildDeclarationRow(
                              label: '20',
                              fontSize: declarationFontSize,
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
                              fontSize: declarationFontSize,
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
                              fontSize: declarationFontSize,
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
                              fontSize: declarationFontSize,
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
                              fontSize: declarationFontSize,
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
                              fontSize: stigljaFontSize,
                              teamOneCount: declStigljaTeamOne,
                              teamTwoCount: declStigljaTeamTwo,
                              onTeamOneIncrement: () {
                                setState(() {
                                  if (declStigljaTeamOne < maxStiglja && declStigljaTeamTwo == 0) {
                                    declStigljaTeamOne = 1;
                                    // Force score: team one gets full points, team two 0.
                                    activeScore = totalPoints.toString();
                                    hasStartedInput = true;
                                  }
                                });
                              },
                              onTeamTwoIncrement: () {
                                setState(() {
                                  if (declStigljaTeamTwo < maxStiglja && declStigljaTeamOne == 0) {
                                    declStigljaTeamTwo = 1;
                                    // Force score: team two gets full points, team one 0.
                                    activeScore = '0';
                                    hasStartedInput = true;
                                  }
                                });
                              },
                              onTeamOneUndo: () {
                                setState(() {
                                  if (declStigljaTeamOne > 0) {
                                    declStigljaTeamOne = 0;
                                    _clearScore();
                                  }
                                });
                              },
                              onTeamTwoUndo: () {
                                setState(() {
                                  if (declStigljaTeamTwo > 0) {
                                    declStigljaTeamTwo = 0;
                                    _clearScore();
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing / 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AddRoundButton(
                    text: 'Spremi',
                    color: theme.colorScheme.primary,
                    isEnabled: isSaveEnabled,
                    onPressed: isSaveEnabled ? _saveRound : () {},
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
}
