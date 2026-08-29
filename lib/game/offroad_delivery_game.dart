import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/delivery_vehicle.dart';
import 'components/parallax_background_component.dart';
import 'components/roadside_scenery_component.dart';
import 'components/terrain_component.dart';

enum DeliveryRoute {
  none,
  safe,
  risk,
}

class OffroadDeliveryGame extends FlameGame {
  static const double worldWidth = 3600;

  late final World gameWorld;

  late final ParallaxBackgroundComponent parallaxBackground;
  late final TerrainComponent terrain;
  late final RoadsideSceneryComponent roadsideScenery;
  late final DeliveryVehicle vehicle;

  late final RectangleComponent depot;
  late final RectangleComponent customer;

  late final TextComponent depotLabel;
  late final TextComponent customerLabel;

  late final RectangleComponent depotCargo;

  late final RectangleComponent routeMarker;
  late final TextComponent routeMarkerLabel;

  final ValueNotifier<String> missionNotifier =
      ValueNotifier<String>(
    'Auftrag: Paket beim Depot abholen',
  );

  final ValueNotifier<bool> routeChoiceNotifier =
      ValueNotifier<bool>(false);

  final ValueNotifier<String> routeNotifier =
      ValueNotifier<String>(
    'Keine Route gewählt',
  );

  double _speed = 0;
  double _throttle = 0;

  bool _cargoLoaded = false;
  bool _missionCompleted = false;
  bool _routeChoiceShown = false;

  DeliveryRoute _selectedRoute =
      DeliveryRoute.none;

  static const double _acceleration = 420;
  static const double _brakingAcceleration = 600;
  static const double _friction = 220;

  static const double _maximumForwardSpeed = 500;
  static const double _maximumReverseSpeed = -180;

  static const double _slopeInfluence = 260;

  static const double _routeChoiceX = 1450;

  @override
  Color backgroundColor() {
    return const Color(0xFF87B7D9);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    gameWorld = World();
    add(gameWorld);

    camera = CameraComponent.withFixedResolution(
      world: gameWorld,
      width: 900,
      height: 400,
    );

    add(camera);

    parallaxBackground =
        ParallaxBackgroundComponent(
      worldWidth: worldWidth,
    );

    terrain = TerrainComponent(
      worldWidth: worldWidth,
    );

    roadsideScenery =
        RoadsideSceneryComponent(
      terrain: terrain,
      worldWidth: worldWidth,
    );

    const double depotX = 60;

    final double depotGroundY =
        terrain.getGroundY(
      depotX + 50,
    );

    depot = RectangleComponent(
      position: Vector2(
        depotX,
        depotGroundY - 100,
      ),
      size: Vector2(
        100,
        100,
      ),
      paint: Paint()
        ..color = const Color(0xFF56616A),
    );

    depotLabel = TextComponent(
      text: 'DEPOT',
      position: Vector2(
        depotX + 18,
        depotGroundY - 130,
      ),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    depotCargo = RectangleComponent(
      position: Vector2(
        depotX + 55,
        depotGroundY - 22,
      ),
      size: Vector2(
        26,
        22,
      ),
      paint: Paint()
        ..color = const Color(0xFFD69A4A),
    );

    const double customerX =
        worldWidth - 180;

    final double customerGroundY =
        terrain.getGroundY(
      customerX + 50,
    );

    customer = RectangleComponent(
      position: Vector2(
        customerX,
        customerGroundY - 90,
      ),
      size: Vector2(
        100,
        90,
      ),
      paint: Paint()
        ..color = const Color(0xFFB66A45),
    );

    customerLabel = TextComponent(
      text: 'KUNDE',
      position: Vector2(
        customerX + 10,
        customerGroundY - 120,
      ),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final double routeGroundY =
        terrain.getGroundY(
      _routeChoiceX,
    );

    routeMarker = RectangleComponent(
      position: Vector2(
        _routeChoiceX,
        routeGroundY - 70,
      ),
      size: Vector2(
        12,
        70,
      ),
      paint: Paint()
        ..color = const Color(0xFFFFC107),
    );

    routeMarkerLabel = TextComponent(
      text: 'ROUTENWAHL',
      position: Vector2(
        _routeChoiceX - 50,
        routeGroundY - 100,
      ),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    const double vehicleStartX = 185;

    final double vehicleGroundY =
        terrain.getGroundY(
      vehicleStartX + 62.5,
    );

    vehicle = DeliveryVehicle(
      position: Vector2(
        vehicleStartX,
        vehicleGroundY - 65,
      ),
    );

    await gameWorld.addAll([
      parallaxBackground,
      terrain,
      roadsideScenery,
      depot,
      depotLabel,
      depotCargo,
      customer,
      customerLabel,
      routeMarker,
      routeMarkerLabel,
      vehicle,
    ]);

    _updateVehicleTerrainPosition();
    _updateParallaxBackground();

    camera.follow(
      vehicle,
      horizontalOnly: true,
      snap: true,
    );
  }

  void setThrottle(double value) {
    if (_routeChoiceShown ||
        _missionCompleted) {
      _throttle = 0;
      return;
    }

    _throttle =
        value.clamp(-1.0, 1.0);
  }

  void selectSafeRoute() {
    if (!_routeChoiceShown) {
      return;
    }

    _selectedRoute =
        DeliveryRoute.safe;

    terrain.selectSafeRoute();

    _routeChoiceShown = false;

    routeChoiceNotifier.value = false;

    routeNotifier.value =
        'Sichere Route • Belohnung ×1,0';

    missionNotifier.value =
        'Sichere Route gewählt – bringe die Lieferung zum Kunden!';

    _updateVehicleTerrainPosition();
  }

  void selectRiskRoute() {
    if (!_routeChoiceShown) {
      return;
    }

    _selectedRoute =
        DeliveryRoute.risk;

    terrain.selectRiskRoute();

    _routeChoiceShown = false;

    routeChoiceNotifier.value = false;

    routeNotifier.value =
        'Risikoroute • Belohnung ×1,5';

    missionNotifier.value =
        'Risikoroute gewählt – erhöhte Belohnung!';

    _updateVehicleTerrainPosition();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_missionCompleted ||
        _routeChoiceShown) {
      _applyFriction(dt);
    } else if (_throttle > 0) {
      _speed +=
          _acceleration *
          _throttle *
          dt;
    } else if (_throttle < 0) {
      _speed +=
          _brakingAcceleration *
          _throttle *
          dt;
    } else {
      _applyFriction(dt);
    }

    _applySlopeEffect(dt);

    _speed = _speed.clamp(
      _maximumReverseSpeed,
      _maximumForwardSpeed,
    );

    final double movement =
        _speed * dt;

    vehicle.position.x += movement;

    _keepVehicleInsideWorld();
    _updateVehicleTerrainPosition();
    _updateParallaxBackground();

    _checkCargoPickup();
    _checkRouteChoice();
    _checkMissionCompletion();
  }

  void _updateParallaxBackground() {
    final double vehicleCenterX =
        vehicle.position.x +
            (vehicle.size.x / 2);

    parallaxBackground
        .updateCameraPosition(
      vehicleCenterX,
    );
  }

  void _applySlopeEffect(double dt) {
    if (_routeChoiceShown ||
        _missionCompleted) {
      return;
    }

    final double vehicleCenterX =
        vehicle.position.x +
            (vehicle.size.x / 2);

    final double groundAngle =
        terrain.getGroundAngle(
      vehicleCenterX,
    );

    final double slopeForce =
        groundAngle *
            _slopeInfluence;

    if (_speed > 0) {
      _speed +=
          slopeForce * dt;
    } else if (_speed < 0) {
      _speed -=
          slopeForce * dt;
    }
  }

  void _updateVehicleTerrainPosition() {
    final double vehicleCenterX =
        vehicle.position.x +
            (vehicle.size.x / 2);

    final double groundY =
        terrain.getGroundY(
      vehicleCenterX,
    );

    final double groundAngle =
        terrain.getGroundAngle(
      vehicleCenterX,
    );

    vehicle.position.y =
        groundY - 65;

    vehicle.angle =
        groundAngle;
  }

  void _checkCargoPickup() {
    if (_cargoLoaded) {
      return;
    }

    if (vehicle.position.x <= 160) {
      _cargoLoaded = true;

      depotCargo.removeFromParent();

      vehicle.showCargo();

      missionNotifier.value =
          'Lieferung geladen – bringe sie zum Kunden!';
    }
  }

  void _checkRouteChoice() {
    if (!_cargoLoaded ||
        _missionCompleted ||
        _routeChoiceShown ||
        _selectedRoute !=
            DeliveryRoute.none) {
      return;
    }

    if (vehicle.position.x >=
        _routeChoiceX - 180) {
      _routeChoiceShown = true;

      _throttle = 0;
      _speed = 0;

      routeChoiceNotifier.value =
          true;

      missionNotifier.value =
          'ROUTENWAHL – welchen Weg möchtest du nehmen?';
    }
  }

  void _checkMissionCompletion() {
    if (!_cargoLoaded ||
        _missionCompleted) {
      return;
    }

    if (vehicle.position.x +
            vehicle.size.x >=
        customer.position.x) {
      _missionCompleted = true;

      _throttle = 0;

      final int reward;

      switch (_selectedRoute) {
        case DeliveryRoute.risk:
          reward = 150;

        case DeliveryRoute.safe:
        case DeliveryRoute.none:
          reward = 100;
      }

      missionNotifier.value =
          'LIEFERUNG ERFOLGREICH! +$reward €';
    }
  }

  void _applyFriction(double dt) {
    if (_speed > 0) {
      _speed -=
          _friction * dt;

      if (_speed < 0) {
        _speed = 0;
      }
    } else if (_speed < 0) {
      _speed +=
          _friction * dt;

      if (_speed > 0) {
        _speed = 0;
      }
    }
  }

  void _keepVehicleInsideWorld() {
    const double minimumX = 20;

    final double maximumX =
        worldWidth -
            vehicle.size.x -
            20;

    if (vehicle.position.x <
        minimumX) {
      vehicle.position.x =
          minimumX;

      _speed = 0;
    }

    if (vehicle.position.x >
        maximumX) {
      vehicle.position.x =
          maximumX;

      _speed = 0;
    }
  }

  @override
  void onRemove() {
    missionNotifier.dispose();
    routeChoiceNotifier.dispose();
    routeNotifier.dispose();

    super.onRemove();
  }
}