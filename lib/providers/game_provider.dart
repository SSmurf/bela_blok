import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/round.dart';

class CurrentGameNotifier extends StateNotifier<List<Round>> {
  CurrentGameNotifier() : super([]);

  void addRound(Round round) {
    state = [...state, round];
  }

  void removeRound(int index) {
    if (index < 0 || index >= state.length) return;

    final newList = List<Round>.from(state);
    newList.removeAt(index);
    state = newList;
  }

  void clearRounds() {
    state = [];
  }

  void updateRound(int index, Round round) {
    if (index < 0 || index >= state.length) return;

    final newList = List<Round>.from(state);
    newList[index] = round;
    state = newList;
  }

  int get teamOneTotal => state.fold(0, (sum, round) => sum + round.scoreTeamOne);
  int get teamTwoTotal => state.fold(0, (sum, round) => sum + round.scoreTeamTwo);
}

final currentGameProvider = StateNotifierProvider<CurrentGameNotifier, List<Round>>((ref) {
  return CurrentGameNotifier();
});
