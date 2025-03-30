import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class NumericKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onDelete;
  final VoidCallback onClear;

  const NumericKeyboard({
    super.key,
    required this.onKeyPressed,
    required this.onDelete,
    required this.onClear,
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

  // Widget _buildKeyButton(String text, Function(String) onPressed, ThemeData theme) {
  //   return Expanded(
  //     child: ElevatedButton(
  //       onPressed: () => onPressed(text),
  //       style: ButtonStyle(
  //         backgroundColor: WidgetStateProperty.all(theme.colorScheme.surface),
  //         foregroundColor: WidgetStateProperty.all(theme.colorScheme.onSurface),
  //         elevation: WidgetStateProperty.all(0),
  //         overlayColor: WidgetStateProperty.all(theme.colorScheme.primary.withValues(alpha: 0.5)),
  //         // padding: WidgetStateProperty.all(EdgeInsets.zero),
  //         shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
  //       ),
  //       child: Center(child: Text(text, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold))),
  //     ),
  //   );
  // }

  Widget _buildKeyButton(String text, Function(String) onPressed, ThemeData theme) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          onPressed: () => onPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            overlayColor: theme.colorScheme.primary.withValues(alpha: 0.5),
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
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(reverseIcon ? 3.14159 : 0),
              child: Icon(icon, size: 40),
            ),
          ),
        ),
      ),
    );
  }
}
