enum SurfaceType { asphalt, gravel, dirt, mud, rock }

enum BiomeType { forest, fields, mountains, quarry, industrial, rural }

class RouteSection {
  const RouteSection({
    required this.id,
    required this.startX,
    required this.endX,
    required this.surfaceType,
    required this.biomeType,
  }) : assert(endX > startX);

  /// Eindeutige ID dieses Streckenabschnitts.
  ///
  /// Beispiel:
  /// forest_gravel_01
  final String id;

  /// X-Position, an der dieser Abschnitt beginnt.
  final double startX;

  /// X-Position, an der dieser Abschnitt endet.
  final double endX;

  /// Untergrund dieses Streckenabschnitts.
  ///
  /// Später kann dieser Wert unter anderem beeinflussen:
  /// - Grip
  /// - Rollwiderstand
  /// - Beschleunigung
  /// - Bremsverhalten
  /// - Partikeleffekte
  final SurfaceType surfaceType;

  /// Umgebung dieses Streckenabschnitts.
  ///
  /// Später kann dieser Wert unter anderem bestimmen:
  /// - Hintergrund
  /// - Vegetation
  /// - Gebäude
  /// - Dekoration
  /// - Hindernisse
  final BiomeType biomeType;

  /// Länge des Streckenabschnitts.
  double get length => endX - startX;

  /// Prüft, ob sich eine bestimmte X-Position
  /// innerhalb dieses Streckenabschnitts befindet.
  bool containsX(double x) {
    return x >= startX && x <= endX;
  }
}
