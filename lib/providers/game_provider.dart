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

  int get teamOneTotal => state.fold(0, (sum, round) {
    return sum +
        round.scoreTeamOne +
        round.decl20TeamOne * 20 +
        round.decl50TeamOne * 50 +
        round.decl100TeamOne * 100 +
        round.decl150TeamOne * 150 +
        round.decl200TeamOne * 200 +
        round.declStigljaTeamOne * 90;
  });

  int get teamTwoTotal => state.fold(0, (sum, round) {
    return sum +
        round.scoreTeamTwo +
        round.decl20TeamTwo * 20 +
        round.decl50TeamTwo * 50 +
        round.decl100TeamTwo * 100 +
        round.decl150TeamTwo * 150 +
        round.decl200TeamTwo * 200 +
        round.declStigljaTeamTwo * 90;
  });
}

final currentGameProvider = StateNotifierProvider<CurrentGameNotifier, List<Round>>((ref) {
  return CurrentGameNotifier();
});
