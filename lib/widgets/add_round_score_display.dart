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
        color: selected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      );

      final Widget scoreWidget = Row(
        mainAxisSize: MainAxisSize.min,
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
            Text(
              " + $declScore",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.normal,
                color: selected ? color : theme.colorScheme.onSurface,
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
