import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class OffroadDeliveryGame extends FlameGame {
  late final RectangleComponent ground;

  late final RectangleComponent vanBody;
  late final CircleComponent frontWheel;
  late final CircleComponent rearWheel;

  late final RectangleComponent depot;
  late final RectangleComponent customer;

  late final TextComponent depotLabel;
  late final TextComponent customerLabel;
  late final TextComponent missionText;

  late final RectangleComponent cargo;

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

    ground = RectangleComponent(
      position: Vector2(
        0,
        size.y * 0.72,
      ),
      size: Vector2(
        size.x,
        size.y * 0.28,
      ),
      paint: Paint()
        ..color = const Color(0xFF4D6B35),
    );

    depot = RectangleComponent(
      position: Vector2(
        35,
        size.y * 0.72 - 100,
      ),
      size: Vector2(
        90,
        100,
      ),
      paint: Paint()
        ..color = const Color(0xFF56616A),
    );

    customer = RectangleComponent(
      position: Vector2(
        size.x - 130,
        size.y * 0.72 - 90,
      ),
      size: Vector2(
        90,
        90,
      ),
      paint: Paint()
        ..color = const Color(0xFFB66A45),
    );

    depotLabel = TextComponent(
      text: 'DEPOT',
      position: Vector2(
        48,
        size.y * 0.72 - 125,
      ),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    customerLabel = TextComponent(
      text: 'KUNDE',
      position: Vector2(
        size.x - 125,
        size.y * 0.72 - 115,
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
        145,
        size.y * 0.72 - 65,
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
        92,
        size.y * 0.72 - 20,
      ),
      size: Vector2(
        24,
        20,
      ),
      paint: Paint()
        ..color = const Color(0xFFD69A4A),
    );

    missionText = TextComponent(
      text: 'Auftrag: Paket beim Depot abholen',
      position: Vector2(
        size.x / 2,
        25,
      ),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(ground);

    add(depot);
    add(customer);

    add(depotLabel);
    add(customerLabel);

    add(cargo);

    add(vanBody);
    add(rearWheel);
    add(frontWheel);

    add(missionText);
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

    _keepVehicleOnScreen();
    _checkMission();
  }

  void _checkMission() {
    if (!_cargoLoaded && vanBody.position.x <= 125) {
      _cargoLoaded = true;

      missionText.text = 'Lieferung geladen – bringe sie zum Kunden!';
    }

    if (_cargoLoaded &&
        !_missionCompleted &&
        vanBody.position.x + vanBody.size.x >= customer.position.x) {
      _missionCompleted = true;
      _throttle = 0;

      missionText.text = 'LIEFERUNG ERFOLGREICH! +100 €';
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

  void _keepVehicleOnScreen() {
    final double minimumX = 20;
    final double maximumX = size.x - vanBody.size.x - 20;

    if (vanBody.position.x < minimumX) {
      final double correction =
          minimumX - vanBody.position.x;

      vanBody.position.x += correction;
      rearWheel.position.x += correction;
      frontWheel.position.x += correction;

      _speed = 0;
    }

    if (vanBody.position.x > maximumX) {
      final double correction =
          maximumX - vanBody.position.x;

      vanBody.position.x += correction;
      rearWheel.position.x += correction;
      frontWheel.position.x += correction;

      _speed = 0;
    }
  }
}