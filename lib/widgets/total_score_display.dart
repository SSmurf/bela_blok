import 'package:flutter/material.dart';

class TotalScoreDisplay extends StatelessWidget {
  final int scoreTeamOne;
  final int scoreTeamTwo;
  final bool? isTeamOneSelected;
  final bool interactable;
  final VoidCallback? onTeamOneTap;
  final VoidCallback? onTeamTwoTap;

  const TotalScoreDisplay({
    super.key,
    required this.scoreTeamOne,
    required this.scoreTeamTwo,
    this.isTeamOneSelected,
    this.interactable = false,
    this.onTeamOneTap,
    this.onTeamTwoTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget teamWidget({
      required String label,
      required int score,
      required bool selected,
      required Color color,
      required VoidCallback? onTap,
    }) {
      // Always supply a background color to make entire area clickable.
      final BoxDecoration decoration = BoxDecoration(
        color: selected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
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
            Text(
              score.toString(),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: selected ? color : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

      if (interactable && onTap != null) {
        return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: content);
      }
      return content;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Team One ("Mi")
        Expanded(
          child: teamWidget(
            label: "Mi",
            score: scoreTeamOne,
            selected: isTeamOneSelected == true,
            color: theme.colorScheme.primary,
            onTap: onTeamOneTap,
          ),
        ),
        // Team Two ("Vi")
        Expanded(
          child: teamWidget(
            label: "Vi",
            score: scoreTeamTwo,
            selected: isTeamOneSelected == false,
            color: theme.colorScheme.secondary,
            onTap: onTeamTwoTap,
          ),
        ),
      ],
    );
  }
}
