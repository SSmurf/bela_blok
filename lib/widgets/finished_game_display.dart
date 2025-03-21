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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Team One Name (left-aligned)
          Expanded(
            child: Text(
              teamOneName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 32, fontWeight: FontWeight.w500),
              textAlign: TextAlign.start,
            ),
          ),
          // Team One Score
          Expanded(
            child: Text(
              // '$teamOneTotal',
              '1134',
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          // Dash Separator
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '-',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 24, fontWeight: FontWeight.w500),
            ),
          ),
          // Team Two Score
          Expanded(
            child: Text(
              '$teamTwoTotal',
              textAlign: TextAlign.start,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          // Team Two Name (right-aligned)
          Expanded(
            child: Text(
              teamTwoName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 32, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
