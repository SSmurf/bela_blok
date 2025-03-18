import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/round.dart';

class RoundDisplay extends StatelessWidget {
  final Round round;

  const RoundDisplay({super.key, required this.round});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Text(
            round.scoreTeamOne.toString(),
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(child: Icon(Symbols.horizontal_rule, size: 24)),
        Expanded(
          child: Text(
            round.scoreTeamOne.toString(),
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
