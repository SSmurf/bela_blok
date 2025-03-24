import 'package:flutter/material.dart';

class AddRoundScoreDisplay extends StatelessWidget {
  final int scoreTeamOne;
  final int scoreTeamTwo;
  final int declarationScoreTeamOne;
  final int declarationScoreTeamTwo;
  final bool? isTeamOneSelected;
  final VoidCallback? onTeamOneTap;
  final VoidCallback? onTeamTwoTap;
  final String teamOneName;
  final String teamTwoName;

  const AddRoundScoreDisplay({
    super.key,
    required this.scoreTeamOne,
    required this.scoreTeamTwo,
    this.declarationScoreTeamOne = 0,
    this.declarationScoreTeamTwo = 0,
    this.isTeamOneSelected,
    this.onTeamOneTap,
    this.onTeamTwoTap,
    required this.teamOneName,
    required this.teamTwoName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget teamWidget({
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
          return 20.0;
        } else if (scoreDigits + declDigits >= 5) {
          return 24.0;
        }
        return 28.0;
      }

      final Widget scoreWidget = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score.toString(),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: selected ? color : theme.colorScheme.onSurface,
            ),
          ),
          if (declScore > 0)
            Flexible(
              child: Text(
                " + $declScore",
                style: TextStyle(
                  fontSize: determineDeclarationFontSize(),
                  fontWeight: FontWeight.normal,
                  color: selected ? color : theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      );

      final Widget content = Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: decoration,
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: selected ? color : theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
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
          child: teamWidget(
            label: teamOneName,
            score: scoreTeamOne,
            declScore: declarationScoreTeamOne,
            selected: isTeamOneSelected == true,
            color: theme.colorScheme.primary,
            onTap: onTeamOneTap,
          ),
        ),
        Expanded(
          child: teamWidget(
            label: teamTwoName,
            score: scoreTeamTwo,
            declScore: declarationScoreTeamTwo,
            selected: isTeamOneSelected == false,
            color: theme.colorScheme.secondary,
            onTap: onTeamTwoTap,
          ),
        ),
      ],
    );
  }
}
