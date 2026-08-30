enum MissionDifficulty { easy, medium, hard }

enum CargoType { parcel, food, buildingMaterials, vehicleParts }

enum DestinationType { house, mountainHut, constructionSite, workshop }

enum MissionRatingCategory {
  deliveryTime,
  cargoCondition,
  drivingControl,
  specialObjective,
}

class MissionRatingRule {
  const MissionRatingRule({
    required this.category,
    required this.maxStars,
    this.threeStarTimeSeconds,
    this.twoStarTimeSeconds,
  }) : assert(maxStars > 0);

  final MissionRatingCategory category;

  /// Maximale Anzahl an Sternen dieser Kategorie.
  final int maxStars;

  /// Zeitgrenze für die beste Zeitbewertung.
  ///
  /// Wird momentan für deliveryTime verwendet.
  final double? threeStarTimeSeconds;

  /// Zeitgrenze für die mittlere Zeitbewertung.
  ///
  /// Alles darüber erhält bei der aktuellen
  /// Zeitbewertung einen Stern.
  final double? twoStarTimeSeconds;

  int evaluateTime(double seconds) {
    if (category != MissionRatingCategory.deliveryTime) {
      return 0;
    }

    final double? threeStarLimit = threeStarTimeSeconds;
    final double? twoStarLimit = twoStarTimeSeconds;

    if (threeStarLimit == null || twoStarLimit == null) {
      return 0;
    }

    if (seconds <= threeStarLimit) {
      return maxStars;
    }

    if (seconds <= twoStarLimit) {
      return (maxStars - 1).clamp(1, maxStars);
    }

    return 1;
  }
}

class DeliveryMission {
  const DeliveryMission({
    required this.id,
    required this.title,
    required this.description,
    required this.cargoType,
    required this.destinationType,
    required this.difficulty,
    required this.moneyReward,
    required this.xpReward,
    required this.requiredLevel,
    this.ratingRules = const <MissionRatingRule>[
      MissionRatingRule(
        category: MissionRatingCategory.deliveryTime,
        maxStars: 3,
        threeStarTimeSeconds: 60,
        twoStarTimeSeconds: 90,
      ),
    ],
  });

  final String id;

  final String title;
  final String description;

  final CargoType cargoType;
  final DestinationType destinationType;

  final MissionDifficulty difficulty;

  final int moneyReward;
  final int xpReward;

  final int requiredLevel;

  final List<MissionRatingRule> ratingRules;

  int get maxStars {
    return ratingRules.fold<int>(0, (int total, MissionRatingRule rule) {
      return total + rule.maxStars;
    });
  }

  MissionRatingRule? get timeRatingRule {
    for (final MissionRatingRule rule in ratingRules) {
      if (rule.category == MissionRatingCategory.deliveryTime) {
        return rule;
      }
    }

    return null;
  }

  int evaluateMissionTime(double seconds) {
    final MissionRatingRule? rule = timeRatingRule;

    if (rule == null) {
      return 0;
    }

    return rule.evaluateTime(seconds);
  }

  bool isUnlockedForLevel(int playerLevel) {
    return playerLevel >= requiredLevel;
  }
}
