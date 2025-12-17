import 'package:bela_blok/models/three_player_round.dart';

int computeThreePlayerRoundTotal(
  ThreePlayerRound round,
  int playerIndex,
  int stigljaValue,
) {
  int baseScore;
  int declarations;

  switch (playerIndex) {
    case 0:
      baseScore = round.scorePlayerOne;
      if (round.declStigljaPlayerOne > 0) {
        declarations = _sumAllDeclarations(round) + (round.declStigljaPlayerOne * stigljaValue);
      } else if (round.declStigljaPlayerTwo > 0 || round.declStigljaPlayerThree > 0) {
        declarations = 0;
      } else {
        declarations = _sumSinglePlayerDeclarations(round, playerIndex);
      }
      break;
    case 1:
      baseScore = round.scorePlayerTwo;
      if (round.declStigljaPlayerTwo > 0) {
        declarations = _sumAllDeclarations(round) + (round.declStigljaPlayerTwo * stigljaValue);
      } else if (round.declStigljaPlayerOne > 0 || round.declStigljaPlayerThree > 0) {
        declarations = 0;
      } else {
        declarations = _sumSinglePlayerDeclarations(round, playerIndex);
      }
      break;
    case 2:
      baseScore = round.scorePlayerThree;
      if (round.declStigljaPlayerThree > 0) {
        declarations = _sumAllDeclarations(round) + (round.declStigljaPlayerThree * stigljaValue);
      } else if (round.declStigljaPlayerOne > 0 || round.declStigljaPlayerTwo > 0) {
        declarations = 0;
      } else {
        declarations = _sumSinglePlayerDeclarations(round, playerIndex);
      }
      break;
    default:
      return 0;
  }

  return baseScore + declarations;
}

int _sumAllDeclarations(ThreePlayerRound round) {
  return (round.decl20PlayerOne + round.decl20PlayerTwo + round.decl20PlayerThree) * 20 +
      (round.decl50PlayerOne + round.decl50PlayerTwo + round.decl50PlayerThree) * 50 +
      (round.decl100PlayerOne + round.decl100PlayerTwo + round.decl100PlayerThree) * 100 +
      (round.decl150PlayerOne + round.decl150PlayerTwo + round.decl150PlayerThree) * 150 +
      (round.decl200PlayerOne + round.decl200PlayerTwo + round.decl200PlayerThree) * 200;
}

int _sumSinglePlayerDeclarations(ThreePlayerRound round, int playerIndex) {
  switch (playerIndex) {
    case 0:
      return round.decl20PlayerOne * 20 +
          round.decl50PlayerOne * 50 +
          round.decl100PlayerOne * 100 +
          round.decl150PlayerOne * 150 +
          round.decl200PlayerOne * 200;
    case 1:
      return round.decl20PlayerTwo * 20 +
          round.decl50PlayerTwo * 50 +
          round.decl100PlayerTwo * 100 +
          round.decl150PlayerTwo * 150 +
          round.decl200PlayerTwo * 200;
    case 2:
      return round.decl20PlayerThree * 20 +
          round.decl50PlayerThree * 50 +
          round.decl100PlayerThree * 100 +
          round.decl150PlayerThree * 150 +
          round.decl200PlayerThree * 200;
    default:
      return 0;
  }
}

