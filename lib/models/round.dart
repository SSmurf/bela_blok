import 'dart:math';

class Round {
  final int scoreTeamOne;
  final int scoreTeamTwo;
  final int decl20TeamOne;
  final int decl20TeamTwo;
  final int decl50TeamOne;
  final int decl50TeamTwo;
  final int decl100TeamOne;
  final int decl100TeamTwo;
  final int decl150TeamOne;
  final int decl150TeamTwo;
  final int decl200TeamOne;
  final int decl200TeamTwo;
  final int declStigljaTeamOne;
  final int declStigljaTeamTwo;

  Round({
    required this.scoreTeamOne,
    required this.scoreTeamTwo,
    this.decl20TeamOne = 0,
    this.decl20TeamTwo = 0,
    this.decl50TeamOne = 0,
    this.decl50TeamTwo = 0,
    this.decl100TeamOne = 0,
    this.decl100TeamTwo = 0,
    this.decl150TeamOne = 0,
    this.decl150TeamTwo = 0,
    this.decl200TeamOne = 0,
    this.decl200TeamTwo = 0,
    this.declStigljaTeamOne = 0,
    this.declStigljaTeamTwo = 0,
  });

  Round.dummy()
    : scoreTeamOne = Random().nextInt(163),
      scoreTeamTwo = Random().nextInt(163),
      decl20TeamOne = Random().nextInt(6),
      decl20TeamTwo = Random().nextInt(6),
      decl50TeamOne = Random().nextInt(5),
      decl50TeamTwo = Random().nextInt(5),
      decl100TeamOne = Random().nextInt(5),
      decl100TeamTwo = Random().nextInt(5),
      decl150TeamOne = Random().nextInt(2),
      decl150TeamTwo = Random().nextInt(2),
      decl200TeamOne = Random().nextInt(2),
      decl200TeamTwo = Random().nextInt(2),
      declStigljaTeamOne = Random().nextInt(2),
      declStigljaTeamTwo = Random().nextInt(2);

  Round copyWith({
    int? scoreTeamOne,
    int? scoreTeamTwo,
    int? decl20TeamOne,
    int? decl20TeamTwo,
    int? decl50TeamOne,
    int? decl50TeamTwo,
    int? decl100TeamOne,
    int? decl100TeamTwo,
    int? decl150TeamOne,
    int? decl150TeamTwo,
    int? decl200TeamOne,
    int? decl200TeamTwo,
    int? declStigljaTeamOne,
    int? declStigljaTeamTwo,
  }) {
    return Round(
      scoreTeamOne: scoreTeamOne ?? this.scoreTeamOne,
      scoreTeamTwo: scoreTeamTwo ?? this.scoreTeamTwo,
      decl20TeamOne: decl20TeamOne ?? this.decl20TeamOne,
      decl20TeamTwo: decl20TeamTwo ?? this.decl20TeamTwo,
      decl50TeamOne: decl50TeamOne ?? this.decl50TeamOne,
      decl50TeamTwo: decl50TeamTwo ?? this.decl50TeamTwo,
      decl100TeamOne: decl100TeamOne ?? this.decl100TeamOne,
      decl100TeamTwo: decl100TeamTwo ?? this.decl100TeamTwo,
      decl150TeamOne: decl150TeamOne ?? this.decl150TeamOne,
      decl150TeamTwo: decl150TeamTwo ?? this.decl150TeamTwo,
      decl200TeamOne: decl200TeamOne ?? this.decl200TeamOne,
      decl200TeamTwo: decl200TeamTwo ?? this.decl200TeamTwo,
      declStigljaTeamOne: declStigljaTeamOne ?? this.declStigljaTeamOne,
      declStigljaTeamTwo: declStigljaTeamTwo ?? this.declStigljaTeamTwo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scoreTeamOne': scoreTeamOne,
      'scoreTeamTwo': scoreTeamTwo,
      'decl20TeamOne': decl20TeamOne,
      'decl20TeamTwo': decl20TeamTwo,
      'decl50TeamOne': decl50TeamOne,
      'decl50TeamTwo': decl50TeamTwo,
      'decl100TeamOne': decl100TeamOne,
      'decl100TeamTwo': decl100TeamTwo,
      'decl150TeamOne': decl150TeamOne,
      'decl150TeamTwo': decl150TeamTwo,
      'decl200TeamOne': decl200TeamOne,
      'decl200TeamTwo': decl200TeamTwo,
      'declStigljaTeamOne': declStigljaTeamOne,
      'declStigljaTeamTwo': declStigljaTeamTwo,
    };
  }

  factory Round.fromJson(Map<String, dynamic> json) {
    return Round(
      scoreTeamOne: json['scoreTeamOne'] as int,
      scoreTeamTwo: json['scoreTeamTwo'] as int,
      decl20TeamOne: json['decl20TeamOne'] as int,
      decl20TeamTwo: json['decl20TeamTwo'] as int,
      decl50TeamOne: json['decl50TeamOne'] as int,
      decl50TeamTwo: json['decl50TeamTwo'] as int,
      decl100TeamOne: json['decl100TeamOne'] as int,
      decl100TeamTwo: json['decl100TeamTwo'] as int,
      decl150TeamOne: json['decl150TeamOne'] as int,
      decl150TeamTwo: json['decl150TeamTwo'] as int,
      decl200TeamOne: json['decl200TeamOne'] as int,
      decl200TeamTwo: json['decl200TeamTwo'] as int,
      declStigljaTeamOne: json['declStigljaTeamOne'] as int,
      declStigljaTeamTwo: json['declStigljaTeamTwo'] as int,
    );
  }

  @override
  String toString() {
    return 'Round(scoreTeamOne: $scoreTeamOne, scoreTeamTwo: $scoreTeamTwo, '
        'decl20TeamOne: $decl20TeamOne, decl20TeamTwo: $decl20TeamTwo, '
        'decl50TeamOne: $decl50TeamOne, decl50TeamTwo: $decl50TeamTwo, '
        'decl100TeamOne: $decl100TeamOne, decl100TeamTwo: $decl100TeamTwo, '
        'decl150TeamOne: $decl150TeamOne, decl150TeamTwo: $decl150TeamTwo, '
        'decl200TeamOne: $decl200TeamOne, decl200TeamTwo: $decl200TeamTwo, '
        'declStigljaTeamOne: $declStigljaTeamOne, declStigljaTeamTwo: $declStigljaTeamTwo)';
  }
}
