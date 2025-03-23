class AppSettings {
  final int goalScore;
  final int stigljaValue;

  AppSettings({this.goalScore = 1001, this.stigljaValue = 90});

  Map<String, dynamic> toJson() => {
        'goalScore': goalScore,
        'stigljaValue': stigljaValue,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        goalScore: json['goalScore'] as int? ?? 1001,
        stigljaValue: json['stigljaValue'] as int? ?? 90,
      );
}
