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
    this.width = 125,
    this.fontSize = 28,
    this.fontWeight = FontWeight.w600,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: width,
        height: 65,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size.fromHeight(50),
            side: BorderSide(color: Colors.transparent),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(text, style: TextStyle(fontSize: fontSize, fontWeight: fontWeight)),
        ),
      ),
    );
  }
}
