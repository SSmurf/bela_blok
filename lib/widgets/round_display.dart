import 'package:flutter/material.dart';
import '../models/round.dart';

class RoundDisplay extends StatelessWidget {
  final Round round;
  final int roundIndex;

  const RoundDisplay({super.key, required this.round, required this.roundIndex});

  int get totalTeamOne {
    return round.scoreTeamOne +
        round.decl20TeamOne * 20 +
        round.decl50TeamOne * 50 +
        round.decl100TeamOne * 100 +
        round.decl150TeamOne * 150 +
        round.decl200TeamOne * 200 +
        round.declStigljaTeamOne * 90;
  }

  int get totalTeamTwo {
    return round.scoreTeamTwo +
        round.decl20TeamTwo * 20 +
        round.decl50TeamTwo * 50 +
        round.decl100TeamTwo * 100 +
        round.decl150TeamTwo * 150 +
        round.decl200TeamTwo * 200 +
        round.declStigljaTeamTwo * 90;
  }

  @override
  Widget build(BuildContext context) {
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
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ),
          // Team One total score.
          Expanded(
            child: Text(
              totalTeamOne.toString(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          const Expanded(
            child: Text(
              '-',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ),
          // Team Two total score.
          Expanded(
            child: Text(
              totalTeamTwo.toString(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}
