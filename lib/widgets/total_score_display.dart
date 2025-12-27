import 'package:flutter/material.dart';

class TotalScoreDisplay extends StatelessWidget {
  final int scoreTeamOne;
  final int scoreTeamTwo;
  final String teamOneName;
  final String teamTwoName;
  final int teamOneWins;
  final int teamTwoWins;

  const TotalScoreDisplay({
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
    final showWins = teamOneWins > 0 || teamTwoWins > 0;

    Widget _winCell(int wins) {
      return Expanded(
        child: Text(
          wins.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Nunito',
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

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
        if (showWins) ...[
          Row(children: [_winCell(teamOneWins), _winCell(teamTwoWins)]),
          const SizedBox(height: 2),
        ],
        Row(children: [_nameCell(teamOneName), _nameCell(teamTwoName)]),
        const SizedBox(height: 6),
        Row(children: [_scoreCell(scoreTeamOne), _scoreCell(scoreTeamTwo)]),
      ],
    );
  }
}
