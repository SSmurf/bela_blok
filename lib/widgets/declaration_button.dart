import 'package:flutter/material.dart';

class DeclarationButton extends StatelessWidget {
  final String text;
  final double width;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback onPressed;

  const DeclarationButton({
    super.key,
    required this.text,
    this.width = 100,
    this.fontSize = 28,
    this.fontWeight = FontWeight.w600,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: width,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            // minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            text,
            style: TextStyle(color: Colors.black, fontSize: fontSize, fontWeight: fontWeight),
          ),
        ),
      ),
    );
  }
}
