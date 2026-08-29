import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

class PhysicsWheel extends BodyComponent {
  PhysicsWheel({required this.startPosition, this.radius = 0.48})
    : super(renderBody: false);

  final Vector2 startPosition;
  final double radius;

  final Paint _tirePaint = Paint()..color = const Color(0xFF202020);

  final Paint _rimPaint = Paint()..color = const Color(0xFF8B9296);

  final Paint _hubPaint = Paint()..color = const Color(0xFF4B5053);

  final Paint _treadPaint = Paint()
    ..color = const Color(0xFF111111)
    ..strokeWidth = 0.07
    ..strokeCap = StrokeCap.round;

  @override
  Body createBody() {
    final BodyDef bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: startPosition,
      linearDamping: 0.05,
      angularDamping: 0.15,
    );

    final Body wheelBody = world.createBody(bodyDef);

    final Circle wheelShape = Circle(radius: radius);

    final ShapeDef shapeDef = ShapeDef(density: 1.2);

    wheelBody.createShape(wheelShape, shapeDef);

    return wheelBody;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawCircle(Offset.zero, radius, _tirePaint);

    canvas.drawCircle(Offset.zero, radius * 0.58, _rimPaint);

    canvas.drawCircle(Offset.zero, radius * 0.20, _hubPaint);

    _drawTread(canvas);
  }

  void _drawTread(Canvas canvas) {
    const int treadCount = 10;

    for (int i = 0; i < treadCount; i++) {
      final double angle = (i / treadCount) * 2 * 3.141592653589793;

      final double innerRadius = radius * 0.78;

      final double outerRadius = radius * 0.98;

      final Offset start = Offset(
        innerRadius * _cos(angle),
        innerRadius * _sin(angle),
      );

      final Offset end = Offset(
        outerRadius * _cos(angle),
        outerRadius * _sin(angle),
      );

      canvas.drawLine(start, end, _treadPaint);
    }
  }

  double _sin(double value) {
    return _fastSin(value);
  }

  double _cos(double value) {
    return _fastSin(value + 1.5707963267948966);
  }

  double _fastSin(double value) {
    double x = value;

    while (x > 3.141592653589793) {
      x -= 6.283185307179586;
    }

    while (x < -3.141592653589793) {
      x += 6.283185307179586;
    }

    const double b = 4 / 3.141592653589793;

    const double c = -4 / (3.141592653589793 * 3.141592653589793);

    final double y = b * x + c * x * x.abs();

    const double p = 0.225;

    return p * (y * y.abs() - y) + y;
  }
}
