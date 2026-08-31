import 'package:flame_forge2d/flame_forge2d.dart';

import 'route_definition.dart';
import 'route_section.dart';

class RouteCatalog {
  RouteCatalog._();

  /// Erste Route von Offroad Delivery.
  ///
  /// Diese Definition übernimmt die bisherige Teststrecke 1:1.
  /// Dadurch soll sich beim späteren Umstellen auf das Routensystem
  /// weder die Streckenführung noch das Fahrgefühl verändern.
  ///
  /// WICHTIGE DESIGNREGEL:
  /// Jede zukünftige Route bekommt eine eigene, bewusst entworfene
  /// Streckenführung. Andere Routen sollen nicht einfach diese Route
  /// mit einem anderen Biom oder einer anderen Optik wiederverwenden.
  static final RouteDefinition route1 = RouteDefinition(
    id: 'route_01',
    name: 'Erste Lieferroute',
    description:
        'Eine abwechslungsreiche Offroad-Lieferroute mit Hügeln, '
        'Tälern und mehreren anspruchsvolleren Abschnitten.',

    terrainControlPoints: <Vector2>[
      // ------------------------------------------
      // START / DEPOT
      // ------------------------------------------

      Vector2(-10, 8.0),
      Vector2(0, 8.0),
      Vector2(8, 8.0),
      Vector2(13, 7.9),
      Vector2(18, 7.5),
      Vector2(23, 7.9),
      Vector2(28, 8.1),

      // ------------------------------------------
      // NATÜRLICHER EINSTIEG
      // ------------------------------------------
      Vector2(34, 7.7),
      Vector2(40, 6.9),
      Vector2(46, 6.2),
      Vector2(52, 6.5),
      Vector2(58, 7.4),
      Vector2(64, 8.1),

      // ------------------------------------------
      // SPRUNG 1
      // ------------------------------------------
      Vector2(68, 7.7),
      Vector2(71, 6.8),
      Vector2(74, 5.7),
      Vector2(77, 5.0),
      Vector2(79, 4.8),
      Vector2(81, 5.0),
      Vector2(84, 6.2),
      Vector2(88, 7.8),
      Vector2(92, 8.7),

      // ------------------------------------------
      // LANGES TAL
      // ------------------------------------------
      Vector2(98, 9.1),
      Vector2(104, 8.8),
      Vector2(110, 7.9),
      Vector2(116, 6.8),
      Vector2(122, 5.8),

      // ------------------------------------------
      // SPRUNG 2
      // ------------------------------------------
      Vector2(128, 4.9),
      Vector2(133, 4.2),
      Vector2(137, 3.9),
      Vector2(140, 3.8),
      Vector2(142, 4.0),
      Vector2(145, 5.2),
      Vector2(148, 6.8),
      Vector2(152, 8.5),
      Vector2(157, 9.6),

      // ------------------------------------------
      // ERHOLUNGSABSCHNITT
      // ------------------------------------------
      Vector2(162, 9.8),
      Vector2(167, 9.1),
      Vector2(172, 8.1),

      // ------------------------------------------
      // SPRUNG 3 / TECHNISCHER BEREICH
      // ------------------------------------------
      Vector2(176, 7.0),
      Vector2(179, 5.8),
      Vector2(182, 5.0),
      Vector2(184, 4.8),
      Vector2(186, 5.2),
      Vector2(189, 6.8),
      Vector2(192, 8.1),
      Vector2(195, 7.2),
      Vector2(198, 5.9),
      Vector2(201, 5.3),
      Vector2(203, 5.5),
      Vector2(206, 6.8),
      Vector2(210, 8.6),
      Vector2(215, 9.4),

      // ------------------------------------------
      // KLEINE OFFROAD-WELLEN
      // ------------------------------------------
      Vector2(220, 8.8),
      Vector2(224, 7.6),
      Vector2(228, 8.2),
      Vector2(232, 7.4),

      // ------------------------------------------
      // SPRUNG 4
      // ------------------------------------------
      Vector2(236, 6.4),
      Vector2(240, 5.1),
      Vector2(244, 3.9),
      Vector2(248, 3.1),
      Vector2(251, 2.8),
      Vector2(253, 2.8),
      Vector2(255, 3.1),
      Vector2(257, 4.2),
      Vector2(260, 5.9),
      Vector2(264, 7.8),
      Vector2(268, 9.2),

      // ------------------------------------------
      // SANFTER AUSLAUF
      // ------------------------------------------
      Vector2(272, 9.2),
      Vector2(274, 8.7),
      Vector2(276, 8.3),

      // ------------------------------------------
      // KOMPLETT EBENER ZIELBEREICH
      // ------------------------------------------
      Vector2(278, 8.0),
      Vector2(280, 8.0),
      Vector2(284, 8.0),
      Vector2(288, 8.0),
      Vector2(292, 8.0),
      Vector2(296, 8.0),
      Vector2(300, 8.0),
      Vector2(304, 8.0),
      Vector2(308, 8.0),
      Vector2(312, 8.0),
      Vector2(316, 8.0),
    ],

    // ------------------------------------------
    // STRECKENABSCHNITTE
    // ------------------------------------------
    //
    // Diese Abschnitte beschreiben zunächst nur,
    // welcher Untergrund und welche Umgebung an
    // welcher Stelle der Route vorgesehen sind.
    //
    // Physik und Grafik werden erst später daran
    // gekoppelt.
    sections: const <RouteSection>[
      RouteSection(
        id: 'route_01_depot',
        startX: -10,
        endX: 30,
        surfaceType: SurfaceType.asphalt,
        biomeType: BiomeType.rural,
      ),

      RouteSection(
        id: 'route_01_forest_entry',
        startX: 30,
        endX: 68,
        surfaceType: SurfaceType.dirt,
        biomeType: BiomeType.forest,
      ),

      RouteSection(
        id: 'route_01_rocky_hills',
        startX: 68,
        endX: 128,
        surfaceType: SurfaceType.rock,
        biomeType: BiomeType.mountains,
      ),

      RouteSection(
        id: 'route_01_forest_valley',
        startX: 128,
        endX: 176,
        surfaceType: SurfaceType.gravel,
        biomeType: BiomeType.forest,
      ),

      RouteSection(
        id: 'route_01_technical_mountains',
        startX: 176,
        endX: 220,
        surfaceType: SurfaceType.rock,
        biomeType: BiomeType.mountains,
      ),

      RouteSection(
        id: 'route_01_muddy_fields',
        startX: 220,
        endX: 236,
        surfaceType: SurfaceType.mud,
        biomeType: BiomeType.fields,
      ),

      RouteSection(
        id: 'route_01_final_climb',
        startX: 236,
        endX: 272,
        surfaceType: SurfaceType.rock,
        biomeType: BiomeType.mountains,
      ),

      RouteSection(
        id: 'route_01_destination',
        startX: 272,
        endX: 316,
        surfaceType: SurfaceType.asphalt,
        biomeType: BiomeType.rural,
      ),
    ],

    // Das Fahrzeug startet in der bisherigen Strecke bei x = 8 / y = 5.
    vehicleStartPosition: Vector2(8, 5),

    // Bisherige Abholstation.
    pickupX: 18,
    pickupZoneHalfWidth: 1.5,

    // Bisheriges Lieferziel.
    deliveryDestinationX: 292,
    deliveryGroundY: 8,

    // Bisherige Lieferzone:
    // x = 287 bis x = 291.
    deliveryZoneCenterX: 289,
    deliveryZoneHalfWidth: 2,

    deliveryMaxSpeed: 1,
  );

  /// Alle aktuell bekannten Routen.
  ///
  /// Später werden hier weitere individuell gestaltete Routen ergänzt.
  static final List<RouteDefinition> routes = <RouteDefinition>[route1];

  /// Sucht eine Route anhand ihrer eindeutigen ID.
  static RouteDefinition? findById(String id) {
    for (final RouteDefinition route in routes) {
      if (route.id == id) {
        return route;
      }
    }

    return null;
  }
}
