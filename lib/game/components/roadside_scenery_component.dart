import 'dart:ui';

import 'package:flame/components.dart';

import 'terrain_component.dart';

class RoadsideSceneryComponent extends PositionComponent {
  RoadsideSceneryComponent({required this.terrain, required this.worldWidth})
    : super(
        position: Vector2.zero(),
        size: Vector2(worldWidth, 400),
        priority: 5,
      );

  final TerrainComponent terrain;
  final double worldWidth;

  final Paint _darkTreePaint = Paint()..color = const Color(0xFF21452E);

  final Paint _lightTreePaint = Paint()..color = const Color(0xFF315C3A);

  final Paint _trunkPaint = Paint()..color = const Color(0xFF60452F);

  final Paint _rockPaint = Paint()..color = const Color(0xFF626B68);

  final Paint _rockHighlightPaint = Paint()..color = const Color(0xFF818A86);

  final Paint _grassPaint = Paint()..color = const Color(0xFF365C2D);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _drawTree(canvas, x: 340, height: 88, width: 48, paint: _darkTreePaint);

    _drawTree(canvas, x: 430, height: 118, width: 62, paint: _lightTreePaint);

    _drawGrass(canvas, x: 535, size: 16);

    _drawRock(canvas, x: 610, width: 34, height: 20);

    _drawTree(canvas, x: 790, height: 100, width: 54, paint: _darkTreePaint);

    _drawTree(canvas, x: 875, height: 72, width: 42, paint: _lightTreePaint);

    _drawGrass(canvas, x: 1010, size: 20);

    _drawRock(canvas, x: 1160, width: 46, height: 28);

    _drawTree(canvas, x: 1240, height: 125, width: 66, paint: _darkTreePaint);

    // Bereich um die Routenwahl absichtlich etwas freier.
    _drawGrass(canvas, x: 1360, size: 15);

    _drawTree(canvas, x: 1580, height: 92, width: 50, paint: _lightTreePaint);

    _drawRock(canvas, x: 1680, width: 38, height: 23);

    _drawTree(canvas, x: 1800, height: 128, width: 68, paint: _darkTreePaint);

    _drawGrass(canvas, x: 1910, size: 19);

    _drawTree(canvas, x: 2070, height: 78, width: 44, paint: _lightTreePaint);

    _drawRock(canvas, x: 2180, width: 52, height: 31);

    _drawTree(canvas, x: 2320, height: 112, width: 58, paint: _darkTreePaint);

    _drawTree(canvas, x: 2420, height: 82, width: 45, paint: _lightTreePaint);

    _drawGrass(canvas, x: 2550, size: 22);

    _drawRock(canvas, x: 2740, width: 40, height: 24);

    _drawTree(canvas, x: 2850, height: 120, width: 64, paint: _darkTreePaint);

    _drawTree(canvas, x: 2970, height: 76, width: 42, paint: _lightTreePaint);

    _drawGrass(canvas, x: 3090, size: 17);

    _drawRock(canvas, x: 3190, width: 48, height: 29);

    _drawTree(canvas, x: 3280, height: 104, width: 56, paint: _darkTreePaint);
  }

  void _drawTree(
    Canvas canvas, {
    required double x,
    required double height,
    required double width,
    required Paint paint,
  }) {
    final double groundY = terrain.getGroundY(x);

    final double trunkHeight = height * 0.30;

    final double trunkWidth = width * 0.16;

    canvas.drawRect(
      Rect.fromLTWH(
        x - (trunkWidth / 2),
        groundY - trunkHeight,
        trunkWidth,
        trunkHeight,
      ),
      _trunkPaint,
    );

    final double crownBottom = groundY - (trunkHeight * 0.35);

    final Path lowerCrown = Path();

    lowerCrown.moveTo(x, groundY - height);

    lowerCrown.lineTo(x - (width / 2), crownBottom);

    lowerCrown.lineTo(x + (width / 2), crownBottom);

    lowerCrown.close();

    canvas.drawPath(lowerCrown, paint);

    final Path middleCrown = Path();

    middleCrown.moveTo(x, groundY - (height * 1.08));

    middleCrown.lineTo(x - (width * 0.40), groundY - (height * 0.38));

    middleCrown.lineTo(x + (width * 0.40), groundY - (height * 0.38));

    middleCrown.close();

    canvas.drawPath(middleCrown, paint);

    final Path upperCrown = Path();

    upperCrown.moveTo(x, groundY - (height * 1.15));

    upperCrown.lineTo(x - (width * 0.29), groundY - (height * 0.60));

    upperCrown.lineTo(x + (width * 0.29), groundY - (height * 0.60));

    upperCrown.close();

    canvas.drawPath(upperCrown, paint);
  }

  void _drawRock(
    Canvas canvas, {
    required double x,
    required double width,
    required double height,
  }) {
    final double groundY = terrain.getGroundY(x);

    final Path rock = Path();

    rock.moveTo(x - (width / 2), groundY);

    rock.lineTo(x - (width * 0.35), groundY - (height * 0.65));

    rock.lineTo(x - (width * 0.08), groundY - height);

    rock.lineTo(x + (width * 0.28), groundY - (height * 0.82));

    rock.lineTo(x + (width / 2), groundY);

    rock.close();

    canvas.drawPath(rock, _rockPaint);

    final Path highlight = Path();

    highlight.moveTo(x - (width * 0.08), groundY - height);

    highlight.lineTo(x + (width * 0.28), groundY - (height * 0.82));

    highlight.lineTo(x + (width * 0.10), groundY - (height * 0.45));

    highlight.close();

    canvas.drawPath(highlight, _rockHighlightPaint);
  }

  void _drawGrass(Canvas canvas, {required double x, required double size}) {
    final double groundY = terrain.getGroundY(x);

    final Paint grassLinePaint = Paint()
      ..color = _grassPaint.color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(x, groundY),
      Offset(x - (size * 0.55), groundY - size),
      grassLinePaint,
    );

    canvas.drawLine(
      Offset(x, groundY),
      Offset(x, groundY - (size * 1.25)),
      grassLinePaint,
    );

    canvas.drawLine(
      Offset(x, groundY),
      Offset(x + (size * 0.55), groundY - (size * 0.90)),
      grassLinePaint,
    );
  }
}
