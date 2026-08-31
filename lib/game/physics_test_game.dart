import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import '../missions/delivery_mission.dart';
import '../routes/route_catalog.dart';
import '../routes/route_definition.dart';
import '../routes/route_section.dart';
import 'components/physics_vehicle.dart';
import 'components/physics_wheel.dart';

class PhysicsTestGame extends Forge2DGame {
  PhysicsTestGame({
    required this.mission,
    RouteDefinition? route,
    this.onPickupStationReached,
    this.onCargoPickedUp,
    this.onCargoConditionChanged,
    this.onDeliveryCompleted,
    this.onMissionFailed,
  }) : route = route ?? RouteCatalog.route1,
       super(
         gravity: Vector2(0, 9.81),
         metersToPixels: 32,
         camera: CameraComponent.withFixedResolution(width: 900, height: 400),
       );

  final DeliveryMission mission;

  /// Individuell gestaltete Route, die für diese Mission gefahren wird.
  final RouteDefinition route;

  final VoidCallback? onPickupStationReached;
  final VoidCallback? onCargoPickedUp;

  final void Function(double cargoConditionPercent)? onCargoConditionChanged;

  final void Function(int moneyReward, int xpReward)? onDeliveryCompleted;

  final VoidCallback? onMissionFailed;

  late final PhysicsVehicle vehicle;
  late final PhysicsWheel rearWheel;
  late final PhysicsWheel frontWheel;

  late final WheelJoint rearWheelJoint;
  late final WheelJoint frontWheelJoint;

  late final PhysicsTerrain terrain;

  bool _pickupStationReached = false;
  bool _cargoPickedUp = false;
  bool _deliveryCompleted = false;
  bool _missionFailed = false;

  bool get cargoPickedUp => _cargoPickedUp;

  double _throttle = 0;

  // ------------------------------------------
  // AKTUELLER STRECKENABSCHNITT
  // ------------------------------------------

  RouteSection? _currentRouteSection;

  RouteSection? get currentRouteSection => _currentRouteSection;

  SurfaceType? get currentSurfaceType => _currentRouteSection?.surfaceType;

  BiomeType? get currentBiomeType => _currentRouteSection?.biomeType;

  // ------------------------------------------
  // UNTERGRUNDPHYSIK
  // ------------------------------------------

  /// Bestimmt, wie stark der Motor auf dem aktuellen
  /// Untergrund seine Leistung auf die Straße bringt.
  ///
  /// Asphalt ist unsere Referenz mit 100 %.
  double get _surfaceMotorMultiplier {
    switch (currentSurfaceType) {
      case SurfaceType.asphalt:
        return 1.00;

      case SurfaceType.gravel:
        return 0.92;

      case SurfaceType.dirt:
        return 0.87;

      case SurfaceType.mud:
        return 0.68;

      case SurfaceType.rock:
        return 0.95;

      case null:
        return 1.00;
    }
  }

  /// Zusätzlicher Rollwiderstand des Untergrunds.
  ///
  /// Ein höherer Wert sorgt dafür, dass das Fahrzeug
  /// beim Loslassen des Pedals schneller Geschwindigkeit verliert.
  double get _surfaceCoastBrakeMultiplier {
    switch (currentSurfaceType) {
      case SurfaceType.asphalt:
        return 1.00;

      case SurfaceType.gravel:
        return 1.15;

      case SurfaceType.dirt:
        return 1.30;

      case SurfaceType.mud:
        return 2.20;

      case SurfaceType.rock:
        return 1.10;

      case null:
        return 1.00;
    }
  }

  // ------------------------------------------
  // LADUNGSZUSTAND / LANDUNGEN
  // ------------------------------------------

  double _cargoConditionPercent = 100.0;

  bool _wasAirborne = false;

  double _maximumAirborneDownwardSpeed = 0.0;

  double _airborneTime = 0.0;

  static const double _minimumAirborneTimeForLanding = 0.18;

  static const double _airborneGroundClearance = 0.12;

  static const double _lightLandingSpeed = 4.5;
  static const double _hardLandingSpeed = 6.0;
  static const double _extremeLandingSpeed = 8.0;

  // ------------------------------------------
  // ÜBERSCHLAG / MISSIONSFEHLSCHLAG
  // ------------------------------------------

  static const double _rolloverAngleDegrees = 70.0;

  static const double _rolloverMaximumLinearSpeed = 1.5;

  static const double _rolloverFailureTime = 2.5;

  double _rolloverStuckTime = 0.0;

  // ------------------------------------------
  // FAHRZEUGSTEUERUNG
  // ------------------------------------------

  static const double _motorSpeed = 26;
  static const double _motorTorque = 60;

  static const double _directionChangeSpeed = 0.75;
  static const double _brakeStrength = 8.0;
  static const double _coastBrakeStrength = 1.2;

  static const double _rearWheelX = -1.45;
  static const double _frontWheelX = 1.45;
  static const double _wheelY = 1.0;

  // ------------------------------------------
  // LUFTSTEUERUNG
  // ------------------------------------------

  static const double _airControlTorque = 32.0;
  static const double _maxAirAngularVelocity = 3.4;

  @override
  Color backgroundColor() {
    return const Color(0xFF87B7D9);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final PhysicsLandscape landscape = PhysicsLandscape();

    terrain = PhysicsTerrain(controlPoints: route.terrainControlPoints);

    final double pickupGroundY = terrain.getTerrainY(route.pickupX);

    final PickupStation pickupStation = PickupStation(
      position: Vector2(route.pickupX, pickupGroundY),
    );

    final PositionComponent deliveryDestination = _createDeliveryDestination();

    final Vector2 startPosition = route.vehicleStartPosition;

    vehicle = PhysicsVehicle(
      startPosition: Vector2(startPosition.x, startPosition.y),
    );

    rearWheel = PhysicsWheel(
      startPosition: Vector2(
        startPosition.x + _rearWheelX,
        startPosition.y + _wheelY,
      ),
    );

    frontWheel = PhysicsWheel(
      startPosition: Vector2(
        startPosition.x + _frontWheelX,
        startPosition.y + _wheelY,
      ),
    );

    await world.add(landscape);
    await world.add(terrain);
    await world.add(pickupStation);
    await world.add(deliveryDestination);
    await world.add(vehicle);
    await world.add(rearWheel);
    await world.add(frontWheel);

    _createSuspension();

    _updateCurrentRouteSection(startPosition.x);

    camera.viewfinder.position = Vector2(
      startPosition.x + 4,
      startPosition.y + 1,
    );
  }

  PositionComponent _createDeliveryDestination() {
    final Vector2 position = Vector2(
      route.deliveryDestinationX,
      route.deliveryGroundY,
    );

    switch (mission.destinationType) {
      case DestinationType.house:
        return DeliveryHouse(position: position);

      case DestinationType.mountainHut:
        return DeliveryMountainHut(position: position);

      case DestinationType.constructionSite:
        return DeliveryConstructionSite(position: position);

      case DestinationType.workshop:
        return DeliveryWorkshop(position: position);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!vehicle.isMounted) {
      return;
    }

    final double vehicleX = vehicle.body.position.x;
    final double vehicleY = vehicle.body.position.y;

    camera.viewfinder.position = Vector2(vehicleX + 5, vehicleY + 0.5);

    _updateCurrentRouteSection(vehicleX);

    if (_missionFailed) {
      return;
    }

    _updateDrivePhysics(dt);

    _updateAirControl();

    _updateLandingDetection(dt);

    _updateRolloverDetection(dt);

    if (_missionFailed) {
      return;
    }

    _checkPickup(vehicleX);

    _checkDelivery(vehicleX);
  }

  // ------------------------------------------
  // STRECKENABSCHNITT
  // ------------------------------------------

  void _updateCurrentRouteSection(double vehicleX) {
    final RouteSection? section = route.sectionAtX(vehicleX);

    if (identical(section, _currentRouteSection)) {
      return;
    }

    _currentRouteSection = section;
  }

  // ------------------------------------------
  // FAHRPHYSIK
  // ------------------------------------------

  void _updateDrivePhysics(double dt) {
    final double horizontalSpeed = vehicle.body.linearVelocity.x;

    final double currentMotorSpeed = _motorSpeed * _surfaceMotorMultiplier;

    if (_throttle == 0) {
      rearWheelJoint.motorSpeed = 0;

      _applyHorizontalBrake(
        _coastBrakeStrength * _surfaceCoastBrakeMultiplier,
        dt,
      );

      return;
    }

    if (_throttle > 0) {
      if (horizontalSpeed < -_directionChangeSpeed) {
        rearWheelJoint.motorSpeed = 0;

        _applyHorizontalBrake(_brakeStrength, dt);

        return;
      }

      rearWheelJoint.motorSpeed = currentMotorSpeed;

      return;
    }

    if (_throttle < 0) {
      if (horizontalSpeed > _directionChangeSpeed) {
        rearWheelJoint.motorSpeed = 0;

        _applyHorizontalBrake(_brakeStrength, dt);

        return;
      }

      rearWheelJoint.motorSpeed = -currentMotorSpeed;
    }
  }

  void _applyHorizontalBrake(double strength, double dt) {
    final Vector2 velocity = vehicle.body.linearVelocity;

    final double horizontalSpeed = velocity.x;

    if (horizontalSpeed.abs() < 0.05) {
      vehicle.body.linearVelocity = Vector2(0, velocity.y);

      return;
    }

    final double brakingAmount = strength * dt;

    double newHorizontalSpeed = horizontalSpeed;

    if (horizontalSpeed > 0) {
      newHorizontalSpeed = (horizontalSpeed - brakingAmount).clamp(
        0.0,
        double.infinity,
      );
    } else {
      newHorizontalSpeed = (horizontalSpeed + brakingAmount).clamp(
        double.negativeInfinity,
        0.0,
      );
    }

    vehicle.body.linearVelocity = Vector2(newHorizontalSpeed, velocity.y);
  }

  // ------------------------------------------
  // LUFTSTEUERUNG
  // ------------------------------------------

  void _updateAirControl() {
    if (_throttle == 0) {
      return;
    }

    if (!_isVehicleAirborne()) {
      return;
    }

    final double angularVelocity = vehicle.body.angularVelocity;

    if (_throttle > 0) {
      if (angularVelocity <= -_maxAirAngularVelocity) {
        return;
      }

      vehicle.body.applyTorque(-_airControlTorque);

      return;
    }

    if (_throttle < 0) {
      if (angularVelocity >= _maxAirAngularVelocity) {
        return;
      }

      vehicle.body.applyTorque(_airControlTorque);
    }
  }

  bool _isVehicleAirborne() {
    final Vector2 rearPosition = rearWheel.body.position;

    final Vector2 frontPosition = frontWheel.body.position;

    final double rearGroundY = terrain.getTerrainY(rearPosition.x);

    final double frontGroundY = terrain.getTerrainY(frontPosition.x);

    final double rearWheelBottom = rearPosition.y + rearWheel.radius;

    final double frontWheelBottom = frontPosition.y + frontWheel.radius;

    final double rearClearance = rearGroundY - rearWheelBottom;

    final double frontClearance = frontGroundY - frontWheelBottom;

    return rearClearance > _airborneGroundClearance &&
        frontClearance > _airborneGroundClearance;
  }

  // ------------------------------------------
  // LANDUNGSERKENNUNG
  // ------------------------------------------

  void _updateLandingDetection(double dt) {
    final bool airborne = _isVehicleAirborne();

    if (airborne) {
      _airborneTime += dt;

      final double downwardSpeed = vehicle.body.linearVelocity.y;

      if (downwardSpeed > _maximumAirborneDownwardSpeed) {
        _maximumAirborneDownwardSpeed = downwardSpeed;
      }

      _wasAirborne = true;

      return;
    }

    if (!_wasAirborne) {
      _airborneTime = 0;
      _maximumAirborneDownwardSpeed = 0;

      return;
    }

    final double airborneTime = _airborneTime;

    final double impactSpeed = _maximumAirborneDownwardSpeed;

    _wasAirborne = false;
    _airborneTime = 0;
    _maximumAirborneDownwardSpeed = 0;

    if (airborneTime < _minimumAirborneTimeForLanding) {
      return;
    }

    if (!_cargoPickedUp || _deliveryCompleted || _missionFailed) {
      return;
    }

    _handleLanding(impactSpeed);
  }

  void _handleLanding(double impactSpeed) {
    if (impactSpeed < _lightLandingSpeed) {
      return;
    }

    double baseDamage;

    if (impactSpeed < _hardLandingSpeed) {
      baseDamage = 3.0;
    } else if (impactSpeed < _extremeLandingSpeed) {
      baseDamage = 8.0;
    } else {
      baseDamage = 15.0 + ((impactSpeed - _extremeLandingSpeed) * 3.0);
    }

    final double angleDamage = _calculateLandingAngleDamage();

    final double cargoMultiplier = _cargoDamageMultiplier(mission.cargoType);

    final double totalDamage = (baseDamage + angleDamage) * cargoMultiplier;

    _applyCargoDamage(totalDamage);
  }

  double _calculateLandingAngleDamage() {
    double angle = vehicle.body.angle.abs();

    while (angle > math.pi) {
      angle -= math.pi * 2;
      angle = angle.abs();
    }

    if (angle > math.pi / 2) {
      angle = math.pi - angle;
    }

    final double degrees = angle * 180 / math.pi;

    if (degrees < 12) {
      return 0;
    }

    if (degrees < 25) {
      return 2;
    }

    if (degrees < 40) {
      return 5;
    }

    return 9;
  }

  double _cargoDamageMultiplier(CargoType cargoType) {
    switch (cargoType) {
      case CargoType.parcel:
        return 1.0;

      case CargoType.food:
        return 1.1;

      case CargoType.buildingMaterials:
        return 0.65;

      case CargoType.vehicleParts:
        return 1.35;
    }
  }

  void _applyCargoDamage(double damage) {
    if (damage <= 0) {
      return;
    }

    final double newCondition = (_cargoConditionPercent - damage).clamp(
      0.0,
      100.0,
    );

    if (newCondition == _cargoConditionPercent) {
      return;
    }

    _cargoConditionPercent = newCondition;

    onCargoConditionChanged?.call(_cargoConditionPercent);
  }

  // ------------------------------------------
  // ÜBERSCHLAGSERKENNUNG
  // ------------------------------------------

  void _updateRolloverDetection(double dt) {
    if (_deliveryCompleted || _missionFailed) {
      _rolloverStuckTime = 0;

      return;
    }

    if (_isVehicleAirborne()) {
      _rolloverStuckTime = 0;

      return;
    }

    final double tiltDegrees = _vehicleTiltDegrees();

    final bool dangerouslyTilted = tiltDegrees >= _rolloverAngleDegrees;

    if (!dangerouslyTilted) {
      _rolloverStuckTime = 0;

      return;
    }

    final Vector2 velocity = vehicle.body.linearVelocity;

    final double linearSpeed = velocity.length;

    if (linearSpeed > _rolloverMaximumLinearSpeed) {
      _rolloverStuckTime = 0;

      return;
    }

    _rolloverStuckTime += dt;

    if (_rolloverStuckTime < _rolloverFailureTime) {
      return;
    }

    _failMission();
  }

  double _vehicleTiltDegrees() {
    double angle = vehicle.body.angle;

    while (angle > math.pi) {
      angle -= math.pi * 2;
    }

    while (angle < -math.pi) {
      angle += math.pi * 2;
    }

    final double absoluteAngle = angle.abs();

    return absoluteAngle * 180 / math.pi;
  }

  void _failMission() {
    if (_missionFailed || _deliveryCompleted) {
      return;
    }

    _missionFailed = true;

    _rolloverStuckTime = 0;

    _throttle = 0;

    rearWheelJoint.motorSpeed = 0;

    onMissionFailed?.call();
  }

  // ------------------------------------------
  // ABHOLSTATION
  // ------------------------------------------

  void _checkPickup(double vehicleX) {
    if (_missionFailed) {
      return;
    }

    if (_pickupStationReached || _cargoPickedUp) {
      return;
    }

    final bool insidePickupZone =
        vehicleX >= route.pickupZoneStartX && vehicleX <= route.pickupZoneEndX;

    if (!insidePickupZone) {
      return;
    }

    _pickupStationReached = true;

    _throttle = 0;
    rearWheelJoint.motorSpeed = 0;

    onPickupStationReached?.call();

    pauseEngine();
  }

  void completePickup() {
    if (_missionFailed) {
      return;
    }

    if (!_pickupStationReached || _cargoPickedUp) {
      return;
    }

    _cargoPickedUp = true;
    _pickupStationReached = false;

    _cargoConditionPercent = 100.0;

    _wasAirborne = false;
    _airborneTime = 0;
    _maximumAirborneDownwardSpeed = 0;

    _rolloverStuckTime = 0;

    _throttle = 0;
    rearWheelJoint.motorSpeed = 0;

    vehicle.showCargo();

    onCargoConditionChanged?.call(_cargoConditionPercent);

    onCargoPickedUp?.call();

    resumeEngine();
  }

  // ------------------------------------------
  // LIEFERUNG
  // ------------------------------------------

  void _checkDelivery(double vehicleX) {
    if (_missionFailed) {
      return;
    }

    if (!_cargoPickedUp) {
      return;
    }

    if (_deliveryCompleted) {
      return;
    }

    final bool insideDeliveryZone =
        vehicleX >= route.deliveryZoneStartX &&
        vehicleX <= route.deliveryZoneEndX;

    if (!insideDeliveryZone) {
      return;
    }

    final double speed = vehicle.body.linearVelocity.x.abs();

    if (speed > route.deliveryMaxSpeed) {
      return;
    }

    _completeDelivery();
  }

  void _completeDelivery() {
    if (_missionFailed || _deliveryCompleted) {
      return;
    }

    _deliveryCompleted = true;

    _rolloverStuckTime = 0;

    vehicle.hideCargo();

    onDeliveryCompleted?.call(mission.moneyReward, mission.xpReward);
  }

  // ------------------------------------------
  // FEDERUNG
  // ------------------------------------------

  void _createSuspension() {
    final WheelJointDef rearJointDef = WheelJointDef(
      bodyA: vehicle.body,
      bodyB: rearWheel.body,
      localAnchorA: Vector2(_rearWheelX, _wheelY),
      localAnchorB: Vector2.zero(),
      localAxisA: Vector2(0, 1),
      enableSpring: true,
      hertz: 4.5,
      dampingRatio: 0.75,
      enableLimit: true,
      lowerTranslation: -0.35,
      upperTranslation: 0.35,
      enableMotor: true,
      maxMotorTorque: _motorTorque,
      motorSpeed: 0,
    );

    final WheelJointDef frontJointDef = WheelJointDef(
      bodyA: vehicle.body,
      bodyB: frontWheel.body,
      localAnchorA: Vector2(_frontWheelX, _wheelY),
      localAnchorB: Vector2.zero(),
      localAxisA: Vector2(0, 1),
      enableSpring: true,
      hertz: 4.5,
      dampingRatio: 0.75,
      enableLimit: true,
      lowerTranslation: -0.35,
      upperTranslation: 0.35,
      enableMotor: false,
    );

    rearWheelJoint = world.physicsWorld.createWheelJoint(rearJointDef);

    frontWheelJoint = world.physicsWorld.createWheelJoint(frontJointDef);
  }

  // ------------------------------------------
  // STEUERUNG
  // ------------------------------------------

  void setThrottle(double value) {
    if (_missionFailed || _deliveryCompleted) {
      _throttle = 0;

      rearWheelJoint.motorSpeed = 0;

      return;
    }

    if (_pickupStationReached && !_cargoPickedUp) {
      _throttle = 0;

      return;
    }

    _throttle = value.clamp(-1.0, 1.0);
  }
}

// ----------------------------------------------------
// ABHOLSTATION
// ----------------------------------------------------

class PickupStation extends PositionComponent {
  PickupStation({required super.position}) : super(priority: 5);

  final Paint _postPaint = Paint()..color = const Color(0xFF4A4F52);

  final Paint _signPaint = Paint()..color = const Color(0xFFF2B84B);

  final Paint _signBorderPaint = Paint()
    ..color = const Color(0xFF5C4520)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.08;

  final Paint _boxPaint = Paint()..color = const Color(0xFFD9903D);

  final Paint _boxTapePaint = Paint()..color = const Color(0xFFFFD080);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRect(const Rect.fromLTWH(-0.08, -2.0, 0.16, 2.0), _postPaint);

    const Rect signRect = Rect.fromLTWH(-1.05, -3.0, 2.1, 1.0);

    canvas.drawRRect(
      RRect.fromRectAndRadius(signRect, const Radius.circular(0.12)),
      _signPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(signRect, const Radius.circular(0.12)),
      _signBorderPaint,
    );

    canvas.drawRect(const Rect.fromLTWH(-0.55, -0.75, 1.1, 0.75), _boxPaint);

    canvas.drawRect(
      const Rect.fromLTWH(-0.08, -0.75, 0.16, 0.75),
      _boxTapePaint,
    );
  }
}

// ----------------------------------------------------
// GEMEINSAME ABGABESTATION
// ----------------------------------------------------

abstract class DeliveryDestination extends PositionComponent {
  DeliveryDestination({required super.position, super.priority = 4});

  final Paint deliveryZonePaint = Paint()..color = const Color(0x66F4D35E);

  final Paint deliveryZoneBorderPaint = Paint()
    ..color = const Color(0xFFD9B83E)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.09;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    drawDeliveryZone(canvas);

    drawDestination(canvas);
  }

  void drawDeliveryZone(Canvas canvas) {
    const Rect zone = Rect.fromLTWH(-5.0, -0.18, 4.0, 0.30);

    canvas.drawRRect(
      RRect.fromRectAndRadius(zone, const Radius.circular(0.12)),
      deliveryZonePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(zone, const Radius.circular(0.12)),
      deliveryZoneBorderPaint,
    );
  }

  void drawDestination(Canvas canvas);
}

// ----------------------------------------------------
// WOHNHAUS
// ----------------------------------------------------

class DeliveryHouse extends DeliveryDestination {
  DeliveryHouse({required super.position});

  final Paint _wallPaint = Paint()..color = const Color(0xFFD7C5A2);

  final Paint _wallShadowPaint = Paint()..color = const Color(0xFFB49B74);

  final Paint _roofPaint = Paint()..color = const Color(0xFF67463A);

  final Paint _roofShadowPaint = Paint()..color = const Color(0xFF4E342D);

  final Paint _doorPaint = Paint()..color = const Color(0xFF76513B);

  final Paint _windowPaint = Paint()..color = const Color(0xFF8CC5DA);

  final Paint _windowFramePaint = Paint()
    ..color = const Color(0xFFF1E4C8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.08;

  final Paint _chimneyPaint = Paint()..color = const Color(0xFF73584A);

  final Paint _stonePaint = Paint()..color = const Color(0xFF7A756B);

  @override
  void drawDestination(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(-1.35, -0.20, 4.9, 0.28), _stonePaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-1.1, -3.1, 4.4, 3.0),
        const Radius.circular(0.08),
      ),
      _wallPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(2.85, -3.0, 0.45, 2.9),
      _wallShadowPaint,
    );

    final Path roof = Path()
      ..moveTo(-1.55, -3.0)
      ..lineTo(0.85, -5.0)
      ..lineTo(3.75, -3.0)
      ..close();

    canvas.drawPath(roof, _roofPaint);

    final Paint roofEdgePaint = Paint()
      ..color = const Color(0xFF4E342D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path roofEdge = Path()
      ..moveTo(-1.65, -2.98)
      ..lineTo(0.85, -5.12)
      ..lineTo(3.85, -2.98);

    canvas.drawPath(roofEdge, roofEdgePaint);

    canvas.drawRect(
      const Rect.fromLTWH(2.15, -4.65, 0.48, 1.25),
      _chimneyPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(2.05, -4.72, 0.68, 0.18),
      _roofShadowPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(1.45, -2.15, 0.85, 2.05),
        const Radius.circular(0.07),
      ),
      _doorPaint,
    );

    canvas.drawCircle(const Offset(2.10, -1.05), 0.07, _roofShadowPaint);

    _drawWindow(canvas, -0.55, -2.25);
    _drawWindow(canvas, 2.45, -2.25);

    for (int i = 0; i < 7; i++) {
      canvas.drawCircle(Offset(-0.85 + (i * 0.55), -0.05), 0.13, _stonePaint);
    }
  }

  void _drawWindow(Canvas canvas, double x, double y) {
    final Rect window = Rect.fromLTWH(x, y, 0.78, 0.82);

    canvas.drawRect(window, _windowPaint);
    canvas.drawRect(window, _windowFramePaint);

    canvas.drawLine(
      Offset(x + 0.39, y),
      Offset(x + 0.39, y + 0.82),
      _windowFramePaint,
    );

    canvas.drawLine(
      Offset(x, y + 0.41),
      Offset(x + 0.78, y + 0.41),
      _windowFramePaint,
    );
  }
}

// ----------------------------------------------------
// BERGHÜTTE
// ----------------------------------------------------

class DeliveryMountainHut extends DeliveryDestination {
  DeliveryMountainHut({required super.position});

  final Paint _woodPaint = Paint()..color = const Color(0xFF8A603E);
  final Paint _darkWoodPaint = Paint()..color = const Color(0xFF5D3D29);
  final Paint _roofPaint = Paint()..color = const Color(0xFF3F4542);
  final Paint _windowPaint = Paint()..color = const Color(0xFF9ED2DF);
  final Paint _stonePaint = Paint()..color = const Color(0xFF77756E);

  @override
  void drawDestination(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(-1.0, -0.18, 4.7, 0.22), _stonePaint);

    canvas.drawRect(const Rect.fromLTWH(-0.8, -2.7, 4.3, 2.55), _woodPaint);

    for (double y = -2.45; y < -0.3; y += 0.42) {
      canvas.drawLine(
        Offset(-0.8, y),
        Offset(3.5, y),
        Paint()
          ..color = const Color(0xFF704B32)
          ..strokeWidth = 0.06,
      );
    }

    final Path roof = Path()
      ..moveTo(-1.25, -2.65)
      ..lineTo(1.25, -4.45)
      ..lineTo(3.95, -2.65)
      ..close();

    canvas.drawPath(roof, _roofPaint);

    canvas.drawRect(const Rect.fromLTWH(0.9, -1.85, 0.9, 1.7), _darkWoodPaint);

    canvas.drawRect(const Rect.fromLTWH(-0.25, -2.0, 0.8, 0.75), _windowPaint);

    canvas.drawRect(const Rect.fromLTWH(2.25, -2.0, 0.8, 0.75), _windowPaint);

    canvas.drawRect(const Rect.fromLTWH(2.8, -4.15, 0.4, 1.1), _darkWoodPaint);
  }
}

// ----------------------------------------------------
// BAUSTELLE
// ----------------------------------------------------

class DeliveryConstructionSite extends DeliveryDestination {
  DeliveryConstructionSite({required super.position});

  final Paint _concretePaint = Paint()..color = const Color(0xFFB5B5AE);
  final Paint _darkConcretePaint = Paint()..color = const Color(0xFF858680);
  final Paint _woodPaint = Paint()..color = const Color(0xFF9A7044);
  final Paint _warningPaint = Paint()..color = const Color(0xFFF2B84B);
  final Paint _darkPaint = Paint()..color = const Color(0xFF353A3C);

  @override
  void drawDestination(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(-0.8, -0.18, 5.5, 0.22),
      _darkConcretePaint,
    );

    canvas.drawRect(const Rect.fromLTWH(0.0, -2.7, 3.8, 2.55), _concretePaint);

    canvas.drawRect(
      const Rect.fromLTWH(0.7, -2.0, 1.0, 1.85),
      _darkConcretePaint,
    );

    canvas.drawRect(const Rect.fromLTWH(2.4, -2.0, 0.9, 0.9), _darkPaint);

    for (double x = -0.45; x <= 4.25; x += 1.55) {
      canvas.drawRect(Rect.fromLTWH(x, -3.45, 0.09, 3.3), _woodPaint);
    }

    for (double y = -3.35; y <= -0.3; y += 1.0) {
      canvas.drawRect(Rect.fromLTWH(-0.5, y, 4.85, 0.09), _woodPaint);
    }

    canvas.drawRect(
      const Rect.fromLTWH(-1.25, -1.45, 0.95, 0.65),
      _warningPaint,
    );

    canvas.drawLine(
      const Offset(-0.78, -0.8),
      const Offset(-0.78, -0.1),
      Paint()
        ..color = const Color(0xFF4A4F52)
        ..strokeWidth = 0.1,
    );
  }
}

// ----------------------------------------------------
// WERKSTATT
// ----------------------------------------------------

class DeliveryWorkshop extends DeliveryDestination {
  DeliveryWorkshop({required super.position});

  final Paint _wallPaint = Paint()..color = const Color(0xFF8A9395);
  final Paint _darkWallPaint = Paint()..color = const Color(0xFF60686A);
  final Paint _roofPaint = Paint()..color = const Color(0xFF404648);
  final Paint _garageDoorPaint = Paint()..color = const Color(0xFFCDD2D2);

  final Paint _doorLinePaint = Paint()
    ..color = const Color(0xFF8E9697)
    ..strokeWidth = 0.06;

  final Paint _signPaint = Paint()..color = const Color(0xFFF2B84B);

  @override
  void drawDestination(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(-1.0, -0.18, 5.6, 0.22),
      _darkWallPaint,
    );

    canvas.drawRect(const Rect.fromLTWH(-0.7, -3.1, 5.1, 2.95), _wallPaint);

    canvas.drawRect(const Rect.fromLTWH(-0.95, -3.35, 5.6, 0.35), _roofPaint);

    const Rect garageDoor = Rect.fromLTWH(-0.1, -2.35, 2.65, 2.2);

    canvas.drawRect(garageDoor, _garageDoorPaint);

    for (double y = -2.1; y < -0.2; y += 0.4) {
      canvas.drawLine(Offset(-0.1, y), Offset(2.55, y), _doorLinePaint);
    }

    canvas.drawRect(const Rect.fromLTWH(3.0, -2.0, 0.75, 1.85), _darkWallPaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0.45, -3.9, 2.2, 0.55),
        const Radius.circular(0.08),
      ),
      _signPaint,
    );
  }
}

// ----------------------------------------------------
// HINTERGRUND
// ----------------------------------------------------

class PhysicsLandscape extends PositionComponent {
  PhysicsLandscape() : super(priority: -100);

  final Paint _farMountainPaint = Paint()..color = const Color(0xFF9DB4BD);
  final Paint _middleMountainPaint = Paint()..color = const Color(0xFF78949B);
  final Paint _hillPaint = Paint()..color = const Color(0xFF587D57);
  final Paint _forestPaint = Paint()..color = const Color(0xFF3D6748);
  final Paint _trunkPaint = Paint()..color = const Color(0xFF4B4334);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _drawFarMountains(canvas);
    _drawMiddleMountains(canvas);
    _drawHills(canvas);
    _drawForest(canvas);
  }

  void _drawFarMountains(Canvas canvas) {
    final Path path = Path()
      ..moveTo(-40, 10)
      ..lineTo(-40, 4.5)
      ..lineTo(-28, 0.8)
      ..lineTo(-20, 3.0)
      ..lineTo(-10, -0.5)
      ..lineTo(0, 3.2)
      ..lineTo(12, 0.2)
      ..lineTo(24, 3.1)
      ..lineTo(36, -0.8)
      ..lineTo(48, 3.0)
      ..lineTo(60, 0.6)
      ..lineTo(72, 3.4)
      ..lineTo(84, -0.4)
      ..lineTo(98, 3.2)
      ..lineTo(112, 0.4)
      ..lineTo(126, 3.1)
      ..lineTo(140, -0.7)
      ..lineTo(154, 3.0)
      ..lineTo(168, 0.1)
      ..lineTo(182, 3.3)
      ..lineTo(196, -0.9)
      ..lineTo(210, 3.0)
      ..lineTo(224, 0.4)
      ..lineTo(238, 3.2)
      ..lineTo(252, -0.6)
      ..lineTo(266, 3.1)
      ..lineTo(280, 0.2)
      ..lineTo(294, 3.4)
      ..lineTo(310, -0.5)
      ..lineTo(325, 3.5)
      ..lineTo(325, 10)
      ..close();

    canvas.drawPath(path, _farMountainPaint);
  }

  void _drawMiddleMountains(Canvas canvas) {
    final Path path = Path()
      ..moveTo(-40, 10)
      ..lineTo(-40, 5.5)
      ..quadraticBezierTo(-30, 2.2, -20, 5.2)
      ..quadraticBezierTo(-8, 1.6, 4, 5.0)
      ..quadraticBezierTo(16, 2.0, 28, 5.4)
      ..quadraticBezierTo(42, 1.7, 55, 5.1)
      ..quadraticBezierTo(68, 2.4, 82, 5.4)
      ..quadraticBezierTo(96, 1.5, 110, 5.0)
      ..quadraticBezierTo(124, 2.0, 138, 5.3)
      ..quadraticBezierTo(152, 1.6, 166, 5.2)
      ..quadraticBezierTo(180, 2.4, 194, 5.4)
      ..quadraticBezierTo(208, 1.4, 222, 5.1)
      ..quadraticBezierTo(236, 2.2, 250, 5.3)
      ..quadraticBezierTo(264, 1.7, 278, 5.2)
      ..quadraticBezierTo(292, 2.3, 306, 5.4)
      ..quadraticBezierTo(316, 3.0, 325, 5.6)
      ..lineTo(325, 10)
      ..close();

    canvas.drawPath(path, _middleMountainPaint);
  }

  void _drawHills(Canvas canvas) {
    final Path path = Path()
      ..moveTo(-40, 11)
      ..lineTo(-40, 6.5)
      ..quadraticBezierTo(-25, 4.7, -10, 6.6)
      ..quadraticBezierTo(5, 4.8, 20, 6.4)
      ..quadraticBezierTo(35, 4.5, 50, 6.6)
      ..quadraticBezierTo(65, 4.7, 80, 6.5)
      ..quadraticBezierTo(95, 4.4, 110, 6.4)
      ..quadraticBezierTo(125, 4.7, 140, 6.6)
      ..quadraticBezierTo(155, 4.4, 170, 6.5)
      ..quadraticBezierTo(185, 4.7, 200, 6.4)
      ..quadraticBezierTo(215, 4.3, 230, 6.6)
      ..quadraticBezierTo(245, 4.8, 260, 6.4)
      ..quadraticBezierTo(275, 4.5, 290, 6.6)
      ..quadraticBezierTo(305, 4.7, 325, 6.5)
      ..lineTo(325, 11)
      ..close();

    canvas.drawPath(path, _hillPaint);
  }

  void _drawForest(Canvas canvas) {
    for (double x = -35; x < 325; x += 3.4) {
      final int index = ((x + 35) / 3.4).round();

      final double variation = (index % 4) * 0.18;

      _drawTree(canvas, x, 6.6 + variation, 1.0 + ((index % 3) * 0.12));
    }
  }

  void _drawTree(Canvas canvas, double x, double y, double scale) {
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(x, y - (0.45 * scale)),
        width: 0.12 * scale,
        height: 0.9 * scale,
      ),
      _trunkPaint,
    );

    final Path tree = Path()
      ..moveTo(x, y - (2.0 * scale))
      ..lineTo(x - (0.65 * scale), y - (0.65 * scale))
      ..lineTo(x - (0.35 * scale), y - (0.65 * scale))
      ..lineTo(x - (0.85 * scale), y)
      ..lineTo(x + (0.85 * scale), y)
      ..lineTo(x + (0.35 * scale), y - (0.65 * scale))
      ..lineTo(x + (0.65 * scale), y - (0.65 * scale))
      ..close();

    canvas.drawPath(tree, _forestPaint);
  }
}

// ----------------------------------------------------
// PHYSIK-TERRAIN
// ----------------------------------------------------

class PhysicsTerrain extends BodyComponent {
  PhysicsTerrain({required List<Vector2> controlPoints})
    : _controlPoints = controlPoints
          .map((Vector2 point) => Vector2(point.x, point.y))
          .toList(),
      super(renderBody: false) {
    _points = _buildSmoothTerrain();
  }

  final Paint _groundPaint = Paint()..color = const Color(0xFF506F38);

  final Paint _roadPaint = Paint()
    ..color = const Color(0xFF756650)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.45
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  final List<Vector2> _controlPoints;

  late final List<Vector2> _points;

  static const int _segmentsPerSection = 5;

  List<Vector2> _buildSmoothTerrain() {
    final List<Vector2> result = <Vector2>[];

    if (_controlPoints.length < 2) {
      return List<Vector2>.from(_controlPoints);
    }

    result.add(Vector2(_controlPoints.first.x, _controlPoints.first.y));

    for (int i = 0; i < _controlPoints.length - 1; i++) {
      final Vector2 p0 = i == 0 ? _controlPoints[i] : _controlPoints[i - 1];

      final Vector2 p1 = _controlPoints[i];

      final Vector2 p2 = _controlPoints[i + 1];

      final Vector2 p3 = i + 2 < _controlPoints.length
          ? _controlPoints[i + 2]
          : _controlPoints[i + 1];

      for (int step = 1; step <= _segmentsPerSection; step++) {
        final double t = step / _segmentsPerSection;

        final double x = _catmullRom(p0.x, p1.x, p2.x, p3.x, t);

        final double y = _catmullRom(p0.y, p1.y, p2.y, p3.y, t);

        result.add(Vector2(x, y));
      }
    }

    return result;
  }

  double _catmullRom(double p0, double p1, double p2, double p3, double t) {
    final double t2 = t * t;
    final double t3 = t2 * t;

    return 0.5 *
        ((2.0 * p1) +
            (-p0 + p2) * t +
            (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 +
            (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3);
  }

  double getTerrainY(double x) {
    if (_points.isEmpty) {
      return 8.0;
    }

    if (x <= _points.first.x) {
      return _points.first.y;
    }

    if (x >= _points.last.x) {
      return _points.last.y;
    }

    for (int i = 0; i < _points.length - 1; i++) {
      final Vector2 start = _points[i];
      final Vector2 end = _points[i + 1];

      if (x >= start.x && x <= end.x) {
        final double width = end.x - start.x;

        if (width.abs() < 0.0001) {
          return start.y;
        }

        final double progress = (x - start.x) / width;

        return start.y + ((end.y - start.y) * progress);
      }
    }

    return _points.last.y;
  }

  @override
  Body createBody() {
    final BodyDef bodyDef = BodyDef(
      type: BodyType.static,
      position: Vector2.zero(),
    );

    final Body terrainBody = world.createBody(bodyDef);

    final List<Vector2> collisionPoints = _points
        .map((Vector2 point) => Vector2(point.x, point.y))
        .toList();

    terrainBody.createChain(ChainDef(points: collisionPoints, isLoop: false));

    return terrainBody;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (_points.isEmpty) {
      return;
    }

    final Path groundPath = Path()..moveTo(_points.first.x, _points.first.y);

    for (int i = 1; i < _points.length; i++) {
      groundPath.lineTo(_points[i].x, _points[i].y);
    }

    groundPath
      ..lineTo(_points.last.x, 20)
      ..lineTo(_points.first.x, 20)
      ..close();

    canvas.drawPath(groundPath, _groundPaint);

    final Path roadPath = Path()..moveTo(_points.first.x, _points.first.y);

    for (int i = 1; i < _points.length; i++) {
      roadPath.lineTo(_points[i].x, _points[i].y);
    }

    canvas.drawPath(roadPath, _roadPaint);
  }
}
