import 'package:bela_blok/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/three_player_round.dart';
import '../utils/three_player_score_utils.dart';

class ThreePlayerRoundDisplay extends ConsumerWidget {
  final ThreePlayerRound round;
  final int roundIndex;

  const ThreePlayerRoundDisplay({super.key, required this.round, required this.roundIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int stigljaValue = ref.watch(settingsProvider).stigljaValue;

    // Calculate totals for each player including declarations
    int playerOneTotal = computeThreePlayerRoundTotal(round, 0, stigljaValue);
    int playerTwoTotal = computeThreePlayerRoundTotal(round, 1, stigljaValue);
    int playerThreeTotal = computeThreePlayerRoundTotal(round, 2, stigljaValue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Round number
          SizedBox(
            width: 32,
            child: Text(
              '${roundIndex + 1}.',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Nunito'),
            ),
          ),
          // Player One total score
          Expanded(
            child: Text(
              playerOneTotal.toString(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
              textAlign: TextAlign.center,
            ),
          ),
          const Text('-', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, fontFamily: 'Nunito')),
          // Player Two total score
          Expanded(
            child: Text(
              playerTwoTotal.toString(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
              textAlign: TextAlign.center,
            ),
          ),
          const Text('-', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, fontFamily: 'Nunito')),
          // Player Three total score
          Expanded(
            child: Text(
              playerThreeTotal.toString(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
