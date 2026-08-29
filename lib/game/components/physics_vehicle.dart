import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

class PhysicsVehicle extends BodyComponent {
  PhysicsVehicle({
    required this.startPosition,
  }) : super(
          renderBody: false,
        );

  final Vector2 startPosition;

  static const double bodyWidth = 4.2;
  static const double bodyHeight = 0.95;

  // Pickup startet wieder OHNE Ladung.
  bool _cargoVisible = false;

  final Paint _bodyPaint = Paint()
    ..color = const Color(0xFFE7E7E7);

  final Paint _bodyShadowPaint = Paint()
    ..color = const Color(0xFFC5C9CB);

  final Paint _windowPaint = Paint()
    ..color = const Color(0xFF557C91);

  final Paint _windowLightPaint = Paint()
    ..color = const Color(0xFF7299AD);

  final Paint _darkPaint = Paint()
    ..color = const Color(0xFF303638);

  final Paint _bedInsidePaint = Paint()
    ..color = const Color(0xFF62696C);

  final Paint _headlightPaint = Paint()
    ..color = const Color(0xFFFFD66B);

  final Paint _rearLightPaint = Paint()
    ..color = const Color(0xFFC74B42);

  final Paint _linePaint = Paint()
    ..color = const Color(0xFF999FA2)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.045;

  final Paint _wheelArchPaint = Paint()
    ..color = const Color(0xFF24282A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.12;

  final Paint _cargoPaint = Paint()
    ..color = const Color(0xFFD9903D);

  final Paint _cargoSidePaint = Paint()
    ..color = const Color(0xFFA9652D);

  final Paint _cargoTapePaint = Paint()
    ..color = const Color(0xFFFFD080);

  final Paint _cargoOutlinePaint = Paint()
    ..color = const Color(0xFF71451F)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.07;

  bool get cargoVisible => _cargoVisible;

  void showCargo() {
    _cargoVisible = true;
  }

  void hideCargo() {
    _cargoVisible = false;
  }

  @override
  Body createBody() {
    final BodyDef bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: startPosition,
      linearDamping: 0.15,
      angularDamping: 1.2,
    );

    final Body vehicleBody = world.createBody(
      bodyDef,
    );

    final Polygon bodyShape = Polygon.box(
      bodyWidth / 2,
      bodyHeight / 2,
      radius: 0.08,
    );

    final ShapeDef shapeDef = ShapeDef(
      density: 1.8,
    );

    vehicleBody.createShape(
      bodyShape,
      shapeDef,
    );

    return vehicleBody;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _drawLowerBody(canvas);
    _drawTruckBed(canvas);
    _drawCabin(canvas);
    _drawHood(canvas);
    _drawWheelArches(canvas);
    _drawDetails(canvas);

    if (_cargoVisible) {
      _drawCargo(canvas);
    }
  }

  void _drawLowerBody(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          -2.1,
          -0.45,
          4.2,
          0.90,
        ),
        const Radius.circular(0.12),
      ),
      _bodyPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        -1.92,
        0.20,
        3.78,
        0.27,
      ),
      _bodyShadowPaint,
    );
  }

  void _drawTruckBed(Canvas canvas) {
    // Ladefläche hinten links.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          -2.02,
          -0.68,
          1.62,
          0.85,
        ),
        const Radius.circular(0.07),
      ),
      _bodyPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        -1.90,
        -0.72,
        1.38,
        0.13,
      ),
      _bedInsidePaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        -0.52,
        -0.80,
        0.10,
        0.95,
      ),
      _bodyShadowPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        -2.03,
        -0.55,
        0.08,
        0.66,
      ),
      _bodyShadowPaint,
    );
  }

  void _drawCabin(Canvas canvas) {
    final Path cabin = Path()
      ..moveTo(-0.48, -0.45)
      ..lineTo(-0.18, -1.36)
      ..quadraticBezierTo(
        -0.12,
        -1.53,
        0.10,
        -1.53,
      )
      ..lineTo(0.92, -1.53)
      ..quadraticBezierTo(
        1.12,
        -1.51,
        1.26,
        -1.31,
      )
      ..lineTo(1.55, -0.45)
      ..close();

    canvas.drawPath(
      cabin,
      _bodyPaint,
    );

    final Path rearWindow = Path()
      ..moveTo(-0.08, -1.36)
      ..lineTo(0.40, -1.36)
      ..lineTo(0.40, -0.58)
      ..lineTo(-0.32, -0.58)
      ..close();

    canvas.drawPath(
      rearWindow,
      _windowLightPaint,
    );

    final Path frontWindow = Path()
      ..moveTo(0.50, -1.36)
      ..lineTo(0.88, -1.36)
      ..quadraticBezierTo(
        1.00,
        -1.34,
        1.08,
        -1.22,
      )
      ..lineTo(1.35, -0.58)
      ..lineTo(0.50, -0.58)
      ..close();

    canvas.drawPath(
      frontWindow,
      _windowPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        0.39,
        -1.40,
        0.11,
        0.86,
      ),
      _darkPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          -0.34,
          -0.52,
          0.78,
          0.90,
        ),
        const Radius.circular(0.04),
      ),
      _linePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          0.46,
          -0.52,
          0.88,
          0.90,
        ),
        const Radius.circular(0.04),
      ),
      _linePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          0.12,
          -0.30,
          0.22,
          0.065,
        ),
        const Radius.circular(0.03),
      ),
      _darkPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          1.00,
          -0.30,
          0.22,
          0.065,
        ),
        const Radius.circular(0.03),
      ),
      _darkPaint,
    );
  }

  void _drawHood(Canvas canvas) {
    final Path hood = Path()
      ..moveTo(1.20, -0.66)
      ..lineTo(1.55, -0.70)
      ..lineTo(2.02, -0.50)
      ..lineTo(2.10, -0.18)
      ..lineTo(1.45, -0.18)
      ..close();

    canvas.drawPath(
      hood,
      _bodyPaint,
    );
  }

  void _drawWheelArches(Canvas canvas) {
    canvas.drawArc(
      const Rect.fromLTWH(
        -1.95,
        -0.12,
        1.00,
        1.00,
      ),
      3.141592653589793,
      3.141592653589793,
      false,
      _wheelArchPaint,
    );

    canvas.drawArc(
      const Rect.fromLTWH(
        0.95,
        -0.12,
        1.00,
        1.00,
      ),
      3.141592653589793,
      3.141592653589793,
      false,
      _wheelArchPaint,
    );
  }

  void _drawDetails(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          -2.20,
          0.14,
          0.32,
          0.25,
        ),
        const Radius.circular(0.06),
      ),
      _darkPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          1.90,
          0.12,
          0.34,
          0.27,
        ),
        const Radius.circular(0.06),
      ),
      _darkPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          -2.05,
          -0.48,
          0.13,
          0.28,
        ),
        const Radius.circular(0.035),
      ),
      _rearLightPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          1.92,
          -0.42,
          0.18,
          0.20,
        ),
        const Radius.circular(0.04),
      ),
      _headlightPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          -0.70,
          0.38,
          2.20,
          0.10,
        ),
        const Radius.circular(0.05),
      ),
      _darkPaint,
    );
  }

  void _drawCargo(Canvas canvas) {
    const Rect cargoRect = Rect.fromLTWH(
      -1.72,
      -1.58,
      1.05,
      0.95,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        cargoRect,
        const Radius.circular(0.06),
      ),
      _cargoPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        -0.82,
        -1.52,
        0.15,
        0.84,
      ),
      _cargoSidePaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        -1.27,
        -1.58,
        0.13,
        0.95,
      ),
      _cargoTapePaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        -1.72,
        -1.17,
        1.05,
        0.13,
      ),
      _cargoTapePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        cargoRect,
        const Radius.circular(0.06),
      ),
      _cargoOutlinePaint,
    );
  }
}