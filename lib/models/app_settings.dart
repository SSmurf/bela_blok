class AppSettings {
  int goalScore;
  
  AppSettings({this.goalScore = 1001});
  
  Map<String, dynamic> toJson() => {'goalScore': goalScore};
  
  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        goalScore: json['goalScore'] as int? ?? 1001,
      );
}
