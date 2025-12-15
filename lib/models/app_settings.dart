class AppSettings {
  final int goalScore;
  final int stigljaValue;
  final String teamOneName;
  final String teamTwoName;
  final bool isThreePlayerMode;
  final String playerOneName;
  final String playerTwoName;
  final String playerThreeName;

  AppSettings({
    this.goalScore = 1001,
    this.stigljaValue = 90,
    required this.teamOneName,
    required this.teamTwoName,
    this.isThreePlayerMode = false,
    this.playerOneName = 'Osoba 1',
    this.playerTwoName = 'Osoba 2',
    this.playerThreeName = 'Osoba 3',
  });

  AppSettings copyWith({
    int? goalScore,
    int? stigljaValue,
    String? teamOneName,
    String? teamTwoName,
    bool? isThreePlayerMode,
    String? playerOneName,
    String? playerTwoName,
    String? playerThreeName,
  }) {
    return AppSettings(
      goalScore: goalScore ?? this.goalScore,
      stigljaValue: stigljaValue ?? this.stigljaValue,
      teamOneName: teamOneName ?? this.teamOneName,
      teamTwoName: teamTwoName ?? this.teamTwoName,
      isThreePlayerMode: isThreePlayerMode ?? this.isThreePlayerMode,
      playerOneName: playerOneName ?? this.playerOneName,
      playerTwoName: playerTwoName ?? this.playerTwoName,
      playerThreeName: playerThreeName ?? this.playerThreeName,
    );
  }

  Map<String, dynamic> toJson() => {
    'goalScore': goalScore,
    'stigljaValue': stigljaValue,
    'teamOneName': teamOneName,
    'teamTwoName': teamTwoName,
    'isThreePlayerMode': isThreePlayerMode,
    'playerOneName': playerOneName,
    'playerTwoName': playerTwoName,
    'playerThreeName': playerThreeName,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    goalScore: json['goalScore'] as int? ?? 1001,
    stigljaValue: json['stigljaValue'] as int? ?? 90,
    teamOneName: json['teamOneName'] as String? ?? 'Mi',
    teamTwoName: json['teamTwoName'] as String? ?? 'Vi',
    isThreePlayerMode: json['isThreePlayerMode'] as bool? ?? false,
    playerOneName: json['playerOneName'] as String? ?? 'Osoba 1',
    playerTwoName: json['playerTwoName'] as String? ?? 'Osoba 2',
    playerThreeName: json['playerThreeName'] as String? ?? 'Osoba 3',
  );
}
