import 'package:flutter/material.dart';

class TotalScoreDisplay extends StatelessWidget {
  final int scoreTeamOne;
  final int scoreTeamTwo;
  const TotalScoreDisplay({super.key, required this.scoreTeamOne, required this.scoreTeamTwo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget teamWidget({required String label, required int score}) {
      final BoxDecoration decoration = BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      );

      final Widget content = Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: decoration,
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              score.toString(),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
      return content;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(child: teamWidget(label: "Mi", score: scoreTeamOne)),
        Expanded(child: teamWidget(label: "Vi", score: scoreTeamTwo)),
      ],
    );
  }
}
