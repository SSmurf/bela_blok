import 'package:bela_blok/models/game_transfer.dart';
import 'package:bela_blok/providers/game_provider.dart';
import 'package:bela_blok/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';

class QrService {
  static GameTransfer createGameTransfer(WidgetRef ref) {
    final rounds = ref.read(currentGameProvider);
    final settings = ref.read(settingsProvider);

    return GameTransfer(
      rounds: rounds,
      teamOneName: settings.teamOneName,
      teamTwoName: settings.teamTwoName,
      goalScore: settings.goalScore,
      stigljaValue: settings.stigljaValue,
    );
  }

  static void importGame(WidgetRef ref, GameTransfer gameTransfer) {
    // Update settings
    ref.read(settingsProvider.notifier).state = AppSettings(
      goalScore: gameTransfer.goalScore,
      stigljaValue: gameTransfer.stigljaValue,
      teamOneName: gameTransfer.teamOneName,
      teamTwoName: gameTransfer.teamTwoName,
    );

    // Update game rounds
    ref.read(currentGameProvider.notifier).clearRounds();
    for (final round in gameTransfer.rounds) {
      ref.read(currentGameProvider.notifier).addRound(round);
    }
  }
}
