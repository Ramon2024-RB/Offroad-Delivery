import 'delivery_mission.dart';

class MissionCatalog {
  const MissionCatalog._();

  static const List<DeliveryMission> missions = [
    DeliveryMission(
      id: 'parcel_house_01',
      title: 'Paket zum Wohnhaus',
      description:
          'Hole ein Paket am Depot ab und liefere es sicher zum Kunden.',
      cargoType: CargoType.parcel,
      destinationType: DestinationType.house,
      difficulty: MissionDifficulty.easy,
      moneyReward: 250,
      xpReward: 100,
      requiredLevel: 1,
    ),
    DeliveryMission(
      id: 'food_mountain_hut_01',
      title: 'Vorräte zur Berghütte',
      description: 'Bringe Lebensmittel über schwierigeres Gelände zu einer abgelegenen Berghütte.',
      cargoType: CargoType.food,
      destinationType: DestinationType.mountainHut,
      difficulty: MissionDifficulty.medium,
      moneyReward: 400,
      xpReward: 175,
      requiredLevel: 2,
    ),
    DeliveryMission(
      id: 'building_materials_01',
      title: 'Material zur Baustelle',
      description: 'Transportiere Baumaterial zu einer Baustelle im Gelände.',
      cargoType: CargoType.buildingMaterials,
      destinationType: DestinationType.constructionSite,
      difficulty: MissionDifficulty.medium,
      moneyReward: 550,
      xpReward: 225,
      requiredLevel: 3,
    ),
    DeliveryMission(
      id: 'vehicle_parts_workshop_01',
      title: 'Ersatzteile zur Werkstatt',
      description: 'Liefere dringend benötigte Fahrzeugteile zu einer abgelegenen Werkstatt.',
      cargoType: CargoType.vehicleParts,
      destinationType: DestinationType.workshop,
      difficulty: MissionDifficulty.hard,
      moneyReward: 800,
      xpReward: 350,
      requiredLevel: 5,
    ),
  ];

  static List<DeliveryMission> unlockedMissions(int playerLevel) {
    return missions
        .where((mission) => mission.isUnlockedForLevel(playerLevel))
        .toList();
  }

  static DeliveryMission? findById(String id) {
    for (final DeliveryMission mission in missions) {
      if (mission.id == id) {
        return mission;
      }
    }

    return null;
  }
}
