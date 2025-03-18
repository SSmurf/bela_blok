import 'package:bela_blok/models/round.dart';
import 'package:bela_blok/widgets/round_display.dart';
import 'package:bela_blok/widgets/total_score_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../widgets/add_round_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.settings_outlined), iconSize: 32, onPressed: () {}),
        actions: [
          IconButton(icon: const Icon(Symbols.clear), iconSize: 32, onPressed: () {}),
          IconButton(icon: const Icon(Symbols.history), iconSize: 32, onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          children: [
            TotalScoreDisplay(scoreTeamOne: 654, scoreTeamTwo: 123),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Expanded(
              child: FadingEdgeScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      return RoundDisplay(round: Round.dummy(), roundIndex: index);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AddRoundButton(text: 'Mi', color: Colors.green, onPressed: () {}),
                AddRoundButton(text: 'Vi', color: Colors.red, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class FadingEdgeScrollView extends StatelessWidget {
  final Widget child;
  final double fadeHeight;

  const FadingEdgeScrollView({super.key, required this.child, this.fadeHeight = 20.0});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect rect) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
          stops: [0.0, fadeHeight / rect.height, 1.0 - (fadeHeight / rect.height), 1.0],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}
