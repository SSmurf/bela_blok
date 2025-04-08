import 'package:flutter/material.dart';

class LandscapeTotalScoreDisplay extends StatelessWidget {
  final int scoreTeamOne;
  final int scoreTeamTwo;
  final String teamOneName;
  final String teamTwoName;

  const LandscapeTotalScoreDisplay({
    super.key,
    required this.scoreTeamOne,
    required this.scoreTeamTwo,
    this.teamOneName = 'Mi',
    this.teamTwoName = 'Vi',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final double labelFontSize = screenWidth <= 640 ? 36 : 48;
    final double scoreFontSize = screenWidth <= 640 ? 96 : 96;

    Widget teamWidget({required String label, required int score, required bool primary}) {
      final BoxDecoration decoration = BoxDecoration(
        color:
            primary
                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                : theme.colorScheme.secondary.withValues(alpha: 0.5),
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
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito',
                  color: theme.colorScheme.onSurface,
                  overflow: TextOverflow.ellipsis,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              score.toString(),
              style: TextStyle(
                fontSize: scoreFontSize,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                fontFamily: 'Nunito',
                overflow: TextOverflow.ellipsis,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
      return content;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: teamWidget(label: teamOneName, score: scoreTeamOne, primary: true)),
        const SizedBox(width: 16),
        Expanded(child: teamWidget(label: teamTwoName, score: scoreTeamTwo, primary: false)),
      ],
    );
  }
}
