import 'package:flutter/material.dart';

class TotalScoreDisplay extends StatelessWidget {
  final int score;

  const TotalScoreDisplay({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      color: Theme.of(context).colorScheme.primary,
      surfaceTintColor: Theme.of(context).colorScheme.secondary,
      
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(score.toString(), style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
