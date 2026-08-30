enum MissionDifficulty { easy, medium, hard }

enum CargoType { parcel, food, buildingMaterials, vehicleParts }

enum DestinationType { house, mountainHut, constructionSite, workshop }

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

  bool isUnlockedForLevel(int playerLevel) {
    return playerLevel >= requiredLevel;
  }
}
