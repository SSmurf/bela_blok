import 'package:bela_blok/models/round.dart';
import 'package:bela_blok/providers/game_provider.dart';
import 'package:bela_blok/widgets/round_display.dart';
import 'package:bela_blok/widgets/total_score_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../widgets/add_round_button.dart';
import 'round_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rounds = ref.watch(currentGameProvider);
    final gameNotifier = ref.read(currentGameProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.settings_outlined), iconSize: 32, onPressed: () {}),
        actions: [
          IconButton(
            icon: const Icon(Symbols.clear),
            iconSize: 32,
            onPressed: rounds.isNotEmpty ? () => _confirmClearGame(context, ref) : null,
          ),
          IconButton(icon: const Icon(Symbols.history), iconSize: 32, onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        child: Column(
          children: [
            TotalScoreDisplay(
              scoreTeamOne: gameNotifier.teamOneTotal,
              scoreTeamTwo: gameNotifier.teamTwoTotal,
            ),
            const SizedBox(height: 6),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider()),
            const SizedBox(height: 12),
            Expanded(
              child:
                  rounds.isEmpty
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
                                key: ValueKey(
                                  'round_${rounds[index].hashCode}',
                                ), // Use unique key based on object
                                background: Container(
                                  color: Colors.red.withOpacity(0.7),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (_) async {
                                  // Show confirmation dialog
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
                                  // This is now safe because we confirmed the dismissal
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
                  text: 'Nova runda',
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () => _addNewRound(context),
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
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RoundScreen()));
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
