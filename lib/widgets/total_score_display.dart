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
          child: Text(scoreTeamOne.toString(), style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
        ),
        Expanded(child: Icon(Icons.horizontal_rule, size: 24)),
        Expanded(
          child: Text(scoreTeamTwo.toString(), style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
