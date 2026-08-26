import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DeliveryVehicle extends PositionComponent {
  DeliveryVehicle({
    required super.position,
  }) : super(
          size: Vector2(125, 75),
        );

  late final RectangleComponent body;
  late final CircleComponent rearWheel;
  late final CircleComponent frontWheel;
  late final RectangleComponent cargo;

  bool cargoVisible = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    body = RectangleComponent(
      position: Vector2.zero(),
      size: Vector2(125, 55),
      paint: Paint()
        ..color = const Color(0xFFE8E8E8),
    );

    rearWheel = CircleComponent(
      radius: 16,
      position: Vector2(
        25,
        50,
      ),
      paint: Paint()
        ..color = const Color(0xFF202020),
    );

    frontWheel = CircleComponent(
      radius: 16,
      position: Vector2(
        100,
        50,
      ),
      paint: Paint()
        ..color = const Color(0xFF202020),
    );

    cargo = RectangleComponent(
      position: Vector2(
        50,
        -22,
      ),
      size: Vector2(
        26,
        22,
      ),
      paint: Paint()
        ..color = const Color(0xFFD69A4A),
    );

    await add(body);
    await add(rearWheel);
    await add(frontWheel);
  }

  void showCargo() {
    if (cargoVisible) {
      return;
    }

    cargoVisible = true;
    add(cargo);
  }
}