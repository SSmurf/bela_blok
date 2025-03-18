import 'package:flutter/material.dart';

class TotalScoreDisplay extends StatelessWidget {
  final int scoreTeamOne;
  final int scoreTeamTwo;

  const TotalScoreDisplay({super.key, required this.scoreTeamOne, required this.scoreTeamTwo});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Center(
            child: Text(scoreTeamOne.toString(), style: TextStyle(fontSize: 48), textAlign: TextAlign.center),
          ),
        ),
        Center(child: const Text(":", style: TextStyle(fontSize: 40))),
        Expanded(
          child: Center(
            child: Text(scoreTeamTwo.toString(), style: TextStyle(fontSize: 48), textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }
}
