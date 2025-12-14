import 'package:flutter/material.dart';

class LandscapeTotalScoreDisplay extends StatelessWidget {
  final int scoreTeamOne;
  final int scoreTeamTwo;
  final String teamOneName;
  final String teamTwoName;
  final int teamOneWins;
  final int teamTwoWins;

  const LandscapeTotalScoreDisplay({
    super.key,
    required this.scoreTeamOne,
    required this.scoreTeamTwo,
    this.teamOneName = 'Mi',
    this.teamTwoName = 'Vi',
    this.teamOneWins = 0,
    this.teamTwoWins = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final double labelFontSize = screenWidth <= 640 ? 36 : 48;
    final double scoreFontSize = screenWidth <= 640 ? 96 : 96;

    Widget teamWidget({required String label, required int score, required bool primary, required int wins}) {
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Text(
                    wins.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nunito',
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
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
                ],
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
        Expanded(child: teamWidget(label: teamOneName, score: scoreTeamOne, primary: true, wins: teamOneWins)),
        const SizedBox(width: 16),
        Expanded(child: teamWidget(label: teamTwoName, score: scoreTeamTwo, primary: false, wins: teamTwoWins)),
      ],
    );
  }
}
