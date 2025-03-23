import 'package:flutter/material.dart';

class TotalScoreDisplay extends StatelessWidget {
  final int scoreTeamOne;
  final int scoreTeamTwo;
  final String teamOneName;
  final String teamTwoName;

  const TotalScoreDisplay({
    super.key,
    required this.scoreTeamOne,
    required this.scoreTeamTwo,
    this.teamOneName = 'Mi',
    this.teamTwoName = 'Vi',
  });

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
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
        Expanded(child: teamWidget(label: teamOneName, score: scoreTeamOne)),
        Expanded(child: teamWidget(label: teamTwoName, score: scoreTeamTwo)),
      ],
    );
  }
}
