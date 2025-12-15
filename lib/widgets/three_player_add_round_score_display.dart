import 'package:flutter/material.dart';

class ThreePlayerAddRoundScoreDisplay extends StatelessWidget {
  final int scorePlayerOne;
  final int scorePlayerTwo;
  final int scorePlayerThree;
  final int declarationScorePlayerOne;
  final int declarationScorePlayerTwo;
  final int declarationScorePlayerThree;
  final int selectedPlayerIndex; // 0, 1, or 2
  final VoidCallback? onPlayerOneTap;
  final VoidCallback? onPlayerTwoTap;
  final VoidCallback? onPlayerThreeTap;
  final String playerOneName;
  final String playerTwoName;
  final String playerThreeName;

  const ThreePlayerAddRoundScoreDisplay({
    super.key,
    required this.scorePlayerOne,
    required this.scorePlayerTwo,
    required this.scorePlayerThree,
    this.declarationScorePlayerOne = 0,
    this.declarationScorePlayerTwo = 0,
    this.declarationScorePlayerThree = 0,
    required this.selectedPlayerIndex,
    this.onPlayerOneTap,
    this.onPlayerTwoTap,
    this.onPlayerThreeTap,
    required this.playerOneName,
    required this.playerTwoName,
    required this.playerThreeName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget playerWidget({
      required String label,
      required int score,
      required int declScore,
      required bool selected,
      required Color color,
      required VoidCallback? onTap,
    }) {
      final BoxDecoration decoration = BoxDecoration(
        color: selected ? color.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      );

      double determineDeclarationFontSize() {
        final scoreDigits = score.toString().length;
        final declDigits = declScore.toString().length;
        if (scoreDigits >= 3 && declDigits >= 3) {
          return 14.0;
        } else if (scoreDigits + declDigits >= 5) {
          return 16.0;
        }
        return 18.0;
      }

      final Widget scoreWidget = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score.toString(),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
              color: selected ? color : theme.colorScheme.onSurface,
            ),
          ),
          if (declScore > 0)
            Flexible(
              child: Text(
                "+$declScore",
                style: TextStyle(
                  fontSize: determineDeclarationFontSize(),
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Nunito',
                  color: selected ? color : theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      );

      final Widget content = Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: decoration,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito',
                  color: selected ? color : theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            scoreWidget,
          ],
        ),
      );

      if (onTap != null) {
        return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: content);
      }
      return content;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: playerWidget(
            label: playerOneName,
            score: scorePlayerOne,
            declScore: declarationScorePlayerOne,
            selected: selectedPlayerIndex == 0,
            color: theme.colorScheme.primary,
            onTap: onPlayerOneTap,
          ),
        ),
        Expanded(
          child: playerWidget(
            label: playerTwoName,
            score: scorePlayerTwo,
            declScore: declarationScorePlayerTwo,
            selected: selectedPlayerIndex == 1,
            color: theme.colorScheme.secondary,
            onTap: onPlayerTwoTap,
          ),
        ),
        Expanded(
          child: playerWidget(
            label: playerThreeName,
            score: scorePlayerThree,
            declScore: declarationScorePlayerThree,
            selected: selectedPlayerIndex == 2,
            color: theme.colorScheme.tertiary,
            onTap: onPlayerThreeTap,
          ),
        ),
      ],
    );
  }
}

