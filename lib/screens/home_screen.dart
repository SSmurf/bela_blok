import 'package:bela_blok/models/round.dart';
import 'package:bela_blok/providers/game_provider.dart';
import 'package:bela_blok/providers/settings_provider.dart';
import 'package:bela_blok/screens/history_screen.dart';
import 'package:bela_blok/screens/round_screen.dart';
import 'package:bela_blok/screens/settings_screen.dart';
import 'package:bela_blok/services/local_storage_service.dart';
import 'package:bela_blok/services/score_calculator.dart';
import 'package:bela_blok/widgets/add_round_button.dart';
import 'package:bela_blok/widgets/round_display.dart';
import 'package:bela_blok/widgets/total_score_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _gameSaved = false;
  final LocalStorageService _localStorageService = LocalStorageService();

  void _confirmClearGame(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Brisanje igre'),
            content: const Text('Jesi li siguran da želiš obrisati sve runde?'),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Odustani', style: TextStyle(fontSize: 18)),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(currentGameProvider.notifier).clearRounds();
                  setState(() {
                    _gameSaved = false;
                  });
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Obriši', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
    );
  }

  _addNewRound(BuildContext context, {required String teamOneName, required String teamTwoName}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) =>
                RoundScreen(isTeamOneSelected: true, teamOneName: teamOneName, teamTwoName: teamTwoName),
      ),
    );
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

  // Calculate total declaration points (excluding stiglja)
  int _calculateTotalDeclarations(List<Round> rounds, {required bool teamOne}) {
    return rounds.fold(0, (sum, round) {
      if (teamOne) {
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
    final rounds = ref.watch(currentGameProvider);
    final settings = ref.watch(settingsProvider);
    final int currentGoal = settings.goalScore;
    final int teamOneTotal = ScoreCalculator(stigljaValue: settings.stigljaValue).computeTeamOneTotal(rounds);
    final int teamTwoTotal = ScoreCalculator(stigljaValue: settings.stigljaValue).computeTeamTwoTotal(rounds);
    final bool gameEnded = teamOneTotal >= currentGoal || teamTwoTotal >= currentGoal;
    String winningTeam = '';

    if (gameEnded) {
      if (teamOneTotal > teamTwoTotal) {
        winningTeam = settings.teamOneName;
      } else if (teamTwoTotal > teamOneTotal) {
        winningTeam = settings.teamTwoName;
      } else {
        winningTeam = 'Remi';
      }
    }

    if (gameEnded && !_gameSaved) {
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

    return Scaffold(
      appBar: AppBar(
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
            onPressed: rounds.isNotEmpty && !gameEnded ? () => _confirmClearGame(context) : null,
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
            TotalScoreDisplay(
              scoreTeamOne: teamOneTotal,
              scoreTeamTwo: teamTwoTotal,
              teamOneName: settings.teamOneName,
              teamTwoName: settings.teamTwoName,
            ),
            const SizedBox(height: 6),

            // Row(
            //   children: [
            //     Expanded(child: const Divider(height: 1, thickness: 1)),
            //     Icon(HugeIcons.strokeRoundedRecord, size: 16),
            //     Expanded(child: const Divider(height: 1, thickness: 1)),
            //   ],
            // ),
            Image.asset('assets/images/divider_1.png', fit: BoxFit.fitWidth, color: Colors.white),

            const SizedBox(height: 12),
            Expanded(
              child:
                  gameEnded
                      ? Center(
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
                                    label: "Ukupno zvanja",
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
                                    label: "Ukupno štiglji",
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
                                  final int lastIndex = rounds.length - 1;
                                  Navigator.of(context).push(
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
                                  );
                                },
                                icon: const Icon(HugeIcons.strokeRoundedUndo),
                                label: const Text(
                                  'Poništi zadnju rundu',
                                  style: TextStyle(fontFamily: 'Nunito'),
                                ),
                              ),
                          ],
                        ),
                      )
                      : rounds.isEmpty
                      ? Center(
                        child: Text(
                          '"Poštuj kartu i karta će poštovati tebe."',
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 24, fontWeight: FontWeight.w500),
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
                                  color: Colors.red.withValues(alpha: 0.7),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (_) async {
                                  return await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text('Brisanje runde'),
                                              content: const Text(
                                                'Jesi li siguran da želiš obrisati ovu rundu?',
                                              ),
                                              actionsAlignment: MainAxisAlignment.spaceEvenly,
                                              actions: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () => Navigator.of(context).pop(false),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                                      foregroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      elevation: 0,
                                                    ),
                                                    child: const Text(
                                                      'Odustani',
                                                      style: TextStyle(fontSize: 18),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () => Navigator.of(context).pop(true),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Theme.of(context).colorScheme.secondary,
                                                      foregroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      elevation: 0,
                                                    ),
                                                    child: const Text(
                                                      'Obriši',
                                                      style: TextStyle(fontSize: 18),
                                                    ),
                                                  ),
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AddRoundButton(
                  text: gameEnded ? 'Nova igra' : 'Nova runda',
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    if (gameEnded) {
                      ref.read(currentGameProvider.notifier).clearRounds();
                      setState(() {
                        _gameSaved = false;
                      });
                    } else {
                      _addNewRound(
                        context,
                        teamOneName: settings.teamOneName,
                        teamTwoName: settings.teamTwoName,
                      );
                    }
                  },
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
