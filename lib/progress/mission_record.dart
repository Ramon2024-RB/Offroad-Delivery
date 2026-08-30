class MissionRecord {
  const MissionRecord({
    required this.missionId,
    required this.bestTimeSeconds,
    required this.bestStars,
  });

  final String missionId;
  final double bestTimeSeconds;
  final int bestStars;

  MissionRecord copyWith({
    String? missionId,
    double? bestTimeSeconds,
    int? bestStars,
  }) {
    return MissionRecord(
      missionId: missionId ?? this.missionId,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
      bestStars: bestStars ?? this.bestStars,
    );
  }
}
