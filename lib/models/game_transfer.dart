import 'dart:convert';
import 'package:bela_blok/models/round.dart';

class GameTransfer {
  final List<Round> rounds;
  final String teamOneName;
  final String teamTwoName;
  final int goalScore;
  final int stigljaValue;
  final DateTime timestamp;

  GameTransfer({
    required this.rounds,
    required this.teamOneName,
    required this.teamTwoName,
    required this.goalScore,
    required this.stigljaValue,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'rounds': rounds.map((round) => round.toJson()).toList(),
      'teamOneName': teamOneName,
      'teamTwoName': teamTwoName,
      'goalScore': goalScore,
      'stigljaValue': stigljaValue,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory GameTransfer.fromJson(Map<String, dynamic> json) {
    return GameTransfer(
      rounds: (json['rounds'] as List).map((r) => Round.fromJson(r)).toList(),
      teamOneName: json['teamOneName'],
      teamTwoName: json['teamTwoName'],
      goalScore: json['goalScore'],
      stigljaValue: json['stigljaValue'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  String toQrData() {
    return jsonEncode(toJson());
  }

  static GameTransfer fromQrData(String qrData) {
    return GameTransfer.fromJson(jsonDecode(qrData));
  }
}
