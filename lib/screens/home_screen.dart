import 'package:bela_blok/models/round.dart';
import 'package:bela_blok/widgets/round_display.dart';
import 'package:bela_blok/widgets/total_score_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.settings_outlined), iconSize: 32, onPressed: () {}),
        actions: [
          IconButton(icon: Icon(Symbols.clear), iconSize: 32, onPressed: () {}),
          IconButton(icon: const Icon(Symbols.history), iconSize: 32, onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
        child: Column(
          children: [
            TotalScoreDisplay(scoreTeamOne: 654, scoreTeamTwo: 123),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                  RoundDisplay(round: Round.dummy()),
                ],
              ),
            ),
            Row(),
          ],
        ),
      ),
    );
  }
}
