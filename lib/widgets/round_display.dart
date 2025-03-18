import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/round.dart';

class RoundDisplay extends StatelessWidget {
  final Round round;
  final int roundIndex;

  const RoundDisplay({super.key, required this.round, required this.roundIndex});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: 24,
            child: Text('$roundIndex.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          ),

          Expanded(
            child: Text(
              round.scoreTeamOne.toString(),
              style: TextStyle(fontSize: 32),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(child: Icon(Symbols.horizontal_rule, size: 32)),
          Expanded(
            child: Text(
              round.scoreTeamOne.toString(),
              style: TextStyle(fontSize: 32),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 24),
        ],
      ),
    );
  }
}
