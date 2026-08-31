import 'package:flame_forge2d/flame_forge2d.dart';

/// Beschreibt eine komplette fahrbare Route in Offroad Delivery.
///
/// Die Route enthält zunächst nur die grundlegenden Informationen,
/// die wir für Terrain, Fahrzeugstart, Abholstation und Lieferziel
/// benötigen.
///
/// Später können hier weitere Eigenschaften ergänzt werden, zum Beispiel:
/// - Biom / Umgebung
/// - Wetter
/// - Tageszeit
/// - Routenschwierigkeit
/// - geheime Strecken
/// - Freischaltbedingungen
class RouteDefinition {
  const RouteDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.terrainControlPoints,
    required this.vehicleStartPosition,
    required this.pickupX,
    required this.pickupZoneHalfWidth,
    required this.deliveryDestinationX,
    required this.deliveryGroundY,
    required this.deliveryZoneCenterX,
    required this.deliveryZoneHalfWidth,
    required this.deliveryMaxSpeed,
  });

  /// Eindeutige interne ID der Route.
  ///
  /// Beispiel:
  /// forest_route_01
  final String id;

  /// Anzeigename der Route.
  ///
  /// Beispiel:
  /// Waldpass
  final String name;

  /// Kurze Beschreibung der Route.
  final String description;

  /// Kontrollpunkte, aus denen später das Gelände erzeugt wird.
  ///
  /// Zwischen diesen Punkten erzeugt PhysicsTerrain weiterhin
  /// die geglättete Fahrbahn.
  final List<Vector2> terrainControlPoints;

  /// Startposition des Fahrzeugs.
  final Vector2 vehicleStartPosition;

  /// X-Position der Abholstation.
  final double pickupX;

  /// Größe der Abholzone links und rechts von [pickupX].
  final double pickupZoneHalfWidth;

  /// Position des sichtbaren Lieferziels.
  final double deliveryDestinationX;

  /// Bodenhöhe des Lieferziels.
  final double deliveryGroundY;

  /// Mittelpunkt der tatsächlichen Lieferzone.
  final double deliveryZoneCenterX;

  /// Größe der Lieferzone links und rechts vom Mittelpunkt.
  final double deliveryZoneHalfWidth;

  /// Maximale Geschwindigkeit, mit der das Fahrzeug
  /// die Lieferung abschließen darf.
  final double deliveryMaxSpeed;

  double get pickupZoneStartX => pickupX - pickupZoneHalfWidth;

  double get pickupZoneEndX => pickupX + pickupZoneHalfWidth;

  double get deliveryZoneStartX => deliveryZoneCenterX - deliveryZoneHalfWidth;

  double get deliveryZoneEndX => deliveryZoneCenterX + deliveryZoneHalfWidth;
}
