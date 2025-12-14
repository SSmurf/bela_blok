import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class FinishedGameDisplay extends StatelessWidget {
  final String teamOneName;
  final int teamOneTotal;
  final int teamTwoTotal;
  final String teamTwoName;
  final DateTime? gameDate;
  final String? winningTeam;
  final VoidCallback? onTap;

  const FinishedGameDisplay({
    super.key,
    required this.teamOneName,
    required this.teamOneTotal,
    required this.teamTwoTotal,
    required this.teamTwoName,
    this.gameDate,
    this.winningTeam,
    this.onTap,
  });

  String _formatDate(BuildContext context) {
    if (gameDate == null) return '';
    final locale = Localizations.localeOf(context).languageCode;
    // Use a format that works well for history (Day, Month Year, Time)
    // Adjust format based on locale if needed, or use a standard one.
    // 'yMMMd' gives "Oct 24, 2025" or similar. 'Hm' gives "18:47".
    // Combined: "Oct 24, 2025 18:47"
    return DateFormat.yMMMd(locale).add_Hm().format(gameDate!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = _formatDate(context);
    final bool showFooter = formattedDate.isNotEmpty || onTap != null;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1), width: 1),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        hoverColor: theme.colorScheme.primary.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 360) {
                    return _buildVerticalLayout(context);
                  } else {
                    return _buildHorizontalLayout(context);
                  }
                },
              ),
              if (showFooter)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    children: [
                      if (formattedDate.isNotEmpty)
                        Expanded(
                          child: Text(
                            formattedDate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        const Spacer(),
                      if (formattedDate.isNotEmpty && onTap != null) const SizedBox(width: 8),
                      if (onTap != null)
                        Icon(
                          HugeIcons.strokeRoundedArrowRight01,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    final theme = Theme.of(context);
    final bool teamOneWins = winningTeam == teamOneName;
    final bool teamTwoWins = winningTeam == teamTwoName;

    const double nameFontSize = 18;

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            teamOneName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: nameFontSize,
              fontWeight: teamOneWins ? FontWeight.bold : FontWeight.w500,
              color: theme.colorScheme.onSurface,
              fontFamily: 'Nunito',
            ),
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$teamOneTotal',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: teamOneWins ? FontWeight.bold : FontWeight.w500,
                  fontFamily: 'Nunito',
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  '-',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              Text(
                '$teamTwoTotal',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: teamTwoWins ? FontWeight.bold : FontWeight.w500,
                  fontFamily: 'Nunito',
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            teamTwoName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: nameFontSize,
              fontWeight: teamTwoWins ? FontWeight.bold : FontWeight.w500,
              color: theme.colorScheme.onSurface,
              fontFamily: 'Nunito',
            ),
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    final theme = Theme.of(context);
    final bool teamOneWins = winningTeam == teamOneName;
    final bool teamTwoWins = winningTeam == teamTwoName;

    return Column(
      children: [
        _buildTeamRow(context, name: teamOneName, score: teamOneTotal, isWinner: teamOneWins, theme: theme),
        const SizedBox(height: 8),
        _buildTeamRow(context, name: teamTwoName, score: teamTwoTotal, isWinner: teamTwoWins, theme: theme),
      ],
    );
  }

  Widget _buildTeamRow(
    BuildContext context, {
    required String name,
    required int score,
    required bool isWinner,
    required ThemeData theme,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 24,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
              color: theme.colorScheme.onSurface,
              fontFamily: 'Nunito',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '$score',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 24,
            fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
            fontFamily: 'Nunito',
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
