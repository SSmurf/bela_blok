import 'package:bela_blok/models/three_player_round.dart';

class ThreePlayerGame {
  final String id;
  final String playerOneName;
  final String playerTwoName;
  final String playerThreeName;
  final List<ThreePlayerRound> rounds;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int goalScore;
  final bool isCanceled;

  ThreePlayerGame({
    String? id,
    required this.playerOneName,
    required this.playerTwoName,
    required this.playerThreeName,
    List<ThreePlayerRound>? rounds,
    DateTime? createdAt,
    this.updatedAt,
    this.goalScore = 1001,
    this.isCanceled = false,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        rounds = rounds ?? [],
        createdAt = createdAt ?? DateTime.now();

  int _calculatePlayerTotal(ThreePlayerRound round, int player, int stigljaValue) {
    int score;
    int decl20, decl50, decl100, decl150, decl200, declStiglja;

    switch (player) {
      case 1:
        score = round.scorePlayerOne;
        decl20 = round.decl20PlayerOne;
        decl50 = round.decl50PlayerOne;
        decl100 = round.decl100PlayerOne;
        decl150 = round.decl150PlayerOne;
        decl200 = round.decl200PlayerOne;
        declStiglja = round.declStigljaPlayerOne;
        break;
      case 2:
        score = round.scorePlayerTwo;
        decl20 = round.decl20PlayerTwo;
        decl50 = round.decl50PlayerTwo;
        decl100 = round.decl100PlayerTwo;
        decl150 = round.decl150PlayerTwo;
        decl200 = round.decl200PlayerTwo;
        declStiglja = round.declStigljaPlayerTwo;
        break;
      case 3:
        score = round.scorePlayerThree;
        decl20 = round.decl20PlayerThree;
        decl50 = round.decl50PlayerThree;
        decl100 = round.decl100PlayerThree;
        decl150 = round.decl150PlayerThree;
        decl200 = round.decl200PlayerThree;
        declStiglja = round.declStigljaPlayerThree;
        break;
      default:
        return 0;
    }

    // Check if another player has stiglja - if so, this player gets nothing
    if (player != 1 && round.declStigljaPlayerOne > 0) return 0;
    if (player != 2 && round.declStigljaPlayerTwo > 0) return 0;
    if (player != 3 && round.declStigljaPlayerThree > 0) return 0;

    // If this player has stiglja, they get all declarations from all players
    if (declStiglja > 0) {
      final allDecl20 = round.decl20PlayerOne + round.decl20PlayerTwo + round.decl20PlayerThree;
      final allDecl50 = round.decl50PlayerOne + round.decl50PlayerTwo + round.decl50PlayerThree;
      final allDecl100 = round.decl100PlayerOne + round.decl100PlayerTwo + round.decl100PlayerThree;
      final allDecl150 = round.decl150PlayerOne + round.decl150PlayerTwo + round.decl150PlayerThree;
      final allDecl200 = round.decl200PlayerOne + round.decl200PlayerTwo + round.decl200PlayerThree;

      return score +
          allDecl20 * 20 +
          allDecl50 * 50 +
          allDecl100 * 100 +
          allDecl150 * 150 +
          allDecl200 * 200 +
          declStiglja * stigljaValue;
    }

    return score +
        decl20 * 20 +
        decl50 * 50 +
        decl100 * 100 +
        decl150 * 150 +
        decl200 * 200;
  }

  int getPlayerOneTotalScore({int stigljaValue = 90}) {
    return rounds.fold(0, (sum, round) => sum + _calculatePlayerTotal(round, 1, stigljaValue));
  }

  int getPlayerTwoTotalScore({int stigljaValue = 90}) {
    return rounds.fold(0, (sum, round) => sum + _calculatePlayerTotal(round, 2, stigljaValue));
  }

  int getPlayerThreeTotalScore({int stigljaValue = 90}) {
    return rounds.fold(0, (sum, round) => sum + _calculatePlayerTotal(round, 3, stigljaValue));
  }

  bool isFinished({int stigljaValue = 90}) {
    final p1 = getPlayerOneTotalScore(stigljaValue: stigljaValue);
    final p2 = getPlayerTwoTotalScore(stigljaValue: stigljaValue);
    final p3 = getPlayerThreeTotalScore(stigljaValue: stigljaValue);
    return p1 >= goalScore || p2 >= goalScore || p3 >= goalScore;
  }

  String getWinningPlayer({int stigljaValue = 90}) {
    if (!isFinished(stigljaValue: stigljaValue)) return '';

    final p1 = getPlayerOneTotalScore(stigljaValue: stigljaValue);
    final p2 = getPlayerTwoTotalScore(stigljaValue: stigljaValue);
    final p3 = getPlayerThreeTotalScore(stigljaValue: stigljaValue);

    if (p1 >= goalScore && p1 >= p2 && p1 >= p3) return playerOneName;
    if (p2 >= goalScore && p2 >= p1 && p2 >= p3) return playerTwoName;
    if (p3 >= goalScore && p3 >= p1 && p3 >= p2) return playerThreeName;

    return '';
  }

  ThreePlayerGame copyWith({
    String? id,
    String? playerOneName,
    String? playerTwoName,
    String? playerThreeName,
    List<ThreePlayerRound>? rounds,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? goalScore,
    bool? isCanceled,
  }) {
    return ThreePlayerGame(
      id: id ?? this.id,
      playerOneName: playerOneName ?? this.playerOneName,
      playerTwoName: playerTwoName ?? this.playerTwoName,
      playerThreeName: playerThreeName ?? this.playerThreeName,
      rounds: rounds ?? this.rounds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      goalScore: goalScore ?? this.goalScore,
      isCanceled: isCanceled ?? this.isCanceled,
    );
  }

  ThreePlayerGame addRound(ThreePlayerRound round) {
    final newRounds = List<ThreePlayerRound>.from(rounds)..add(round);
    return copyWith(rounds: newRounds, updatedAt: DateTime.now());
  }

  ThreePlayerGame updateRound(int index, ThreePlayerRound round) {
    if (index < 0 || index >= rounds.length) {
      throw RangeError('Round index out of range');
    }
    final newRounds = List<ThreePlayerRound>.from(rounds);
    newRounds[index] = round;
    return copyWith(rounds: newRounds, updatedAt: DateTime.now());
  }

  ThreePlayerGame removeRound(int index) {
    if (index < 0 || index >= rounds.length) {
      throw RangeError('Round index out of range');
    }
    final newRounds = List<ThreePlayerRound>.from(rounds);
    newRounds.removeAt(index);
    return copyWith(rounds: newRounds, updatedAt: DateTime.now());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerOneName': playerOneName,
      'playerTwoName': playerTwoName,
      'playerThreeName': playerThreeName,
      'rounds': rounds.map((round) => round.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'goalScore': goalScore,
      'isCanceled': isCanceled,
      'isThreePlayer': true,
    };
  }

  factory ThreePlayerGame.fromJson(Map<String, dynamic> json) {
    return ThreePlayerGame(
      id: json['id'] as String,
      playerOneName: json['playerOneName'] as String,
      playerTwoName: json['playerTwoName'] as String,
      playerThreeName: json['playerThreeName'] as String,
      rounds: (json['rounds'] as List<dynamic>)
          .map((e) => ThreePlayerRound.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      goalScore: json['goalScore'] as int,
      isCanceled: json['isCanceled'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'ThreePlayerGame(id: $id, P1: $playerOneName, P2: $playerTwoName, P3: $playerThreeName, rounds: ${rounds.length})';
  }
}

