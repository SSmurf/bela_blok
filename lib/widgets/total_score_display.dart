import 'package:flutter/material.dart';

class TotalScoreDisplay extends StatelessWidget {
  final int scoreTeamOne;
  final int scoreTeamTwo;

  const TotalScoreDisplay({super.key, required this.scoreTeamOne, required this.scoreTeamTwo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Center(child: Text("Mi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
            ),
            const SizedBox(width: 12.1),
            Expanded(
              child: Center(child: Text("Vi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  scoreTeamOne.toString(),
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Center(child: const Text(":", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold))),
            Expanded(
              child: Center(
                child: Text(
                  scoreTeamTwo.toString(),
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
