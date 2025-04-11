import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

class NumericKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final bool keysEnabled;

  const NumericKeyboard({
    super.key,
    required this.onKeyPressed,
    required this.onDelete,
    required this.onClear,
    this.keysEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildKeyButton('1', onKeyPressed, theme),
              _buildKeyButton('2', onKeyPressed, theme),
              _buildKeyButton('3', onKeyPressed, theme),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildKeyButton('4', onKeyPressed, theme),
              _buildKeyButton('5', onKeyPressed, theme),
              _buildKeyButton('6', onKeyPressed, theme),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildKeyButton('7', onKeyPressed, theme),
              _buildKeyButton('8', onKeyPressed, theme),
              _buildKeyButton('9', onKeyPressed, theme),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildActionButton(onClear, theme, HugeIcons.strokeRoundedDelete02, false),
              _buildKeyButton('0', onKeyPressed, theme),
              _buildActionButton(onDelete, theme, HugeIcons.strokeRoundedEraser01, true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyButton(String text, Function(String) onPressed, ThemeData theme) {
    final bool enabled = keysEnabled;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          onPressed:
              enabled
                  ? () {
                    if (Platform.isIOS) {
                      SystemSound.play(SystemSoundType.click);
                    }
                    onPressed(text);
                  }
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            disabledBackgroundColor: theme.colorScheme.surface.withValues(alpha: 0.5),
            disabledForegroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            overlayColor: theme.colorScheme.primary,
            padding: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Center(child: Text(text, style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w600))),
        ),
      ),
    );
  }

  Widget _buildActionButton(VoidCallback onPressed, ThemeData theme, IconData icon, bool reverseIcon) {
    final bool enabled = keysEnabled;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed:
              enabled
                  ? () {
                    if (Platform.isIOS) {
                      SystemSound.play(SystemSoundType.click);
                    }
                    onPressed();
                  }
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            disabledBackgroundColor: theme.colorScheme.surface.withValues(alpha: 0.5),
            disabledForegroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            overlayColor: theme.colorScheme.primary,
            padding: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(reverseIcon ? 3.14159 : 0),
              child: Icon(
                icon,
                size: 40,
                color:
                    enabled
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
