import 'package:bela_blok/models/round.dart';

class Game {
  final String id;
  final String teamOneName;
  final String teamTwoName;
  final List<Round> rounds;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int goalScore;

  Game({
    String? id,
    required this.teamOneName,
    required this.teamTwoName,
    List<Round>? rounds,
    DateTime? createdAt,
    this.updatedAt,
    this.goalScore = 1001,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       rounds = rounds ?? [],
       createdAt = createdAt ?? DateTime.now();

  int get teamOneTotalScore => rounds.fold(0, (sum, round) {
    return sum +
        round.scoreTeamOne +
        round.decl20TeamOne * 20 +
        round.decl50TeamOne * 50 +
        round.decl100TeamOne * 100 +
        round.decl150TeamOne * 150 +
        round.decl200TeamOne * 200 +
        round.declStigljaTeamOne * 90;
  });

  int get teamTwoTotalScore => rounds.fold(0, (sum, round) {
    return sum +
        round.scoreTeamTwo +
        round.decl20TeamTwo * 20 +
        round.decl50TeamTwo * 50 +
        round.decl100TeamTwo * 100 +
        round.decl150TeamTwo * 150 +
        round.decl200TeamTwo * 200 +
        round.declStigljaTeamTwo * 90;
  });

  bool get isFinished => teamOneTotalScore >= goalScore || teamTwoTotalScore >= goalScore;

  String get winningTeam {
    if (!isFinished) return '';
    return teamOneTotalScore >= goalScore ? teamOneName : teamTwoName;
  }

  Game copyWith({
    String? id,
    String? teamOneName,
    String? teamTwoName,
    List<Round>? rounds,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? goalScore,
  }) {
    return Game(
      id: id ?? this.id,
      teamOneName: teamOneName ?? this.teamOneName,
      teamTwoName: teamTwoName ?? this.teamTwoName,
      rounds: rounds ?? this.rounds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      goalScore: goalScore ?? this.goalScore,
    );
  }

  Game addRound(Round round) {
    final newRounds = List<Round>.from(rounds)..add(round);
    return copyWith(rounds: newRounds, updatedAt: DateTime.now());
  }

  Game updateRound(int index, Round round) {
    if (index < 0 || index >= rounds.length) {
      throw RangeError('Round index out of range');
    }
    final newRounds = List<Round>.from(rounds);
    newRounds[index] = round;
    return copyWith(rounds: newRounds, updatedAt: DateTime.now());
  }

  Game removeRound(int index) {
    if (index < 0 || index >= rounds.length) {
      throw RangeError('Round index out of range');
    }
    final newRounds = List<Round>.from(rounds);
    newRounds.removeAt(index);
    return copyWith(rounds: newRounds, updatedAt: DateTime.now());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamOneName': teamOneName,
      'teamTwoName': teamTwoName,
      'rounds': rounds.map((round) => round.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'goalScore': goalScore,
    };
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      teamOneName: json['teamOneName'] as String,
      teamTwoName: json['teamTwoName'] as String,
      rounds:
          (json['rounds'] as List<dynamic>).map((e) => Round.fromJson(e as Map<String, dynamic>)).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      goalScore: json['goalScore'] as int,
    );
  }

  @override
  String toString() {
    return 'Game(id: $id, teamOne: $teamOneName, teamTwo: $teamTwoName, rounds: ${rounds.length})';
  }
}
