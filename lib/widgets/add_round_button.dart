import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AddRoundButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final Color color;
  final bool isEnabled;

  const AddRoundButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    this.isEnabled = true,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64.0,
      width: 250.0,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? onPressed : null,
        onLongPress: isEnabled ? onLongPress : null,
        icon: Icon(HugeIcons.strokeRoundedPlusSign, size: 30.0),
        label: Text(text, style: const TextStyle(fontSize: 24.0)),
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
