import 'package:flame_forge2d/flame_forge2d.dart';

import 'route_definition.dart';
import 'route_section.dart';

class RouteCatalog {
  RouteCatalog._();

  // ==================================================
  // ROUTE 1
  // ==================================================

  /// Erste Route von Offroad Delivery.
  ///
  /// Die ursprüngliche Teststrecke bleibt unverändert erhalten.
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

    vehicleStartPosition: Vector2(8, 5),

    pickupX: 18,
    pickupZoneHalfWidth: 1.5,

    deliveryDestinationX: 292,
    deliveryGroundY: 8,

    deliveryZoneCenterX: 289,
    deliveryZoneHalfWidth: 2,

    deliveryMaxSpeed: 1,
  );

  // ==================================================
  // ROUTE 2 – BERGHÜTTE
  // ==================================================

  /// Zweite individuell entworfene Route.
  ///
  /// Diese Strecke führt vom Depot zunächst über eine ruhige
  /// asphaltierte Straße, danach durch einen längeren Waldabschnitt
  /// und schließlich über einen anspruchsvollen Bergweg zur Hütte.
  ///
  /// Der Charakter unterscheidet sich bewusst von Route 1:
  ///
  /// - weniger klassische Sprunghügel
  /// - längere zusammenhängende Steigungen
  /// - Wald- und Schotterpassagen
  /// - schlammiger Bergfuß
  /// - steiler technischer Schlussanstieg
  /// - höher gelegenes Lieferziel
  static final RouteDefinition route2 = RouteDefinition(
    id: 'route_02',
    name: 'Weg zur Berghütte',
    description:
        'Eine Berglieferroute durch Wald, Schlamm und felsiges '
        'Gebirge bis zu einer abgelegenen Berghütte.',

    terrainControlPoints: <Vector2>[
      // ------------------------------------------
      // DEPOT / DORFRAND
      // ------------------------------------------
      //
      // Ruhiger und relativ ebener Start.
      // Der Spieler kann das Fahrzeug zunächst
      // kontrolliert in Bewegung bringen.

      Vector2(-10, 9.0),
      Vector2(0, 9.0),
      Vector2(8, 9.0),
      Vector2(14, 8.9),
      Vector2(20, 8.8),
      Vector2(26, 8.9),
      Vector2(32, 9.0),

      // ------------------------------------------
      // LANDSTRASSE
      // ------------------------------------------
      //
      // Sanfte, längere Wellen statt Sprüngen.
      Vector2(38, 8.7),
      Vector2(44, 8.3),
      Vector2(50, 7.9),
      Vector2(56, 8.0),
      Vector2(62, 8.4),
      Vector2(68, 8.7),

      // ------------------------------------------
      // WALDEINFAHRT
      // ------------------------------------------
      //
      // Der Weg beginnt langsam anzusteigen.
      Vector2(74, 8.5),
      Vector2(80, 8.0),
      Vector2(86, 7.4),
      Vector2(92, 6.8),
      Vector2(98, 6.3),
      Vector2(104, 6.0),

      // ------------------------------------------
      // WALD-SCHOTTERWEG
      // ------------------------------------------
      //
      // Langer, unruhiger Anstieg.
      // Kleine Bodenwellen statt großer Sprünge.
      Vector2(110, 5.8),
      Vector2(116, 6.2),
      Vector2(122, 5.6),
      Vector2(128, 5.9),
      Vector2(134, 5.2),
      Vector2(140, 5.5),
      Vector2(146, 4.8),
      Vector2(152, 5.0),

      // ------------------------------------------
      // KURZE WALDSENKE
      // ------------------------------------------
      Vector2(158, 5.7),
      Vector2(164, 6.5),
      Vector2(170, 6.9),
      Vector2(176, 6.6),

      // ------------------------------------------
      // SCHLAMMIGER BERGFUSS
      // ------------------------------------------
      //
      // Hier soll der Spieler erstmals deutlich
      // gegen den Schlamm arbeiten müssen.
      Vector2(182, 6.3),
      Vector2(188, 6.5),
      Vector2(194, 6.1),
      Vector2(200, 6.4),
      Vector2(206, 5.9),
      Vector2(212, 5.6),

      // ------------------------------------------
      // BEGINN DES BERGPASSES
      // ------------------------------------------
      //
      // Die Steigung nimmt jetzt deutlich zu.
      Vector2(218, 5.0),
      Vector2(224, 4.3),
      Vector2(230, 3.6),
      Vector2(236, 3.0),
      Vector2(242, 2.5),

      // ------------------------------------------
      // TECHNISCHER FELSPASS
      // ------------------------------------------
      //
      // Kürzere Abstände zwischen den Punkten
      // erzeugen einen technischeren Bereich.
      Vector2(247, 2.2),
      Vector2(251, 2.7),
      Vector2(255, 2.0),
      Vector2(259, 2.5),
      Vector2(263, 1.7),
      Vector2(267, 2.1),
      Vector2(271, 1.4),
      Vector2(275, 1.8),

      // ------------------------------------------
      // STEILER SCHLUSSANSTIEG
      // ------------------------------------------
      Vector2(279, 1.3),
      Vector2(283, 0.7),
      Vector2(287, 0.1),
      Vector2(291, -0.4),
      Vector2(295, -0.8),

      // ------------------------------------------
      // BERGKAMM
      // ------------------------------------------
      //
      // Nach dem steilen Aufstieg wird die Strecke
      // wieder etwas ruhiger.
      Vector2(300, -1.0),
      Vector2(305, -0.8),
      Vector2(310, -0.5),
      Vector2(315, -0.7),

      // ------------------------------------------
      // BERGHÜTTE / ZIELBEREICH
      // ------------------------------------------
      //
      // Der Zielbereich ist bewusst flach,
      // damit die Lieferung zuverlässig erkannt wird.
      Vector2(320, -0.8),
      Vector2(324, -0.8),
      Vector2(328, -0.8),
      Vector2(332, -0.8),
      Vector2(336, -0.8),
      Vector2(340, -0.8),
      Vector2(344, -0.8),
      Vector2(348, -0.8),
    ],

    // ------------------------------------------
    // STRECKENABSCHNITTE ROUTE 2
    // ------------------------------------------
    sections: const <RouteSection>[
      // Depot und Dorfrand.
      RouteSection(
        id: 'route_02_depot',
        startX: -10,
        endX: 36,
        surfaceType: SurfaceType.asphalt,
        biomeType: BiomeType.rural,
      ),

      // Asphaltierte Landstraße.
      RouteSection(
        id: 'route_02_country_road',
        startX: 36,
        endX: 70,
        surfaceType: SurfaceType.asphalt,
        biomeType: BiomeType.fields,
      ),

      // Erste unbefestigte Waldeinfahrt.
      RouteSection(
        id: 'route_02_forest_entry',
        startX: 70,
        endX: 108,
        surfaceType: SurfaceType.dirt,
        biomeType: BiomeType.forest,
      ),

      // Längerer Schotterweg durch den Wald.
      RouteSection(
        id: 'route_02_forest_gravel_climb',
        startX: 108,
        endX: 178,
        surfaceType: SurfaceType.gravel,
        biomeType: BiomeType.forest,
      ),

      // Schlammiger Bereich am Bergfuß.
      RouteSection(
        id: 'route_02_muddy_foothills',
        startX: 178,
        endX: 214,
        surfaceType: SurfaceType.mud,
        biomeType: BiomeType.forest,
      ),

      // Beginn des Bergpasses.
      RouteSection(
        id: 'route_02_mountain_climb',
        startX: 214,
        endX: 246,
        surfaceType: SurfaceType.rock,
        biomeType: BiomeType.mountains,
      ),

      // Technischster Teil der Route.
      RouteSection(
        id: 'route_02_rock_pass',
        startX: 246,
        endX: 278,
        surfaceType: SurfaceType.rock,
        biomeType: BiomeType.mountains,
      ),

      // Steiler Schlussanstieg.
      RouteSection(
        id: 'route_02_final_climb',
        startX: 278,
        endX: 300,
        surfaceType: SurfaceType.rock,
        biomeType: BiomeType.mountains,
      ),

      // Bergkamm und Zufahrt zur Hütte.
      RouteSection(
        id: 'route_02_mountain_ridge',
        startX: 300,
        endX: 320,
        surfaceType: SurfaceType.gravel,
        biomeType: BiomeType.mountains,
      ),

      // Flacher Zielbereich an der Berghütte.
      RouteSection(
        id: 'route_02_mountain_hut',
        startX: 320,
        endX: 348,
        surfaceType: SurfaceType.gravel,
        biomeType: BiomeType.mountains,
      ),
    ],

    // Fahrzeugstart am Depot.
    vehicleStartPosition: Vector2(8, 6),

    // Abholstation am Anfang der Route.
    pickupX: 20,
    pickupZoneHalfWidth: 1.5,

    // Die Berghütte liegt deutlich höher als
    // der Startpunkt der Route.
    deliveryDestinationX: 340,
    deliveryGroundY: -0.8,

    // Flache Lieferzone vor der Berghütte.
    deliveryZoneCenterX: 336,
    deliveryZoneHalfWidth: 2,

    deliveryMaxSpeed: 1,
  );

  // ==================================================
  // ROUTENLISTE
  // ==================================================

  /// Alle aktuell bekannten Routen.
  static final List<RouteDefinition> routes = <RouteDefinition>[route1, route2];

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
