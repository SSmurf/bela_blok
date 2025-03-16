import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/round.dart';

class RoundDisplay extends StatelessWidget {
  final Round round;

  RoundDisplay({required this.round});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(round.scoreTeamOne.toString(), style: TextStyle(fontSize: 24)),
        Icon(Symbols.horizontal_rule, size: 24),
        Text(round.scoreTeamOne.toString(), style: TextStyle(fontSize: 24)),
      ],
    );
  }
}
