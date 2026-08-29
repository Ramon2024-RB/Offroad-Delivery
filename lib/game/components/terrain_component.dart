import 'dart:ui';

import 'package:flame/components.dart';

enum TerrainRoute { safe, risk }

class TerrainComponent extends PositionComponent {
  TerrainComponent({required this.worldWidth})
    : super(position: Vector2.zero(), size: Vector2(worldWidth, 400));

  final double worldWidth;

  TerrainRoute _selectedRoute = TerrainRoute.safe;

  final List<Vector2> _startPoints = [
    Vector2(0, 300),
    Vector2(300, 300),
    Vector2(500, 285),
    Vector2(700, 255),
    Vector2(900, 270),
    Vector2(1100, 300),
    Vector2(1300, 290),
    Vector2(1450, 275),
  ];

  final List<Vector2> _safeRoutePoints = [
    Vector2(1450, 275),
    Vector2(1600, 270),
    Vector2(1750, 260),
    Vector2(1900, 270),
    Vector2(2050, 285),
    Vector2(2200, 280),
    Vector2(2350, 265),
    Vector2(2500, 275),
    Vector2(2650, 290),
  ];

  final List<Vector2> _riskRoutePoints = [
    Vector2(1450, 275),
    Vector2(1580, 235),
    Vector2(1700, 310),
    Vector2(1820, 220),
    Vector2(1950, 315),
    Vector2(2080, 230),
    Vector2(2210, 305),
    Vector2(2340, 225),
    Vector2(2470, 300),
    Vector2(2650, 290),
  ];

  final List<Vector2> _endPoints = [
    Vector2(2650, 290),
    Vector2(2850, 300),
    Vector2(3050, 285),
    Vector2(3250, 270),
    Vector2(3450, 300),
    Vector2(3600, 300),
  ];

  final Paint _groundPaint = Paint()..color = const Color(0xFF4D6B35);

  final Paint _roadPaint = Paint()
    ..color = const Color(0xFF7A6A55)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 18
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  List<Vector2> get terrainPoints {
    final List<Vector2> routePoints;

    switch (_selectedRoute) {
      case TerrainRoute.safe:
        routePoints = _safeRoutePoints;
      case TerrainRoute.risk:
        routePoints = _riskRoutePoints;
    }

    return [..._startPoints, ...routePoints.skip(1), ..._endPoints.skip(1)];
  }

  void selectSafeRoute() {
    _selectedRoute = TerrainRoute.safe;
  }

  void selectRiskRoute() {
    _selectedRoute = TerrainRoute.risk;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final List<Vector2> points = terrainPoints;

    if (points.length < 2) {
      return;
    }

    final Path groundPath = Path();

    groundPath.moveTo(points.first.x, points.first.y);

    for (final Vector2 point in points.skip(1)) {
      groundPath.lineTo(point.x, point.y);
    }

    groundPath.lineTo(worldWidth, size.y);

    groundPath.lineTo(0, size.y);

    groundPath.close();

    canvas.drawPath(groundPath, _groundPaint);

    final Path roadPath = Path();

    roadPath.moveTo(points.first.x, points.first.y);

    for (final Vector2 point in points.skip(1)) {
      roadPath.lineTo(point.x, point.y);
    }

    canvas.drawPath(roadPath, _roadPaint);
  }

  double getGroundY(double x) {
    final List<Vector2> points = terrainPoints;

    if (x <= points.first.x) {
      return points.first.y;
    }

    if (x >= points.last.x) {
      return points.last.y;
    }

    for (int i = 0; i < points.length - 1; i++) {
      final Vector2 start = points[i];
      final Vector2 end = points[i + 1];

      if (x >= start.x && x <= end.x) {
        final double progress = (x - start.x) / (end.x - start.x);

        return start.y + ((end.y - start.y) * progress);
      }
    }

    return points.last.y;
  }

  double getGroundAngle(double x) {
    final List<Vector2> points = terrainPoints;

    if (x <= points.first.x) {
      x = points.first.x;
    }

    if (x >= points.last.x) {
      x = points.last.x - 0.01;
    }

    for (int i = 0; i < points.length - 1; i++) {
      final Vector2 start = points[i];
      final Vector2 end = points[i + 1];

      if (x >= start.x && x <= end.x) {
        final double deltaX = end.x - start.x;

        final double deltaY = end.y - start.y;

        return Offset(deltaX, deltaY).direction;
      }
    }

    return 0;
  }
}
