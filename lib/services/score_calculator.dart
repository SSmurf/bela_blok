import 'package:bela_blok/models/round.dart';

class ScoreCalculator {
  final int stigljaValue;

  ScoreCalculator({this.stigljaValue = 90});

  int computeTeamOneTotal(List<Round> rounds) {
    return rounds.fold(0, (sum, round) => sum + computeTeamOneRoundTotal(round));
  }

  int computeTeamTwoTotal(List<Round> rounds) {
    return rounds.fold(0, (sum, round) => sum + computeTeamTwoRoundTotal(round));
  }

  int computeTeamOneRoundTotal(Round round) {
    return round.scoreTeamOne +
        round.decl20TeamOne * 20 +
        round.decl50TeamOne * 50 +
        round.decl100TeamOne * 100 +
        round.decl150TeamOne * 150 +
        round.decl200TeamOne * 200 +
        round.declStigljaTeamOne * stigljaValue;
  }

  int computeTeamTwoRoundTotal(Round round) {
    return round.scoreTeamTwo +
        round.decl20TeamTwo * 20 +
        round.decl50TeamTwo * 50 +
        round.decl100TeamTwo * 100 +
        round.decl150TeamTwo * 150 +
        round.decl200TeamTwo * 200 +
        round.declStigljaTeamTwo * stigljaValue;
  }
}
