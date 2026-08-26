import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class OffroadDeliveryGame extends FlameGame {
  late final RectangleComponent ground;
  late final RectangleComponent vanBody;
  late final CircleComponent frontWheel;
  late final CircleComponent rearWheel;

  double _speed = 0;
  double _throttle = 0;

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
      position: Vector2(0, size.y * 0.72),
      size: Vector2(size.x, size.y * 0.28),
      paint: Paint()
        ..color = const Color(0xFF4D6B35),
    );

    vanBody = RectangleComponent(
      position: Vector2(
        size.x * 0.18,
        size.y * 0.72 - 65,
      ),
      size: Vector2(125, 55),
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

    add(ground);
    add(vanBody);
    add(rearWheel);
    add(frontWheel);
  }

  void setThrottle(double value) {
    _throttle = value.clamp(-1.0, 1.0);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_throttle > 0) {
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

    _keepVehicleOnScreen();
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
      final double correction = minimumX - vanBody.position.x;

      vanBody.position.x += correction;
      rearWheel.position.x += correction;
      frontWheel.position.x += correction;

      _speed = 0;
    }

    if (vanBody.position.x > maximumX) {
      final double correction = maximumX - vanBody.position.x;

      vanBody.position.x += correction;
      rearWheel.position.x += correction;
      frontWheel.position.x += correction;

      _speed = 0;
    }
  }
}