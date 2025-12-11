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

    Widget _nameCell(String label) {
      return Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: 'Nunito',
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
      );
    }

    Widget _scoreCell(int score) {
      return Expanded(
        child: Text(
          score.toString(),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontFamily: 'Nunito',
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [_nameCell(teamOneName), _nameCell(teamTwoName)]),
        const SizedBox(height: 6),
        Row(children: [_scoreCell(scoreTeamOne), _scoreCell(scoreTeamTwo)]),
      ],
    );
  }
}
