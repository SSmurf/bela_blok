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
    String? formattedDate;
    if (gameDate != null) {
      formattedDate =
          '${gameDate!.day.toString().padLeft(2, '0')}.${gameDate!.month.toString().padLeft(2, '0')}.${gameDate!.year}';
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          '$teamOneName $teamOneTotal  $teamTwoTotal $teamTwoName',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        subtitle: formattedDate != null ? Text('Datum: $formattedDate') : null,
        trailing:
            winningTeam != null
                ? Text('Pobjednik: $winningTeam', style: Theme.of(context).textTheme.bodyLarge)
                : null,
      ),
    );
  }
}
