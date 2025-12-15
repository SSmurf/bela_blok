import 'package:bela_blok/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/three_player_round.dart';

class ThreePlayerRoundDisplay extends ConsumerWidget {
  final ThreePlayerRound round;
  final int roundIndex;

  const ThreePlayerRoundDisplay({super.key, required this.round, required this.roundIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int stigljaValue = ref.watch(settingsProvider).stigljaValue;

    // Calculate totals for each player including declarations
    int playerOneTotal = _computePlayerTotal(round, 0, stigljaValue);
    int playerTwoTotal = _computePlayerTotal(round, 1, stigljaValue);
    int playerThreeTotal = _computePlayerTotal(round, 2, stigljaValue);

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
          const Text(
            '-',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, fontFamily: 'Nunito'),
          ),
          // Player Two total score
          Expanded(
            child: Text(
              playerTwoTotal.toString(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
              textAlign: TextAlign.center,
            ),
          ),
          const Text(
            '-',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, fontFamily: 'Nunito'),
          ),
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

  int _computePlayerTotal(ThreePlayerRound round, int playerIndex, int stigljaValue) {
    int baseScore;
    int declarations;

    if (playerIndex == 0) {
      baseScore = round.scorePlayerOne;
      if (round.declStigljaPlayerOne > 0) {
        // Player one has stiglja - gets all declarations
        declarations = (round.decl20PlayerOne + round.decl20PlayerTwo + round.decl20PlayerThree) * 20 +
            (round.decl50PlayerOne + round.decl50PlayerTwo + round.decl50PlayerThree) * 50 +
            (round.decl100PlayerOne + round.decl100PlayerTwo + round.decl100PlayerThree) * 100 +
            (round.decl150PlayerOne + round.decl150PlayerTwo + round.decl150PlayerThree) * 150 +
            (round.decl200PlayerOne + round.decl200PlayerTwo + round.decl200PlayerThree) * 200 +
            (round.declStigljaPlayerOne * stigljaValue);
      } else if (round.declStigljaPlayerTwo > 0 || round.declStigljaPlayerThree > 0) {
        // Another player has stiglja - player one gets no declarations
        declarations = 0;
      } else {
        declarations = round.decl20PlayerOne * 20 +
            round.decl50PlayerOne * 50 +
            round.decl100PlayerOne * 100 +
            round.decl150PlayerOne * 150 +
            round.decl200PlayerOne * 200;
      }
    } else if (playerIndex == 1) {
      baseScore = round.scorePlayerTwo;
      if (round.declStigljaPlayerTwo > 0) {
        declarations = (round.decl20PlayerOne + round.decl20PlayerTwo + round.decl20PlayerThree) * 20 +
            (round.decl50PlayerOne + round.decl50PlayerTwo + round.decl50PlayerThree) * 50 +
            (round.decl100PlayerOne + round.decl100PlayerTwo + round.decl100PlayerThree) * 100 +
            (round.decl150PlayerOne + round.decl150PlayerTwo + round.decl150PlayerThree) * 150 +
            (round.decl200PlayerOne + round.decl200PlayerTwo + round.decl200PlayerThree) * 200 +
            (round.declStigljaPlayerTwo * stigljaValue);
      } else if (round.declStigljaPlayerOne > 0 || round.declStigljaPlayerThree > 0) {
        declarations = 0;
      } else {
        declarations = round.decl20PlayerTwo * 20 +
            round.decl50PlayerTwo * 50 +
            round.decl100PlayerTwo * 100 +
            round.decl150PlayerTwo * 150 +
            round.decl200PlayerTwo * 200;
      }
    } else {
      baseScore = round.scorePlayerThree;
      if (round.declStigljaPlayerThree > 0) {
        declarations = (round.decl20PlayerOne + round.decl20PlayerTwo + round.decl20PlayerThree) * 20 +
            (round.decl50PlayerOne + round.decl50PlayerTwo + round.decl50PlayerThree) * 50 +
            (round.decl100PlayerOne + round.decl100PlayerTwo + round.decl100PlayerThree) * 100 +
            (round.decl150PlayerOne + round.decl150PlayerTwo + round.decl150PlayerThree) * 150 +
            (round.decl200PlayerOne + round.decl200PlayerTwo + round.decl200PlayerThree) * 200 +
            (round.declStigljaPlayerThree * stigljaValue);
      } else if (round.declStigljaPlayerOne > 0 || round.declStigljaPlayerTwo > 0) {
        declarations = 0;
      } else {
        declarations = round.decl20PlayerThree * 20 +
            round.decl50PlayerThree * 50 +
            round.decl100PlayerThree * 100 +
            round.decl150PlayerThree * 150 +
            round.decl200PlayerThree * 200;
      }
    }

    return baseScore + declarations;
  }
}
