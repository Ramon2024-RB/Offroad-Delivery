import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import 'components/physics_vehicle.dart';
import 'components/physics_wheel.dart';

class PhysicsTestGame extends Forge2DGame {
  PhysicsTestGame({
    this.onDeliveryCompleted,
  }) : super(
          gravity: Vector2(
            0,
            9.81,
          ),
          metersToPixels: 32,
          camera: CameraComponent.withFixedResolution(
            width: 900,
            height: 400,
          ),
        );

  final void Function(
    int moneyReward,
    int xpReward,
  )? onDeliveryCompleted;

  late final PhysicsVehicle vehicle;
  late final PhysicsWheel rearWheel;
  late final PhysicsWheel frontWheel;

  late final WheelJoint rearWheelJoint;
  late final WheelJoint frontWheelJoint;

  bool _cargoPickedUp = false;
  bool _deliveryCompleted = false;

  double _throttle = 0;

  int money = 0;
  int xp = 0;

  static const double _motorSpeed = 18;
  static const double _motorTorque = 45;

  static const double _rearWheelX = -1.45;
  static const double _frontWheelX = 1.45;
  static const double _wheelY = 1.0;

  static const double _pickupX = 18.0;

  static const double _deliveryHouseX = 125.0;

  static const double _deliveryZoneCenterX =
      _deliveryHouseX - 3.0;

  static const double _deliveryZoneHalfWidth = 2.0;

  static const double _deliveryMaxSpeed = 1.0;

  @override
  Color backgroundColor() {
    return const Color(0xFF87B7D9);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final PhysicsLandscape landscape =
        PhysicsLandscape();

    final PhysicsTerrain terrain =
        PhysicsTerrain();

    final PickupStation pickupStation =
        PickupStation(
      position: Vector2(
        _pickupX,
        7.0,
      ),
    );

    final DeliveryHouse deliveryHouse =
        DeliveryHouse(
      position: Vector2(
        _deliveryHouseX,
        6.6,
      ),
    );

    vehicle = PhysicsVehicle(
      startPosition: Vector2(
        8,
        5,
      ),
    );

    rearWheel = PhysicsWheel(
      startPosition: Vector2(
        8 + _rearWheelX,
        5 + _wheelY,
      ),
    );

    frontWheel = PhysicsWheel(
      startPosition: Vector2(
        8 + _frontWheelX,
        5 + _wheelY,
      ),
    );

    await world.add(landscape);
    await world.add(terrain);
    await world.add(pickupStation);
    await world.add(deliveryHouse);
    await world.add(vehicle);
    await world.add(rearWheel);
    await world.add(frontWheel);

    _createSuspension();

    camera.viewfinder.position = Vector2(
      12,
      6,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!vehicle.isMounted) {
      return;
    }

    final double vehicleX =
        vehicle.body.position.x;

    final double vehicleY =
        vehicle.body.position.y;

    camera.viewfinder.position = Vector2(
      vehicleX + 5,
      vehicleY + 0.5,
    );

    _checkPickup(vehicleX);

    _checkDelivery(vehicleX);
  }

  void _checkPickup(double vehicleX) {
    if (_cargoPickedUp) {
      return;
    }

    if (vehicleX >= _pickupX - 1.5 &&
        vehicleX <= _pickupX + 1.5) {
      _cargoPickedUp = true;

      vehicle.showCargo();
    }
  }

  void _checkDelivery(double vehicleX) {
    if (!_cargoPickedUp) {
      return;
    }

    if (_deliveryCompleted) {
      return;
    }

    final bool insideDeliveryZone =
        vehicleX >=
                _deliveryZoneCenterX -
                    _deliveryZoneHalfWidth &&
            vehicleX <=
                _deliveryZoneCenterX +
                    _deliveryZoneHalfWidth;

    if (!insideDeliveryZone) {
      return;
    }

    final double speed =
        vehicle.body.linearVelocity.length;

    if (speed > _deliveryMaxSpeed) {
      return;
    }

    _completeDelivery();
  }

  void _completeDelivery() {
    _deliveryCompleted = true;

    vehicle.hideCargo();

    const int moneyReward = 250;
    const int xpReward = 100;

    money += moneyReward;
    xp += xpReward;

    onDeliveryCompleted?.call(
      moneyReward,
      xpReward,
    );
  }

  void _createSuspension() {
    final WheelJointDef rearJointDef =
        WheelJointDef(
      bodyA: vehicle.body,
      bodyB: rearWheel.body,
      localAnchorA: Vector2(
        _rearWheelX,
        _wheelY,
      ),
      localAnchorB: Vector2.zero(),
      localAxisA: Vector2(
        0,
        1,
      ),
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

    final WheelJointDef frontJointDef =
        WheelJointDef(
      bodyA: vehicle.body,
      bodyB: frontWheel.body,
      localAnchorA: Vector2(
        _frontWheelX,
        _wheelY,
      ),
      localAnchorB: Vector2.zero(),
      localAxisA: Vector2(
        0,
        1,
      ),
      enableSpring: true,
      hertz: 4.5,
      dampingRatio: 0.75,
      enableLimit: true,
      lowerTranslation: -0.35,
      upperTranslation: 0.35,
      enableMotor: false,
    );

    rearWheelJoint =
        world.physicsWorld.createWheelJoint(
      rearJointDef,
    );

    frontWheelJoint =
        world.physicsWorld.createWheelJoint(
      frontJointDef,
    );
  }

  void setThrottle(double value) {
    _throttle = value.clamp(
      -1.0,
      1.0,
    );

    if (_throttle == 0) {
      rearWheelJoint.motorSpeed = 0;
      return;
    }

    rearWheelJoint.motorSpeed =
        _motorSpeed * _throttle;
  }
}

// ----------------------------------------------------
// ABHOLSTATION
// ----------------------------------------------------

class PickupStation extends PositionComponent {
  PickupStation({
    required super.position,
  }) : super(
          priority: 5,
        );

  final Paint _postPaint = Paint()
    ..color = const Color(0xFF4A4F52);

  final Paint _signPaint = Paint()
    ..color = const Color(0xFFF2B84B);

  final Paint _signBorderPaint = Paint()
    ..color = const Color(0xFF5C4520)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.08;

  final Paint _boxPaint = Paint()
    ..color = const Color(0xFFD9903D);

  final Paint _boxTapePaint = Paint()
    ..color = const Color(0xFFFFD080);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRect(
      const Rect.fromLTWH(
        -0.08,
        -2.0,
        0.16,
        2.0,
      ),
      _postPaint,
    );

    const Rect signRect = Rect.fromLTWH(
      -1.05,
      -3.0,
      2.1,
      1.0,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        signRect,
        const Radius.circular(0.12),
      ),
      _signPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        signRect,
        const Radius.circular(0.12),
      ),
      _signBorderPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        -0.55,
        -0.75,
        1.1,
        0.75,
      ),
      _boxPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        -0.08,
        -0.75,
        0.16,
        0.75,
      ),
      _boxTapePaint,
    );
  }
}

// ----------------------------------------------------
// LIEFERHAUS
// ----------------------------------------------------

class DeliveryHouse extends PositionComponent {
  DeliveryHouse({
    required super.position,
  }) : super(
          priority: 4,
        );

  final Paint _wallPaint = Paint()
    ..color = const Color(0xFFD7C5A2);

  final Paint _wallShadowPaint = Paint()
    ..color = const Color(0xFFB49B74);

  final Paint _roofPaint = Paint()
    ..color = const Color(0xFF67463A);

  final Paint _roofShadowPaint = Paint()
    ..color = const Color(0xFF4E342D);

  final Paint _doorPaint = Paint()
    ..color = const Color(0xFF76513B);

  final Paint _windowPaint = Paint()
    ..color = const Color(0xFF8CC5DA);

  final Paint _windowFramePaint = Paint()
    ..color = const Color(0xFFF1E4C8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.08;

  final Paint _chimneyPaint = Paint()
    ..color = const Color(0xFF73584A);

  final Paint _stonePaint = Paint()
    ..color = const Color(0xFF7A756B);

  final Paint _deliveryZonePaint = Paint()
    ..color = const Color(0x66F4D35E);

  final Paint _deliveryZoneBorderPaint =
      Paint()
        ..color = const Color(0xFFD9B83E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.09;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _drawDeliveryZone(canvas);
    _drawHouse(canvas);
  }

  void _drawDeliveryZone(Canvas canvas) {
    const Rect zone = Rect.fromLTWH(
      -4.6,
      0.05,
      3.2,
      0.45,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        zone,
        const Radius.circular(0.15),
      ),
      _deliveryZonePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        zone,
        const Radius.circular(0.15),
      ),
      _deliveryZoneBorderPaint,
    );
  }

  void _drawHouse(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(
        -1.35,
        -0.20,
        4.9,
        0.28,
      ),
      _stonePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          -1.1,
          -3.1,
          4.4,
          3.0,
        ),
        const Radius.circular(0.08),
      ),
      _wallPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        2.85,
        -3.0,
        0.45,
        2.9,
      ),
      _wallShadowPaint,
    );

    final Path roof = Path()
      ..moveTo(-1.55, -3.0)
      ..lineTo(0.85, -5.0)
      ..lineTo(3.75, -3.0)
      ..close();

    canvas.drawPath(
      roof,
      _roofPaint,
    );

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

    canvas.drawPath(
      roofEdge,
      roofEdgePaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        2.15,
        -4.65,
        0.48,
        1.25,
      ),
      _chimneyPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        2.05,
        -4.72,
        0.68,
        0.18,
      ),
      _roofShadowPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          1.45,
          -2.15,
          0.85,
          2.05,
        ),
        const Radius.circular(0.07),
      ),
      _doorPaint,
    );

    canvas.drawCircle(
      const Offset(
        2.10,
        -1.05,
      ),
      0.07,
      _roofShadowPaint,
    );

    _drawWindow(
      canvas,
      -0.55,
      -2.25,
    );

    _drawWindow(
      canvas,
      2.45,
      -2.25,
    );

    for (int i = 0; i < 7; i++) {
      canvas.drawCircle(
        Offset(
          -0.85 + (i * 0.55),
          -0.05,
        ),
        0.13,
        _stonePaint,
      );
    }
  }

  void _drawWindow(
    Canvas canvas,
    double x,
    double y,
  ) {
    final Rect window = Rect.fromLTWH(
      x,
      y,
      0.78,
      0.82,
    );

    canvas.drawRect(
      window,
      _windowPaint,
    );

    canvas.drawRect(
      window,
      _windowFramePaint,
    );

    canvas.drawLine(
      Offset(
        x + 0.39,
        y,
      ),
      Offset(
        x + 0.39,
        y + 0.82,
      ),
      _windowFramePaint,
    );

    canvas.drawLine(
      Offset(
        x,
        y + 0.41,
      ),
      Offset(
        x + 0.78,
        y + 0.41,
      ),
      _windowFramePaint,
    );
  }
}

// ----------------------------------------------------
// HINTERGRUND
// ----------------------------------------------------

class PhysicsLandscape extends PositionComponent {
  PhysicsLandscape()
      : super(
          priority: -100,
        );

  final Paint _farMountainPaint = Paint()
    ..color = const Color(0xFF9DB4BD);

  final Paint _middleMountainPaint = Paint()
    ..color = const Color(0xFF78949B);

  final Paint _hillPaint = Paint()
    ..color = const Color(0xFF587D57);

  final Paint _forestPaint = Paint()
    ..color = const Color(0xFF3D6748);

  final Paint _trunkPaint = Paint()
    ..color = const Color(0xFF4B4334);

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
      ..moveTo(-40, 9)
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
      ..lineTo(158, 3.2)
      ..lineTo(175, 0.3)
      ..lineTo(190, 4.0)
      ..lineTo(190, 9)
      ..close();

    canvas.drawPath(
      path,
      _farMountainPaint,
    );
  }

  void _drawMiddleMountains(Canvas canvas) {
    final Path path = Path()
      ..moveTo(-40, 9)
      ..lineTo(-40, 5.5)
      ..quadraticBezierTo(-30, 2.2, -20, 5.2)
      ..quadraticBezierTo(-8, 1.6, 4, 5.0)
      ..quadraticBezierTo(16, 2.0, 28, 5.4)
      ..quadraticBezierTo(42, 1.7, 55, 5.1)
      ..quadraticBezierTo(68, 2.4, 82, 5.4)
      ..quadraticBezierTo(96, 1.5, 110, 5.0)
      ..quadraticBezierTo(124, 2.0, 138, 5.3)
      ..quadraticBezierTo(153, 1.8, 168, 5.1)
      ..quadraticBezierTo(180, 2.8, 190, 5.5)
      ..lineTo(190, 9)
      ..close();

    canvas.drawPath(
      path,
      _middleMountainPaint,
    );
  }

  void _drawHills(Canvas canvas) {
    final Path path = Path()
      ..moveTo(-40, 10)
      ..lineTo(-40, 6.5)
      ..quadraticBezierTo(-25, 4.7, -10, 6.6)
      ..quadraticBezierTo(5, 4.8, 20, 6.4)
      ..quadraticBezierTo(35, 4.5, 50, 6.6)
      ..quadraticBezierTo(65, 4.7, 80, 6.5)
      ..quadraticBezierTo(95, 4.4, 110, 6.4)
      ..quadraticBezierTo(125, 4.7, 140, 6.6)
      ..quadraticBezierTo(155, 4.5, 170, 6.4)
      ..quadraticBezierTo(182, 5.0, 190, 6.5)
      ..lineTo(190, 10)
      ..close();

    canvas.drawPath(
      path,
      _hillPaint,
    );
  }

  void _drawForest(Canvas canvas) {
    for (double x = -35;
        x < 190;
        x += 3.4) {
      final int index =
          ((x + 35) / 3.4).round();

      final double variation =
          (index % 4) * 0.18;

      _drawTree(
        canvas,
        x,
        6.6 + variation,
        1.0 + ((index % 3) * 0.12),
      );
    }
  }

  void _drawTree(
    Canvas canvas,
    double x,
    double y,
    double scale,
  ) {
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(
          x,
          y - (0.45 * scale),
        ),
        width: 0.12 * scale,
        height: 0.9 * scale,
      ),
      _trunkPaint,
    );

    final Path tree = Path()
      ..moveTo(
        x,
        y - (2.0 * scale),
      )
      ..lineTo(
        x - (0.65 * scale),
        y - (0.65 * scale),
      )
      ..lineTo(
        x - (0.35 * scale),
        y - (0.65 * scale),
      )
      ..lineTo(
        x - (0.85 * scale),
        y,
      )
      ..lineTo(
        x + (0.85 * scale),
        y,
      )
      ..lineTo(
        x + (0.35 * scale),
        y - (0.65 * scale),
      )
      ..lineTo(
        x + (0.65 * scale),
        y - (0.65 * scale),
      )
      ..close();

    canvas.drawPath(
      tree,
      _forestPaint,
    );
  }
}

// ----------------------------------------------------
// PHYSIK-TERRAIN
// ----------------------------------------------------

class PhysicsTerrain extends BodyComponent {
  PhysicsTerrain()
      : super(
          renderBody: false,
        );

  final Paint _groundPaint = Paint()
    ..color = const Color(0xFF506F38);

  final Paint _roadPaint = Paint()
    ..color = const Color(0xFF756650)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.45
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static final List<Vector2> _points = [
    Vector2(-10, 8),
    Vector2(0, 8),
    Vector2(8, 8),
    Vector2(13, 7.8),
    Vector2(17, 7.3),
    Vector2(21, 7.6),
    Vector2(25, 8.0),
    Vector2(30, 7.5),
    Vector2(35, 6.4),
    Vector2(40, 5.8),
    Vector2(45, 6.5),
    Vector2(50, 7.5),
    Vector2(55, 8.2),
    Vector2(60, 8.8),
    Vector2(65, 8.4),
    Vector2(70, 7.6),
    Vector2(74, 6.9),
    Vector2(78, 7.7),
    Vector2(82, 6.8),
    Vector2(86, 7.8),
    Vector2(92, 7.2),
    Vector2(98, 6.2),
    Vector2(104, 5.2),
    Vector2(110, 4.7),
    Vector2(116, 5.3),
    Vector2(122, 6.5),
    Vector2(128, 7.6),
    Vector2(136, 8.0),
    Vector2(145, 8.0),
    Vector2(155, 8.0),
  ];

  @override
  Body createBody() {
    final BodyDef bodyDef = BodyDef(
      type: BodyType.static,
      position: Vector2.zero(),
    );

    final Body terrainBody =
        world.createBody(
      bodyDef,
    );

    final List<Vector2> collisionPoints =
        _points
            .map(
              (point) => Vector2(
                point.x,
                point.y,
              ),
            )
            .toList();

    terrainBody.createChain(
      ChainDef(
        points: collisionPoints,
        isLoop: false,
      ),
    );

    return terrainBody;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final Path groundPath = Path()
      ..moveTo(
        _points.first.x,
        _points.first.y,
      );

    for (int i = 1;
        i < _points.length;
        i++) {
      groundPath.lineTo(
        _points[i].x,
        _points[i].y,
      );
    }

    groundPath
      ..lineTo(
        _points.last.x,
        20,
      )
      ..lineTo(
        _points.first.x,
        20,
      )
      ..close();

    canvas.drawPath(
      groundPath,
      _groundPaint,
    );

    final Path roadPath = Path()
      ..moveTo(
        _points.first.x,
        _points.first.y,
      );

    for (int i = 1;
        i < _points.length;
        i++) {
      roadPath.lineTo(
        _points[i].x,
        _points[i].y,
      );
    }

    canvas.drawPath(
      roadPath,
      _roadPaint,
    );
  }
}