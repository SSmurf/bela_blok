import 'package:flutter/material.dart';

class FinishedGameDisplay extends StatelessWidget {
  final String teamOneName;
  final int teamOneTotal;
  final int teamTwoTotal;
  final String teamTwoName;
  final DateTime? gameDate;
  final String? winningTeam;

  const FinishedGameDisplay({
    super.key,
    required this.teamOneName,
    required this.teamOneTotal,
    required this.teamTwoTotal,
    required this.teamTwoName,
    this.gameDate,
    this.winningTeam,
  });

  @override
  Widget build(BuildContext context) {
    double getFontSizeForTeamName(String name) {
      if (name.length <= 4) return 30.0;
      if (name.length <= 8) return 24.0;
      if (name.length <= 12) return 20.0;
      return 18.0;
    }

    final double teamOneFontSize = getFontSizeForTeamName(teamOneName);
    final double teamTwoFontSize = getFontSizeForTeamName(teamTwoName);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              teamOneName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: teamOneFontSize,
                fontWeight: FontWeight.w500,
                fontFamily: 'Nunito',
                height: 1.0,
              ),
              textAlign: TextAlign.start,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$teamOneTotal',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '-',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$teamTwoTotal',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              teamTwoName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: teamTwoFontSize,
                fontWeight: FontWeight.w500,
                fontFamily: 'Nunito',
                height: 1.0,
              ),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
