import 'package:flame_forge2d/flame_forge2d.dart';

import 'route_section.dart';

/// Beschreibt eine komplette fahrbare Route in Offroad Delivery.
///
/// Eine Route besitzt ihr eigenes Terrain sowie individuell festgelegte
/// Streckenabschnitte. Dadurch kann eine einzelne Route später mehrere
/// unterschiedliche Umgebungen und Untergründe enthalten.
///
/// Zusätzlich enthält die Route die Positionen für Fahrzeugstart,
/// Abholstation und Lieferziel.
///
/// Später können hier weitere Eigenschaften ergänzt werden, zum Beispiel:
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
    required this.sections,
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

  /// Kontrollpunkte, aus denen das Gelände erzeugt wird.
  ///
  /// Zwischen diesen Punkten erzeugt PhysicsTerrain weiterhin
  /// die geglättete Fahrbahn.
  final List<Vector2> terrainControlPoints;

  /// Individuell festgelegte Abschnitte dieser Route.
  ///
  /// Jeder Abschnitt beschreibt einen bestimmten Bereich der Route
  /// mit eigenem Untergrund und eigener Umgebung.
  ///
  /// Beispiel:
  /// Wald + Erde
  /// Wald + Schotter
  /// Berge + Fels
  /// ländlicher Bereich + Asphalt
  ///
  /// Diese Abschnitte werden nicht automatisch erzeugt.
  /// Jede Route wird von uns bewusst und individuell aufgebaut.
  final List<RouteSection> sections;

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

  /// Gibt den Streckenabschnitt zurück, in dem sich
  /// die angegebene X-Position befindet.
  ///
  /// Falls die Position keinem Abschnitt zugeordnet ist,
  /// wird null zurückgegeben.
  RouteSection? sectionAtX(double x) {
    for (final RouteSection section in sections) {
      if (section.containsX(x)) {
        return section;
      }
    }

    return null;
  }
}
