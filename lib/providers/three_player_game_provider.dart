import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/three_player_round.dart';

class ThreePlayerGameNotifier extends StateNotifier<List<ThreePlayerRound>> {
  ThreePlayerGameNotifier() : super([]);

  void addRound(ThreePlayerRound round) {
    state = [...state, round];
  }

  void updateRound(int index, ThreePlayerRound round) {
    if (index < 0 || index >= state.length) return;
    final newList = List<ThreePlayerRound>.from(state);
    newList[index] = round;
    state = newList;
  }

  void removeRound(int index) {
    if (index < 0 || index >= state.length) return;
    final newList = List<ThreePlayerRound>.from(state);
    newList.removeAt(index);
    state = newList;
  }

  void setRounds(List<ThreePlayerRound> rounds) {
    state = rounds;
  }

  void clearRounds() {
    state = [];
  }
}

final currentThreePlayerGameProvider =
    StateNotifierProvider<ThreePlayerGameNotifier, List<ThreePlayerRound>>(
  (ref) => ThreePlayerGameNotifier(),
);

