import 'package:flutter/material.dart';

import '../utils/player_name_utils.dart';

class ThreePlayerTotalScoreDisplay extends StatelessWidget {
  final int scorePlayerOne;
  final int scorePlayerTwo;
  final int scorePlayerThree;
  final String playerOneName;
  final String playerTwoName;
  final String playerThreeName;
  final int playerOneWins;
  final int playerTwoWins;
  final int playerThreeWins;
  final int goalScore;

  const ThreePlayerTotalScoreDisplay({
    super.key,
    required this.scorePlayerOne,
    required this.scorePlayerTwo,
    required this.scorePlayerThree,
    required this.playerOneName,
    required this.playerTwoName,
    required this.playerThreeName,
    this.playerOneWins = 0,
    this.playerTwoWins = 0,
    this.playerThreeWins = 0,
    this.goalScore = 1001,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPlayerScore(context, name: playerOneName, score: scorePlayerOne, wins: playerOneWins),
        ),
        Expanded(
          child: _buildPlayerScore(context, name: playerTwoName, score: scorePlayerTwo, wins: playerTwoWins),
        ),
        Expanded(
          child: _buildPlayerScore(
            context,
            name: playerThreeName,
            score: scorePlayerThree,
            wins: playerThreeWins,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerScore(
    BuildContext context, {
    required String name,
    required int score,
    required int wins,
  }) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 375;
    final scoreFontSize = isSmallScreen ? 36.0 : 44.0;
    final nameFontSize = isSmallScreen ? 14.0 : 16.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Wins displayed ABOVE the name
        SizedBox(
          height: 24,
          child:
              wins > 0
                  ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$wins',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Nunito',
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  )
                  : null,
        ),
        const SizedBox(height: 4),
        Text(
          name.truncatedForThreePlayers,
          style: TextStyle(
            fontSize: nameFontSize,
            fontWeight: FontWeight.w600,
            fontFamily: 'Nunito',
            color: theme.colorScheme.onSurface,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 4),
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: scoreFontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
