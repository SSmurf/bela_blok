const int kThreePlayerNameMaxLength = 10;

extension PlayerNameTruncation on String {
  String get truncatedForThreePlayers {
    if (length <= kThreePlayerNameMaxLength) return this;
    return substring(0, kThreePlayerNameMaxLength);
  }
}
