import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SaveRoundButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final Color color;
  final bool isEnabled;
  final double width;
  final bool fullWidth;

  const SaveRoundButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    this.isEnabled = true,
    this.onLongPress,
    this.width = 250.0,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedText = text.trim();
    final displayText =
        fullWidth || !trimmedText.contains(' ')
            ? trimmedText
            : trimmedText.replaceFirst(RegExp(r'\s+'), '\n');
    final double buttonWidth = fullWidth ? double.infinity : width;
    return SizedBox(
      height: 64.0,
      width: buttonWidth,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? onPressed : null,
        onLongPress: isEnabled ? onLongPress : null,
        icon: Icon(HugeIcons.strokeRoundedPlusSign, size: 30.0),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            displayText,
            style: const TextStyle(fontSize: 24.0),
            textAlign: TextAlign.center,
            softWrap: true,
            maxLines: 2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: isEnabled ? color : color.withValues(alpha: 0.3),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.3),
          disabledBackgroundColor: color.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          elevation: 0,
        ),
      ),
    );
  }
}
