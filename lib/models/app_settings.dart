class AppSettings {
  final int goalScore;
  final int stigljaValue;
  final String teamOneName;
  final String teamTwoName;

  AppSettings({
    this.goalScore = 1001,
    this.stigljaValue = 90,
    required this.teamOneName,
    required this.teamTwoName,
  });

  Map<String, dynamic> toJson() => {
    'goalScore': goalScore,
    'stigljaValue': stigljaValue,
    'teamOneName': teamOneName,
    'teamTwoName': teamTwoName,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    goalScore: json['goalScore'] as int? ?? 1001,
    stigljaValue: json['stigljaValue'] as int? ?? 90,
    teamOneName: json['teamOneName'] as String? ?? 'Mi',
    teamTwoName: json['teamTwoName'] as String? ?? 'Vi',
  );
}
