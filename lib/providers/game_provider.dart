import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game.dart';

class GamesNotifier extends StateNotifier<List<Game>> {
  GamesNotifier() : super([]);

  void addGame(Game game) {
    state = [...state, game];
  }

  void updateGame(Game updatedGame) {
    state = [
      for (final game in state)
        if (game.id == updatedGame.id) updatedGame else game,
    ];
  }

  void deleteGame(String gameId) {
    state = state.where((game) => game.id != gameId).toList();
  }

  Game? getGameById(String gameId) {
    try {
      return state.firstWhere((game) => game.id == gameId);
    } catch (_) {
      return null;
    }
  }
}

final gamesProvider = StateNotifierProvider<GamesNotifier, List<Game>>((ref) {
  return GamesNotifier();
});

final gameProvider = Provider.family<Game?, String>((ref, gameId) {
  final games = ref.watch(gamesProvider);
  return games.firstWhere((game) => game.id == gameId);
});
