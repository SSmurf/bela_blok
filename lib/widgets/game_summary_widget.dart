import 'package:bela_blok/models/round.dart';
import 'package:bela_blok/utils/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class GameSummaryWidget extends StatelessWidget {
  final String teamOneName;
  final String teamTwoName;
  final String? winningTeam;
  final List<Round> rounds;

  const GameSummaryWidget({
    super.key,
    required this.teamOneName,
    required this.teamTwoName,
    this.winningTeam,
    required this.rounds,
  });

  int _calculateTotalPoints(List<Round> rounds, {required bool teamOne}) {
    return rounds.fold(0, (sum, round) {
      return sum + (teamOne ? round.scoreTeamOne : round.scoreTeamTwo);
    });
  }

  int _calculateTotalDeclarations(List<Round> rounds, {required bool teamOne}) {
    return rounds.fold(0, (sum, round) {
      if (round.declStigljaTeamOne > 0 && teamOne) {
        return sum +
            round.decl20TeamOne * 20 +
            round.decl50TeamOne * 50 +
            round.decl100TeamOne * 100 +
            round.decl150TeamOne * 150 +
            round.decl200TeamOne * 200 +
            round.decl20TeamTwo * 20 +
            round.decl50TeamTwo * 50 +
            round.decl100TeamTwo * 100 +
            round.decl150TeamTwo * 150 +
            round.decl200TeamTwo * 200;
      } else if (round.declStigljaTeamTwo > 0 && !teamOne) {
        return sum +
            round.decl20TeamOne * 20 +
            round.decl50TeamOne * 50 +
            round.decl100TeamOne * 100 +
            round.decl150TeamOne * 150 +
            round.decl200TeamOne * 200 +
            round.decl20TeamTwo * 20 +
            round.decl50TeamTwo * 50 +
            round.decl100TeamTwo * 100 +
            round.decl150TeamTwo * 150 +
            round.decl200TeamTwo * 200;
      } else if (round.declStigljaTeamOne > 0 && !teamOne) {
        return sum;
      } else if (round.declStigljaTeamTwo > 0 && teamOne) {
        return sum;
      } else if (teamOne) {
        return sum +
            round.decl20TeamOne * 20 +
            round.decl50TeamOne * 50 +
            round.decl100TeamOne * 100 +
            round.decl150TeamOne * 150 +
            round.decl200TeamOne * 200;
      } else {
        return sum +
            round.decl20TeamTwo * 20 +
            round.decl50TeamTwo * 50 +
            round.decl100TeamTwo * 100 +
            round.decl150TeamTwo * 150 +
            round.decl200TeamTwo * 200;
      }
    });
  }

  int _countTotalStiglja(List<Round> rounds, {required bool teamOne}) {
    return rounds.fold(0, (sum, round) {
      return sum + (teamOne ? round.declStigljaTeamOne : round.declStigljaTeamTwo);
    });
  }

  Widget _buildStatRow({
    required BuildContext context,
    required String label,
    required int teamOneValue,
    required int teamTwoValue,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            teamOneValue.toString(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'Nunito'),
          ),
        ),
        Expanded(
          child: Text(
            teamTwoValue.toString(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (winningTeam != null && winningTeam!.isNotEmpty) ...[
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final double fontSize =
                  winningTeam!.length <= 4
                      ? 56
                      : winningTeam!.length <= 8
                      ? 44
                      : winningTeam!.length <= 12
                      ? 36
                      : 28;
              final double iconSize = fontSize + 8;

              if (winningTeam == 'Remi') {
                return SizedBox(
                  width: constraints.maxWidth * 0.9,
                  child: Text(
                    winningTeam!,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Nunito',
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }

              return SizedBox(
                width: constraints.maxWidth * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      HugeIcons.strokeRoundedLaurelWreathLeft02,
                      size: iconSize,
                      color: theme.colorScheme.tertiary,
                    ),
                    Flexible(
                      child: Text(
                        winningTeam!,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Nunito',
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      HugeIcons.strokeRoundedLaurelWreathRight02,
                      size: iconSize,
                      color: theme.colorScheme.tertiary,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ] else ...[
          const SizedBox(height: 24),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              _buildStatRow(
                context: context,
                label: loc.translate('points'),
                teamOneValue: _calculateTotalPoints(rounds, teamOne: true),
                teamTwoValue: _calculateTotalPoints(rounds, teamOne: false),
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: theme.colorScheme.onSurface.withOpacity(0.4)),
              const SizedBox(height: 12),
              _buildStatRow(
                context: context,
                label: loc.translate('totalDeclarations'),
                teamOneValue: _calculateTotalDeclarations(rounds, teamOne: true),
                teamTwoValue: _calculateTotalDeclarations(rounds, teamOne: false),
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: theme.colorScheme.onSurface.withOpacity(0.4)),
              const SizedBox(height: 12),
              _buildStatRow(
                context: context,
                label: loc.translate('totalStiglja'),
                teamOneValue: _countTotalStiglja(rounds, teamOne: true),
                teamTwoValue: _countTotalStiglja(rounds, teamOne: false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
