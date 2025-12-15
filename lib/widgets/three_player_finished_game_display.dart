import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class ThreePlayerFinishedGameDisplay extends StatelessWidget {
  final String playerOneName;
  final int playerOneTotal;
  final String playerTwoName;
  final int playerTwoTotal;
  final String playerThreeName;
  final int playerThreeTotal;
  final DateTime? gameDate;
  final String? winningPlayer;
  final VoidCallback? onTap;

  const ThreePlayerFinishedGameDisplay({
    super.key,
    required this.playerOneName,
    required this.playerOneTotal,
    required this.playerTwoName,
    required this.playerTwoTotal,
    required this.playerThreeName,
    required this.playerThreeTotal,
    this.gameDate,
    this.winningPlayer,
    this.onTap,
  });

  String _formatDate(BuildContext context) {
    if (gameDate == null) return '';
    final locale = Localizations.localeOf(context).languageCode;
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
    final bool playerOneWins = winningPlayer == playerOneName;
    final bool playerTwoWins = winningPlayer == playerTwoName;
    final bool playerThreeWins = winningPlayer == playerThreeName;

    const double nameFontSize = 14;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            playerOneName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: nameFontSize,
              fontWeight: playerOneWins ? FontWeight.bold : FontWeight.w500,
              color: theme.colorScheme.onSurface,
              fontFamily: 'Nunito',
            ),
            textAlign: TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$playerOneTotal',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 20,
                  fontWeight: playerOneWins ? FontWeight.bold : FontWeight.w500,
                  fontFamily: 'Nunito',
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  '-',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 20,
                    color: theme.colorScheme.outline,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              Text(
                '$playerTwoTotal',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 20,
                  fontWeight: playerTwoWins ? FontWeight.bold : FontWeight.w500,
                  fontFamily: 'Nunito',
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  '-',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 20,
                    color: theme.colorScheme.outline,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              Text(
                '$playerThreeTotal',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 20,
                  fontWeight: playerThreeWins ? FontWeight.bold : FontWeight.w500,
                  fontFamily: 'Nunito',
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            playerThreeName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: nameFontSize,
              fontWeight: playerThreeWins ? FontWeight.bold : FontWeight.w500,
              color: theme.colorScheme.onSurface,
              fontFamily: 'Nunito',
            ),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    final theme = Theme.of(context);
    final bool playerOneWins = winningPlayer == playerOneName;
    final bool playerTwoWins = winningPlayer == playerTwoName;
    final bool playerThreeWins = winningPlayer == playerThreeName;

    return Column(
      children: [
        _buildPlayerRow(context, name: playerOneName, score: playerOneTotal, isWinner: playerOneWins, theme: theme),
        const SizedBox(height: 6),
        _buildPlayerRow(context, name: playerTwoName, score: playerTwoTotal, isWinner: playerTwoWins, theme: theme),
        const SizedBox(height: 6),
        _buildPlayerRow(context, name: playerThreeName, score: playerThreeTotal, isWinner: playerThreeWins, theme: theme),
      ],
    );
  }

  Widget _buildPlayerRow(
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
              fontSize: 18,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
              color: theme.colorScheme.onSurface,
              fontFamily: 'Nunito',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '$score',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 20,
            fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
            fontFamily: 'Nunito',
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
