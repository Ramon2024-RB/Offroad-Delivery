import 'dart:ui';

import 'package:flame/components.dart';

class BackgroundComponent extends PositionComponent {
  BackgroundComponent({
    required this.worldWidth,
  }) : super(
          position: Vector2.zero(),
          size: Vector2(worldWidth, 400),
          priority: -100,
        );

  final double worldWidth;

  final Paint _skyPaint = Paint()
    ..color = const Color(0xFF87B7D9);

  final Paint _farMountainPaint = Paint()
    ..color = const Color(0xFF78919A);

  final Paint _farHillPaint = Paint()
    ..color = const Color(0xFF58786B);

  final Paint _farTreePaint = Paint()
    ..color = const Color(0xFF355A43);

  final Paint _farTreeDarkPaint = Paint()
    ..color = const Color(0xFF2C4F39);

  final Paint _trunkPaint = Paint()
    ..color = const Color(0xFF4D493A);

  final List<Vector2> _backgroundGroundPoints = [
    Vector2(0, 275),
    Vector2(180, 265),
    Vector2(360, 280),
    Vector2(540, 250),
    Vector2(720, 260),
    Vector2(900, 235),
    Vector2(1080, 250),
    Vector2(1260, 270),
    Vector2(1440, 245),
    Vector2(1620, 230),
    Vector2(1800, 250),
    Vector2(1980, 265),
    Vector2(2160, 240),
    Vector2(2340, 225),
    Vector2(2520, 245),
    Vector2(2700, 270),
    Vector2(2880, 250),
    Vector2(3060, 235),
    Vector2(3240, 255),
    Vector2(3420, 240),
    Vector2(3600, 260),
  ];

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _drawSky(canvas);
    _drawFarMountains(canvas);
    _drawBackgroundHills(canvas);
    _drawBackgroundForest(canvas);
  }

  void _drawSky(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        worldWidth,
        size.y,
      ),
      _skyPaint,
    );
  }

  void _drawFarMountains(Canvas canvas) {
    final Path mountains = Path();

    mountains.moveTo(0, 245);

    mountains.lineTo(170, 175);
    mountains.lineTo(310, 220);

    mountains.lineTo(500, 115);
    mountains.lineTo(690, 225);

    mountains.lineTo(900, 155);
    mountains.lineTo(1080, 215);

    mountains.lineTo(1280, 105);
    mountains.lineTo(1480, 220);

    mountains.lineTo(1680, 150);
    mountains.lineTo(1870, 225);

    mountains.lineTo(2080, 125);
    mountains.lineTo(2290, 215);

    mountains.lineTo(2490, 145);
    mountains.lineTo(2690, 225);

    mountains.lineTo(2910, 110);
    mountains.lineTo(3120, 215);

    mountains.lineTo(3320, 150);
    mountains.lineTo(3500, 220);

    mountains.lineTo(worldWidth, 180);

    mountains.lineTo(
      worldWidth,
      size.y,
    );

    mountains.lineTo(
      0,
      size.y,
    );

    mountains.close();

    canvas.drawPath(
      mountains,
      _farMountainPaint,
    );
  }

  void _drawBackgroundHills(Canvas canvas) {
    final Path hills = Path();

    hills.moveTo(
      _backgroundGroundPoints.first.x,
      _backgroundGroundPoints.first.y,
    );

    for (
      final Vector2 point
      in _backgroundGroundPoints.skip(1)
    ) {
      hills.lineTo(
        point.x,
        point.y,
      );
    }

    hills.lineTo(
      worldWidth,
      size.y,
    );

    hills.lineTo(
      0,
      size.y,
    );

    hills.close();

    canvas.drawPath(
      hills,
      _farHillPaint,
    );
  }

  void _drawBackgroundForest(Canvas canvas) {
    _drawTreeGroup(
      canvas,
      startX: 80,
      treeCount: 5,
      spacing: 46,
    );

    _drawTreeGroup(
      canvas,
      startX: 390,
      treeCount: 3,
      spacing: 55,
    );

    _drawTreeGroup(
      canvas,
      startX: 650,
      treeCount: 6,
      spacing: 43,
    );

    _drawTreeGroup(
      canvas,
      startX: 1030,
      treeCount: 4,
      spacing: 52,
    );

    _drawTreeGroup(
      canvas,
      startX: 1340,
      treeCount: 7,
      spacing: 42,
    );

    _drawTreeGroup(
      canvas,
      startX: 1770,
      treeCount: 3,
      spacing: 58,
    );

    _drawTreeGroup(
      canvas,
      startX: 2050,
      treeCount: 6,
      spacing: 45,
    );

    _drawTreeGroup(
      canvas,
      startX: 2440,
      treeCount: 4,
      spacing: 54,
    );

    _drawTreeGroup(
      canvas,
      startX: 2760,
      treeCount: 7,
      spacing: 41,
    );

    _drawTreeGroup(
      canvas,
      startX: 3200,
      treeCount: 5,
      spacing: 48,
    );
  }

  void _drawTreeGroup(
    Canvas canvas, {
    required double startX,
    required int treeCount,
    required double spacing,
  }) {
    for (int i = 0; i < treeCount; i++) {
      final double x =
          startX + (i * spacing);

      final double heightVariation =
          (i % 3) * 8;

      final double widthVariation =
          (i % 2) * 5;

      final bool darker =
          i.isEven;

      _drawBackgroundTree(
        canvas,
        x: x,
        height: 52 + heightVariation,
        width: 28 + widthVariation,
        paint: darker
            ? _farTreeDarkPaint
            : _farTreePaint,
      );
    }
  }

  void _drawBackgroundTree(
    Canvas canvas, {
    required double x,
    required double height,
    required double width,
    required Paint paint,
  }) {
    final double groundY =
        _getBackgroundGroundY(x);

    final double trunkHeight =
        height * 0.25;

    final double trunkWidth =
        width * 0.12;

    canvas.drawRect(
      Rect.fromLTWH(
        x - (trunkWidth / 2),
        groundY - trunkHeight,
        trunkWidth,
        trunkHeight,
      ),
      _trunkPaint,
    );

    final Path lowerCrown = Path();

    lowerCrown.moveTo(
      x,
      groundY - height,
    );

    lowerCrown.lineTo(
      x - (width / 2),
      groundY - (height * 0.12),
    );

    lowerCrown.lineTo(
      x + (width / 2),
      groundY - (height * 0.12),
    );

    lowerCrown.close();

    canvas.drawPath(
      lowerCrown,
      paint,
    );

    final Path middleCrown = Path();

    middleCrown.moveTo(
      x,
      groundY - (height * 1.12),
    );

    middleCrown.lineTo(
      x - (width * 0.40),
      groundY - (height * 0.40),
    );

    middleCrown.lineTo(
      x + (width * 0.40),
      groundY - (height * 0.40),
    );

    middleCrown.close();

    canvas.drawPath(
      middleCrown,
      paint,
    );

    final Path upperCrown = Path();

    upperCrown.moveTo(
      x,
      groundY - (height * 1.22),
    );

    upperCrown.lineTo(
      x - (width * 0.28),
      groundY - (height * 0.68),
    );

    upperCrown.lineTo(
      x + (width * 0.28),
      groundY - (height * 0.68),
    );

    upperCrown.close();

    canvas.drawPath(
      upperCrown,
      paint,
    );
  }

  double _getBackgroundGroundY(
    double x,
  ) {
    if (x <=
        _backgroundGroundPoints.first.x) {
      return _backgroundGroundPoints
          .first.y;
    }

    if (x >=
        _backgroundGroundPoints.last.x) {
      return _backgroundGroundPoints
          .last.y;
    }

    for (
      int i = 0;
      i <
          _backgroundGroundPoints.length -
              1;
      i++
    ) {
      final Vector2 start =
          _backgroundGroundPoints[i];

      final Vector2 end =
          _backgroundGroundPoints[i + 1];

      if (x >= start.x &&
          x <= end.x) {
        final double progress =
            (x - start.x) /
                (end.x - start.x);

        return start.y +
            ((end.y - start.y) *
                progress);
      }
    }

    return _backgroundGroundPoints.last.y;
  }
}