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
    this.perfectConditionPercent,
    this.goodConditionPercent,
  }) : assert(maxStars > 0);

  final MissionRatingCategory category;

  /// Maximale Anzahl an Sternen dieser Kategorie.
  final int maxStars;

  // --------------------------------------------------
  // ZEITBEWERTUNG
  // --------------------------------------------------

  /// Zeitgrenze für die beste Zeitbewertung.
  ///
  /// Wird für deliveryTime verwendet.
  final double? threeStarTimeSeconds;

  /// Zeitgrenze für die mittlere Zeitbewertung.
  ///
  /// Alles darüber erhält bei der aktuellen
  /// Zeitbewertung einen Stern.
  final double? twoStarTimeSeconds;

  // --------------------------------------------------
  // LADUNGSZUSTAND
  // --------------------------------------------------

  /// Mindestzustand der Ladung für die volle
  /// Sternezahl dieser Kategorie.
  ///
  /// Beispiel:
  /// 90 bedeutet mindestens 90 % Ladungszustand.
  final double? perfectConditionPercent;

  /// Mindestzustand für die mittlere Bewertung.
  ///
  /// Darunter gibt es bei der aktuellen
  /// Ladungsbewertung keine Sterne.
  final double? goodConditionPercent;

  int evaluateTime(double seconds) {
    if (category != MissionRatingCategory.deliveryTime) {
      return 0;
    }

    final double? bestLimit = threeStarTimeSeconds;

    final double? middleLimit = twoStarTimeSeconds;

    if (bestLimit == null || middleLimit == null) {
      return 0;
    }

    if (seconds <= bestLimit) {
      return maxStars;
    }

    if (seconds <= middleLimit) {
      return (maxStars - 1).clamp(1, maxStars);
    }

    return 1;
  }

  int evaluateCargoCondition(double conditionPercent) {
    if (category != MissionRatingCategory.cargoCondition) {
      return 0;
    }

    final double? perfectLimit = perfectConditionPercent;

    final double? goodLimit = goodConditionPercent;

    if (perfectLimit == null || goodLimit == null) {
      return 0;
    }

    final double safeCondition = conditionPercent.clamp(0.0, 100.0);

    if (safeCondition >= perfectLimit) {
      return maxStars;
    }

    if (safeCondition >= goodLimit) {
      return (maxStars - 1).clamp(1, maxStars);
    }

    return 0;
  }
}

class MissionRatingResult {
  const MissionRatingResult({
    required this.timeStars,
    required this.cargoConditionStars,
    required this.drivingControlStars,
    required this.specialObjectiveStars,
  });

  final int timeStars;
  final int cargoConditionStars;
  final int drivingControlStars;
  final int specialObjectiveStars;

  int get totalStars {
    return timeStars +
        cargoConditionStars +
        drivingControlStars +
        specialObjectiveStars;
  }
}

class DeliveryMission {
  const DeliveryMission({
    required this.id,
    required this.title,
    required this.description,
    required this.routeId,
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

  // --------------------------------------------------
  // ROUTE
  // --------------------------------------------------

  /// Eindeutige ID der Route, auf der diese Mission stattfindet.
  ///
  /// Die ID verweist auf eine Route aus dem RouteCatalog.
  ///
  /// Dadurch können Missionen später gezielt auf vollständig
  /// individuell entworfenen Strecken stattfinden.
  ///
  /// Beispiel:
  /// route_01
  final String routeId;

  final CargoType cargoType;
  final DestinationType destinationType;

  final MissionDifficulty difficulty;

  final int moneyReward;
  final int xpReward;

  final int requiredLevel;

  final List<MissionRatingRule> ratingRules;

  // --------------------------------------------------
  // MAXIMALE GESAMTSTERNE
  // --------------------------------------------------

  int get maxStars {
    return ratingRules.fold<int>(0, (int total, MissionRatingRule rule) {
      return total + rule.maxStars;
    });
  }

  // --------------------------------------------------
  // BEWERTUNGSREGELN FINDEN
  // --------------------------------------------------

  MissionRatingRule? ratingRuleFor(MissionRatingCategory category) {
    for (final MissionRatingRule rule in ratingRules) {
      if (rule.category == category) {
        return rule;
      }
    }

    return null;
  }

  MissionRatingRule? get timeRatingRule {
    return ratingRuleFor(MissionRatingCategory.deliveryTime);
  }

  MissionRatingRule? get cargoConditionRatingRule {
    return ratingRuleFor(MissionRatingCategory.cargoCondition);
  }

  MissionRatingRule? get drivingControlRatingRule {
    return ratingRuleFor(MissionRatingCategory.drivingControl);
  }

  MissionRatingRule? get specialObjectiveRatingRule {
    return ratingRuleFor(MissionRatingCategory.specialObjective);
  }

  // --------------------------------------------------
  // EINZELNE BEWERTUNGEN
  // --------------------------------------------------

  int evaluateMissionTime(double seconds) {
    final MissionRatingRule? rule = timeRatingRule;

    if (rule == null) {
      return 0;
    }

    return rule.evaluateTime(seconds);
  }

  int evaluateCargoCondition(double conditionPercent) {
    final MissionRatingRule? rule = cargoConditionRatingRule;

    if (rule == null) {
      return 0;
    }

    return rule.evaluateCargoCondition(conditionPercent);
  }

  // --------------------------------------------------
  // GESAMTBEWERTUNG
  // --------------------------------------------------

  MissionRatingResult evaluateMission({
    required double timeSeconds,
    double cargoConditionPercent = 100.0,
    int drivingControlStars = 0,
    int specialObjectiveStars = 0,
  }) {
    final int timeStars = evaluateMissionTime(timeSeconds);

    final int cargoStars = evaluateCargoCondition(cargoConditionPercent);

    final int safeDrivingStars = _clampStarsForCategory(
      MissionRatingCategory.drivingControl,
      drivingControlStars,
    );

    final int safeSpecialStars = _clampStarsForCategory(
      MissionRatingCategory.specialObjective,
      specialObjectiveStars,
    );

    return MissionRatingResult(
      timeStars: timeStars,
      cargoConditionStars: cargoStars,
      drivingControlStars: safeDrivingStars,
      specialObjectiveStars: safeSpecialStars,
    );
  }

  int _clampStarsForCategory(MissionRatingCategory category, int stars) {
    final MissionRatingRule? rule = ratingRuleFor(category);

    if (rule == null) {
      return 0;
    }

    return stars.clamp(0, rule.maxStars);
  }

  // --------------------------------------------------
  // FREISCHALTUNG
  // --------------------------------------------------

  bool isUnlockedForLevel(int playerLevel) {
    return playerLevel >= requiredLevel;
  }
}
