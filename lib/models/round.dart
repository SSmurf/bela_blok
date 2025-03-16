class Round {
  final int scoreTeamOne;
  final int scoreTeamTwo;

  Round({required this.scoreTeamOne, required this.scoreTeamTwo});

  Round.dummy() : scoreTeamOne = 123, scoreTeamTwo = 456;

  Round copyWith({int? scoreTeamOne, int? scoreTeamTwo}) {
    return Round(
      scoreTeamOne: scoreTeamOne ?? this.scoreTeamOne,
      scoreTeamTwo: scoreTeamTwo ?? this.scoreTeamTwo,
    );
  }

  Map<String, dynamic> toJson() {
    return {'scoreTeamOne': scoreTeamOne, 'scoreTeamTwo': scoreTeamTwo};
  }

  factory Round.fromJson(Map<String, dynamic> json) {
    return Round(scoreTeamOne: json['scoreTeamOne'] as int, scoreTeamTwo: json['scoreTeamTwo'] as int);
  }

  @override
  String toString() => 'Round(scoreTeamOne: $scoreTeamOne, scoreTeamTwo: $scoreTeamTwo)';
}
