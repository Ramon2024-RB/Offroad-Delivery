class PlayerProgress {
  const PlayerProgress({
    required this.money,
    required this.xp,
    required this.level,
  });

  final int money;
  final int xp;
  final int level;

  factory PlayerProgress.initial() {
    return const PlayerProgress(money: 0, xp: 0, level: 1);
  }

  PlayerProgress copyWith({int? money, int? xp, int? level}) {
    return PlayerProgress(
      money: money ?? this.money,
      xp: xp ?? this.xp,
      level: level ?? this.level,
    );
  }

  PlayerProgress addRewards({required int moneyReward, required int xpReward}) {
    final int newXp = xp + xpReward;

    return copyWith(
      money: money + moneyReward,
      xp: newXp,
      level: _calculateLevel(newXp),
    );
  }

  static int _calculateLevel(int xp) {
    return 1 + (xp ~/ 1000);
  }
}
