class ThreePlayerRound {
  final int scorePlayerOne;
  final int scorePlayerTwo;
  final int scorePlayerThree;

  // Declarations for Player One
  final int decl20PlayerOne;
  final int decl50PlayerOne;
  final int decl100PlayerOne;
  final int decl150PlayerOne;
  final int decl200PlayerOne;
  final int declStigljaPlayerOne;

  // Declarations for Player Two
  final int decl20PlayerTwo;
  final int decl50PlayerTwo;
  final int decl100PlayerTwo;
  final int decl150PlayerTwo;
  final int decl200PlayerTwo;
  final int declStigljaPlayerTwo;

  // Declarations for Player Three
  final int decl20PlayerThree;
  final int decl50PlayerThree;
  final int decl100PlayerThree;
  final int decl150PlayerThree;
  final int decl200PlayerThree;
  final int declStigljaPlayerThree;

  ThreePlayerRound({
    required this.scorePlayerOne,
    required this.scorePlayerTwo,
    required this.scorePlayerThree,
    this.decl20PlayerOne = 0,
    this.decl50PlayerOne = 0,
    this.decl100PlayerOne = 0,
    this.decl150PlayerOne = 0,
    this.decl200PlayerOne = 0,
    this.declStigljaPlayerOne = 0,
    this.decl20PlayerTwo = 0,
    this.decl50PlayerTwo = 0,
    this.decl100PlayerTwo = 0,
    this.decl150PlayerTwo = 0,
    this.decl200PlayerTwo = 0,
    this.declStigljaPlayerTwo = 0,
    this.decl20PlayerThree = 0,
    this.decl50PlayerThree = 0,
    this.decl100PlayerThree = 0,
    this.decl150PlayerThree = 0,
    this.decl200PlayerThree = 0,
    this.declStigljaPlayerThree = 0,
  });

  ThreePlayerRound copyWith({
    int? scorePlayerOne,
    int? scorePlayerTwo,
    int? scorePlayerThree,
    int? decl20PlayerOne,
    int? decl50PlayerOne,
    int? decl100PlayerOne,
    int? decl150PlayerOne,
    int? decl200PlayerOne,
    int? declStigljaPlayerOne,
    int? decl20PlayerTwo,
    int? decl50PlayerTwo,
    int? decl100PlayerTwo,
    int? decl150PlayerTwo,
    int? decl200PlayerTwo,
    int? declStigljaPlayerTwo,
    int? decl20PlayerThree,
    int? decl50PlayerThree,
    int? decl100PlayerThree,
    int? decl150PlayerThree,
    int? decl200PlayerThree,
    int? declStigljaPlayerThree,
  }) {
    return ThreePlayerRound(
      scorePlayerOne: scorePlayerOne ?? this.scorePlayerOne,
      scorePlayerTwo: scorePlayerTwo ?? this.scorePlayerTwo,
      scorePlayerThree: scorePlayerThree ?? this.scorePlayerThree,
      decl20PlayerOne: decl20PlayerOne ?? this.decl20PlayerOne,
      decl50PlayerOne: decl50PlayerOne ?? this.decl50PlayerOne,
      decl100PlayerOne: decl100PlayerOne ?? this.decl100PlayerOne,
      decl150PlayerOne: decl150PlayerOne ?? this.decl150PlayerOne,
      decl200PlayerOne: decl200PlayerOne ?? this.decl200PlayerOne,
      declStigljaPlayerOne: declStigljaPlayerOne ?? this.declStigljaPlayerOne,
      decl20PlayerTwo: decl20PlayerTwo ?? this.decl20PlayerTwo,
      decl50PlayerTwo: decl50PlayerTwo ?? this.decl50PlayerTwo,
      decl100PlayerTwo: decl100PlayerTwo ?? this.decl100PlayerTwo,
      decl150PlayerTwo: decl150PlayerTwo ?? this.decl150PlayerTwo,
      decl200PlayerTwo: decl200PlayerTwo ?? this.decl200PlayerTwo,
      declStigljaPlayerTwo: declStigljaPlayerTwo ?? this.declStigljaPlayerTwo,
      decl20PlayerThree: decl20PlayerThree ?? this.decl20PlayerThree,
      decl50PlayerThree: decl50PlayerThree ?? this.decl50PlayerThree,
      decl100PlayerThree: decl100PlayerThree ?? this.decl100PlayerThree,
      decl150PlayerThree: decl150PlayerThree ?? this.decl150PlayerThree,
      decl200PlayerThree: decl200PlayerThree ?? this.decl200PlayerThree,
      declStigljaPlayerThree: declStigljaPlayerThree ?? this.declStigljaPlayerThree,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scorePlayerOne': scorePlayerOne,
      'scorePlayerTwo': scorePlayerTwo,
      'scorePlayerThree': scorePlayerThree,
      'decl20PlayerOne': decl20PlayerOne,
      'decl50PlayerOne': decl50PlayerOne,
      'decl100PlayerOne': decl100PlayerOne,
      'decl150PlayerOne': decl150PlayerOne,
      'decl200PlayerOne': decl200PlayerOne,
      'declStigljaPlayerOne': declStigljaPlayerOne,
      'decl20PlayerTwo': decl20PlayerTwo,
      'decl50PlayerTwo': decl50PlayerTwo,
      'decl100PlayerTwo': decl100PlayerTwo,
      'decl150PlayerTwo': decl150PlayerTwo,
      'decl200PlayerTwo': decl200PlayerTwo,
      'declStigljaPlayerTwo': declStigljaPlayerTwo,
      'decl20PlayerThree': decl20PlayerThree,
      'decl50PlayerThree': decl50PlayerThree,
      'decl100PlayerThree': decl100PlayerThree,
      'decl150PlayerThree': decl150PlayerThree,
      'decl200PlayerThree': decl200PlayerThree,
      'declStigljaPlayerThree': declStigljaPlayerThree,
    };
  }

  factory ThreePlayerRound.fromJson(Map<String, dynamic> json) {
    return ThreePlayerRound(
      scorePlayerOne: json['scorePlayerOne'] as int,
      scorePlayerTwo: json['scorePlayerTwo'] as int,
      scorePlayerThree: json['scorePlayerThree'] as int,
      decl20PlayerOne: json['decl20PlayerOne'] as int? ?? 0,
      decl50PlayerOne: json['decl50PlayerOne'] as int? ?? 0,
      decl100PlayerOne: json['decl100PlayerOne'] as int? ?? 0,
      decl150PlayerOne: json['decl150PlayerOne'] as int? ?? 0,
      decl200PlayerOne: json['decl200PlayerOne'] as int? ?? 0,
      declStigljaPlayerOne: json['declStigljaPlayerOne'] as int? ?? 0,
      decl20PlayerTwo: json['decl20PlayerTwo'] as int? ?? 0,
      decl50PlayerTwo: json['decl50PlayerTwo'] as int? ?? 0,
      decl100PlayerTwo: json['decl100PlayerTwo'] as int? ?? 0,
      decl150PlayerTwo: json['decl150PlayerTwo'] as int? ?? 0,
      decl200PlayerTwo: json['decl200PlayerTwo'] as int? ?? 0,
      declStigljaPlayerTwo: json['declStigljaPlayerTwo'] as int? ?? 0,
      decl20PlayerThree: json['decl20PlayerThree'] as int? ?? 0,
      decl50PlayerThree: json['decl50PlayerThree'] as int? ?? 0,
      decl100PlayerThree: json['decl100PlayerThree'] as int? ?? 0,
      decl150PlayerThree: json['decl150PlayerThree'] as int? ?? 0,
      decl200PlayerThree: json['decl200PlayerThree'] as int? ?? 0,
      declStigljaPlayerThree: json['declStigljaPlayerThree'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'ThreePlayerRound(P1: $scorePlayerOne, P2: $scorePlayerTwo, P3: $scorePlayerThree)';
  }
}

