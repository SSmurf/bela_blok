import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AddRoundButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const AddRoundButton({super.key, required this.text, required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56.0, // Set the desired height
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(Symbols.add, size: 40.0), // Increased icon size
        label: Text(text, style: TextStyle(fontSize: 32.0)), // Increased text size
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, // Custom color
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Squircles shape
          ),
          elevation: 0, // No shadow
        ),
      ),
    );
  }
}
