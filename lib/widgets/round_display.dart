import 'package:bela_blok/providers/settings_provider.dart';
import 'package:bela_blok/services/score_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/round.dart';

class RoundDisplay extends ConsumerWidget {
  final Round round;
  final int roundIndex;

  const RoundDisplay({super.key, required this.round, required this.roundIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int stigljaValue = ref.watch(settingsProvider).stigljaValue;
    int teamOneTotal = ScoreCalculator(stigljaValue: stigljaValue).computeTeamOneRoundTotal(round);
    int teamTwoTotal = ScoreCalculator(stigljaValue: stigljaValue).computeTeamTwoRoundTotal(round);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Round number.
          SizedBox(
            width: 32,
            child: Text(
              '${roundIndex + 1}.',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Nunito'),
            ),
          ),
          // Team One total score.
          Expanded(
            child: Text(
              teamOneTotal.toString(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
              textAlign: TextAlign.center,
            ),
          ),
          const Expanded(
            child: Text(
              '-',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, fontFamily: 'Nunito'),
              textAlign: TextAlign.center,
            ),
          ),
          // Team Two total score.
          Expanded(
            child: Text(
              teamTwoTotal.toString(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}
