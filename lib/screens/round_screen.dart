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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    isTeamOneSelected = widget.isTeamOneSelected;

    // If we're editing an existing round, initialize the scores
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
        // Invert the score if input has already started
        if (hasStartedInput) {
          int current = int.parse(activeScore);
          activeScore = (totalPoints - current).toString();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 24),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Bodovi tab
                  Expanded(
                    child: NumericKeyboard(
                      onKeyPressed: _updateScore,
                      onDelete: _deleteDigit,
                      onClear: _clearScore,
                    ),
                  ),
                  // Zvanja tab
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
                    ),
                    child: const Center(child: Text('Zvanja Content', style: TextStyle(fontSize: 18))),
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

class NumericKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onDelete;
  final VoidCallback onClear;

  const NumericKeyboard({
    super.key,
    required this.onKeyPressed,
    required this.onDelete,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildKeyButton('1', onKeyPressed, theme),
              _buildKeyButton('2', onKeyPressed, theme),
              _buildKeyButton('3', onKeyPressed, theme),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildKeyButton('4', onKeyPressed, theme),
              _buildKeyButton('5', onKeyPressed, theme),
              _buildKeyButton('6', onKeyPressed, theme),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildKeyButton('7', onKeyPressed, theme),
              _buildKeyButton('8', onKeyPressed, theme),
              _buildKeyButton('9', onKeyPressed, theme),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildActionButton(onClear, theme, HugeIcons.strokeRoundedDelete02, false),
              _buildKeyButton('0', onKeyPressed, theme),
              _buildActionButton(onDelete, theme, HugeIcons.strokeRoundedEraser01, true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyButton(String text, Function(String) onPressed, ThemeData theme) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => onPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            padding: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Center(child: Text(text, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  Widget _buildActionButton(VoidCallback onPressed, ThemeData theme, IconData icon, bool reverseIcon) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(reverseIcon ? 3.14159 : 0),
              child: Icon(icon, size: 40),
            ),
          ),
        ),
      ),
    );
  }
}
