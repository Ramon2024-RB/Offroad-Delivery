import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class OffroadDeliveryGame extends FlameGame {
  static const double worldWidth = 3200;
  static const double groundHeight = 110;

  late final World gameWorld;

  late final RectangleComponent ground;

  late final RectangleComponent vanBody;
  late final CircleComponent frontWheel;
  late final CircleComponent rearWheel;

  late final RectangleComponent depot;
  late final RectangleComponent customer;

  late final TextComponent depotLabel;
  late final TextComponent customerLabel;

  late final RectangleComponent cargo;

  final ValueNotifier<String> missionNotifier =
      ValueNotifier<String>('Auftrag: Paket beim Depot abholen');

  double _speed = 0;
  double _throttle = 0;

  bool _cargoLoaded = false;
  bool _missionCompleted = false;

  static const double _acceleration = 420;
  static const double _brakingAcceleration = 600;
  static const double _friction = 220;

  static const double _maximumForwardSpeed = 500;
  static const double _maximumReverseSpeed = -180;

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

    const double groundY = 300;

    ground = RectangleComponent(
      position: Vector2(
        0,
        groundY,
      ),
      size: Vector2(
        worldWidth,
        groundHeight,
      ),
      paint: Paint()
        ..color = const Color(0xFF4D6B35),
    );

    depot = RectangleComponent(
      position: Vector2(
        60,
        groundY - 100,
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
        78,
        groundY - 130,
      ),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    customer = RectangleComponent(
      position: Vector2(
        worldWidth - 180,
        groundY - 90,
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
        worldWidth - 170,
        groundY - 120,
      ),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    vanBody = RectangleComponent(
      position: Vector2(
        185,
        groundY - 65,
      ),
      size: Vector2(
        125,
        55,
      ),
      paint: Paint()
        ..color = const Color(0xFFE8E8E8),
    );

    rearWheel = CircleComponent(
      radius: 16,
      position: Vector2(
        vanBody.position.x + 25,
        vanBody.position.y + 50,
      ),
      paint: Paint()
        ..color = const Color(0xFF202020),
    );

    frontWheel = CircleComponent(
      radius: 16,
      position: Vector2(
        vanBody.position.x + 100,
        vanBody.position.y + 50,
      ),
      paint: Paint()
        ..color = const Color(0xFF202020),
    );

    cargo = RectangleComponent(
      position: Vector2(
        115,
        groundY - 22,
      ),
      size: Vector2(
        26,
        22,
      ),
      paint: Paint()
        ..color = const Color(0xFFD69A4A),
    );

    await gameWorld.addAll([
      ground,
      depot,
      depotLabel,
      customer,
      customerLabel,
      cargo,
      vanBody,
      rearWheel,
      frontWheel,
    ]);

    camera.follow(
      vanBody,
      horizontalOnly: true,
      snap: true,
    );
  }

  void setThrottle(double value) {
    _throttle = value.clamp(-1.0, 1.0);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_missionCompleted) {
      _applyFriction(dt);
    } else if (_throttle > 0) {
      _speed += _acceleration * _throttle * dt;
    } else if (_throttle < 0) {
      _speed += _brakingAcceleration * _throttle * dt;
    } else {
      _applyFriction(dt);
    }

    _speed = _speed.clamp(
      _maximumReverseSpeed,
      _maximumForwardSpeed,
    );

    final double movement = _speed * dt;

    vanBody.position.x += movement;
    rearWheel.position.x += movement;
    frontWheel.position.x += movement;

    if (_cargoLoaded) {
      cargo.position = Vector2(
        vanBody.position.x + 50,
        vanBody.position.y - 22,
      );
    }

    _keepVehicleInsideWorld();
    _checkMission();
  }

  void _checkMission() {
    if (!_cargoLoaded && vanBody.position.x <= 160) {
      _cargoLoaded = true;

      missionNotifier.value =
          'Lieferung geladen – bringe sie zum Kunden!';
    }

    if (_cargoLoaded &&
        !_missionCompleted &&
        vanBody.position.x + vanBody.size.x >= customer.position.x) {
      _missionCompleted = true;
      _throttle = 0;

      missionNotifier.value =
          'LIEFERUNG ERFOLGREICH! +100 €';
    }
  }

  void _applyFriction(double dt) {
    if (_speed > 0) {
      _speed -= _friction * dt;

      if (_speed < 0) {
        _speed = 0;
      }
    } else if (_speed < 0) {
      _speed += _friction * dt;

      if (_speed > 0) {
        _speed = 0;
      }
    }
  }

  void _keepVehicleInsideWorld() {
    const double minimumX = 20;

    final double maximumX =
        worldWidth - vanBody.size.x - 20;

    if (vanBody.position.x < minimumX) {
      final double correction =
          minimumX - vanBody.position.x;

      _moveVehicle(correction);

      _speed = 0;
    }

    if (vanBody.position.x > maximumX) {
      final double correction =
          maximumX - vanBody.position.x;

      _moveVehicle(correction);

      _speed = 0;
    }
  }

  void _moveVehicle(double movement) {
    vanBody.position.x += movement;
    rearWheel.position.x += movement;
    frontWheel.position.x += movement;
  }

  @override
  void onRemove() {
    missionNotifier.dispose();
    super.onRemove();
  }
}