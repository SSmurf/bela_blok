import 'package:bela_blok/models/round.dart';
import 'package:bela_blok/providers/game_provider.dart';
import 'package:bela_blok/widgets/round_display.dart';
import 'package:bela_blok/widgets/total_score_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../widgets/add_round_button.dart';
import 'round_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rounds = ref.watch(currentGameProvider);
    final gameNotifier = ref.read(currentGameProvider.notifier);

    // Determine the total scores.
    final int teamOneTotal = gameNotifier.teamOneTotal;
    final int teamTwoTotal = gameNotifier.teamTwoTotal;
    // The game ends when one team's score is at least 1.001.
    final bool gameEnded = teamOneTotal >= 1001 || teamTwoTotal >= 1001;
    // Determine the winning team.
    final String winningTeam =
        teamOneTotal >= 1001
            ? 'Mi'
            : teamTwoTotal >= 1001
            ? 'Vi'
            : '';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(HugeIcons.strokeRoundedSettings02),
          iconSize: 32,
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedCancel01),
            iconSize: 32,
            onPressed: rounds.isNotEmpty && !gameEnded ? () => _confirmClearGame(context, ref) : null,
          ),
          IconButton(icon: const Icon(HugeIcons.strokeRoundedClock02), iconSize: 32, onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        child: Column(
          children: [
            TotalScoreDisplay(scoreTeamOne: teamOneTotal, scoreTeamTwo: teamTwoTotal),
            const SizedBox(height: 6),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider()),
            const SizedBox(height: 12),
            Expanded(
              child:
                  gameEnded
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  HugeIcons.strokeRoundedLaurelWreathLeft02,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                Text(
                                  winningTeam,
                                  style: TextStyle(fontSize: 56, fontWeight: FontWeight.w500),
                                ),
                                Icon(
                                  HugeIcons.strokeRoundedLaurelWreathRight02,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Undo last round button.
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
                                          ),
                                    ),
                                  );
                                },
                                icon: const Icon(HugeIcons.strokeRoundedUndo),
                                label: const Text('Poništi zadnju rundu'),
                              ),
                          ],
                        ),
                      )
                      : rounds.isEmpty
                      ? Center(
                        child: Text(
                          'Još nema rundi. Dodaj novu rundu!',
                          style: Theme.of(context).textTheme.bodyLarge,
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
                                  return await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text('Brisanje runde'),
                                              content: const Text(
                                                'Jesi li siguran da želiš obrisati ovu rundu?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('Odustani'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text('Obriši'),
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
                                  onTap: () => _editRound(context, ref, rounds[index], index),
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
                    } else {
                      _addNewRound(context);
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

  void _addNewRound(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const RoundScreen(isTeamOneSelected: true)));
  }

  void _editRound(BuildContext context, WidgetRef ref, Round round, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RoundScreen(roundToEdit: round, roundIndex: index, isTeamOneSelected: true),
      ),
    );
  }

  void _confirmClearGame(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Brisanje igre'),
            content: const Text('Jesi li siguran da želiš obrisati sve runde?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Odustani')),
              TextButton(
                onPressed: () {
                  ref.read(currentGameProvider.notifier).clearRounds();
                  Navigator.of(context).pop();
                },
                child: const Text('Obriši'),
              ),
            ],
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
