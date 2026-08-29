import 'dart:ui';

import 'package:flame/components.dart';

class ParallaxBackgroundComponent extends PositionComponent {
  ParallaxBackgroundComponent({
    required this.worldWidth,
  }) : super(
          position: Vector2.zero(),
          size: Vector2(worldWidth, 400),
          priority: -200,
        );

  final double worldWidth;

  double cameraX = 0;

  static const double _drawingStartX = -1800;
  static const double _drawingEndX = 6200;

  final Paint _skyPaint = Paint()
    ..color = const Color(0xFF87B7D9);

  final Paint _farMountainPaint = Paint()
    ..color = const Color(0xFF8198A0);

  final Paint _middleMountainPaint = Paint()
    ..color = const Color(0xFF687F78);

  final Paint _farHillPaint = Paint()
    ..color = const Color(0xFF4E6F5A);

  final Paint _farTreePaint = Paint()
    ..color = const Color(0xFF355A43);

  final Paint _farTreeDarkPaint = Paint()
    ..color = const Color(0xFF294B36);

  final Paint _trunkPaint = Paint()
    ..color = const Color(0xFF4B493B);

  void updateCameraPosition(double x) {
    cameraX = x;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _drawSky(canvas);

    canvas.save();
    canvas.translate(
      cameraX * 0.78,
      0,
    );
    _drawFarMountains(canvas);
    canvas.restore();

    canvas.save();
    canvas.translate(
      cameraX * 0.60,
      0,
    );
    _drawMiddleMountains(canvas);
    canvas.restore();

    canvas.save();
    canvas.translate(
      cameraX * 0.38,
      0,
    );
    _drawFarHills(canvas);
    _drawFarForest(canvas);
    canvas.restore();
  }

  void _drawSky(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(
        _drawingStartX,
        0,
        _drawingEndX - _drawingStartX,
        size.y,
      ),
      _skyPaint,
    );
  }

  void _drawFarMountains(Canvas canvas) {
    final List<Offset> points = [
      const Offset(_drawingStartX, 255),
      const Offset(-1600, 230),
      const Offset(-1420, 175),
      const Offset(-1260, 215),
      const Offset(-1080, 145),
      const Offset(-900, 205),
      const Offset(-720, 235),
      const Offset(-500, 165),
      const Offset(-320, 205),
      const Offset(-100, 120),
      const Offset(100, 190),
      const Offset(300, 225),
      const Offset(520, 155),
      const Offset(700, 205),
      const Offset(930, 105),
      const Offset(1130, 185),
      const Offset(1320, 225),
      const Offset(1540, 150),
      const Offset(1740, 205),
      const Offset(1960, 125),
      const Offset(2160, 195),
      const Offset(2370, 225),
      const Offset(2590, 145),
      const Offset(2790, 205),
      const Offset(3010, 115),
      const Offset(3220, 190),
      const Offset(3420, 225),
      const Offset(3650, 155),
      const Offset(3860, 205),
      const Offset(4080, 130),
      const Offset(4290, 195),
      const Offset(4500, 225),
      const Offset(4720, 150),
      const Offset(4930, 205),
      const Offset(5150, 120),
      const Offset(5360, 190),
      const Offset(5580, 225),
      const Offset(5800, 160),
      const Offset(6000, 210),
      const Offset(_drawingEndX, 235),
    ];

    _drawSmoothLandscape(
      canvas,
      points: points,
      paint: _farMountainPaint,
      bottomY: 400,
    );
  }

  void _drawMiddleMountains(Canvas canvas) {
    final List<Offset> points = [
      const Offset(_drawingStartX, 285),
      const Offset(-1550, 260),
      const Offset(-1320, 220),
      const Offset(-1100, 255),
      const Offset(-850, 195),
      const Offset(-620, 250),
      const Offset(-380, 270),
      const Offset(-120, 215),
      const Offset(120, 255),
      const Offset(380, 185),
      const Offset(620, 245),
      const Offset(850, 270),
      const Offset(1110, 205),
      const Offset(1350, 250),
      const Offset(1600, 190),
      const Offset(1840, 245),
      const Offset(2080, 270),
      const Offset(2340, 210),
      const Offset(2580, 250),
      const Offset(2830, 185),
      const Offset(3070, 245),
      const Offset(3310, 270),
      const Offset(3560, 205),
      const Offset(3800, 250),
      const Offset(4050, 195),
      const Offset(4290, 245),
      const Offset(4530, 270),
      const Offset(4780, 210),
      const Offset(5020, 250),
      const Offset(5270, 190),
      const Offset(5510, 245),
      const Offset(5750, 270),
      const Offset(6000, 215),
      const Offset(_drawingEndX, 255),
    ];

    _drawSmoothLandscape(
      canvas,
      points: points,
      paint: _middleMountainPaint,
      bottomY: 400,
    );
  }

  void _drawFarHills(Canvas canvas) {
    final List<Offset> points = [];

    const double sectionWidth = 240;

    for (
      double x = _drawingStartX;
      x <= _drawingEndX;
      x += sectionWidth
    ) {
      points.add(
        Offset(
          x,
          _farHillGroundY(x),
        ),
      );
    }

    _drawSmoothLandscape(
      canvas,
      points: points,
      paint: _farHillPaint,
      bottomY: 400,
    );
  }

  void _drawSmoothLandscape(
    Canvas canvas, {
    required List<Offset> points,
    required Paint paint,
    required double bottomY,
  }) {
    if (points.length < 2) {
      return;
    }

    final Path path = Path();

    path.moveTo(
      points.first.dx,
      points.first.dy,
    );

    for (int i = 0; i < points.length - 1; i++) {
      final Offset current = points[i];
      final Offset next = points[i + 1];

      final double middleX =
          (current.dx + next.dx) / 2;

      final double middleY =
          (current.dy + next.dy) / 2;

      path.quadraticBezierTo(
        current.dx,
        current.dy,
        middleX,
        middleY,
      );
    }

    path.lineTo(
      points.last.dx,
      points.last.dy,
    );

    path.lineTo(
      points.last.dx,
      bottomY,
    );

    path.lineTo(
      points.first.dx,
      bottomY,
    );

    path.close();

    canvas.drawPath(
      path,
      paint,
    );
  }

  void _drawFarForest(Canvas canvas) {
    final List<_TreeGroup> groups = [
      const _TreeGroup(-1600, 5, 43),
      const _TreeGroup(-1280, 3, 52),
      const _TreeGroup(-970, 7, 40),
      const _TreeGroup(-520, 4, 49),
      const _TreeGroup(-180, 6, 42),
      const _TreeGroup(220, 3, 55),
      const _TreeGroup(520, 7, 39),
      const _TreeGroup(980, 4, 51),
      const _TreeGroup(1320, 6, 43),
      const _TreeGroup(1740, 3, 57),
      const _TreeGroup(2050, 7, 40),
      const _TreeGroup(2510, 5, 47),
      const _TreeGroup(2890, 3, 54),
      const _TreeGroup(3200, 7, 41),
      const _TreeGroup(3660, 4, 50),
      const _TreeGroup(4010, 6, 42),
      const _TreeGroup(4420, 3, 56),
      const _TreeGroup(4730, 7, 40),
      const _TreeGroup(5190, 5, 46),
      const _TreeGroup(5570, 3, 53),
      const _TreeGroup(5870, 6, 42),
    ];

    for (
      int groupIndex = 0;
      groupIndex < groups.length;
      groupIndex++
    ) {
      final _TreeGroup group =
          groups[groupIndex];

      for (
        int treeIndex = 0;
        treeIndex < group.count;
        treeIndex++
      ) {
        final double spacingVariation =
            (treeIndex % 3) * 5;

        final double x =
            group.startX +
            (treeIndex *
                (group.spacing +
                    spacingVariation));

        final double groundY =
            _farHillGroundY(x);

        final double height =
            38 +
            (((treeIndex * 7) +
                        (groupIndex * 3)) %
                    24);

        final double width =
            22 +
            (((treeIndex * 5) +
                        groupIndex) %
                    11);

        final Paint treePaint =
            (treeIndex + groupIndex).isEven
                ? _farTreeDarkPaint
                : _farTreePaint;

        _drawTree(
          canvas,
          x: x,
          groundY: groundY,
          height: height,
          width: width,
          paint: treePaint,
        );
      }
    }
  }

  double _farHillGroundY(double x) {
    const double sectionWidth = 240;

    final double normalized =
        (x - _drawingStartX) /
            sectionWidth;

    final int sectionIndex =
        normalized.floor();

    final double progress =
        normalized - sectionIndex;

    final double startY =
        _hillHeight(sectionIndex);

    final double endY =
        _hillHeight(sectionIndex + 1);

    final double smoothProgress =
        progress *
        progress *
        (3 - (2 * progress));

    return startY +
        ((endY - startY) *
            smoothProgress);
  }

  double _hillHeight(int index) {
    const List<double> heights = [
      286,
      274,
      279,
      258,
      266,
      247,
      255,
      273,
      264,
      243,
      252,
      269,
      278,
      259,
      246,
      254,
      272,
      263,
      242,
      250,
      268,
      276,
      257,
      245,
      253,
      271,
      261,
      244,
      255,
      273,
      265,
      248,
      258,
      275,
      264,
    ];

    int wrappedIndex =
        index % heights.length;

    if (wrappedIndex < 0) {
      wrappedIndex += heights.length;
    }

    return heights[wrappedIndex];
  }

  void _drawTree(
    Canvas canvas, {
    required double x,
    required double groundY,
    required double height,
    required double width,
    required Paint paint,
  }) {
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
      groundY - (height * 0.10),
    );

    lowerCrown.lineTo(
      x + (width / 2),
      groundY - (height * 0.10),
    );

    lowerCrown.close();

    canvas.drawPath(
      lowerCrown,
      paint,
    );

    final Path middleCrown = Path();

    middleCrown.moveTo(
      x,
      groundY - (height * 1.10),
    );

    middleCrown.lineTo(
      x - (width * 0.39),
      groundY - (height * 0.39),
    );

    middleCrown.lineTo(
      x + (width * 0.39),
      groundY - (height * 0.39),
    );

    middleCrown.close();

    canvas.drawPath(
      middleCrown,
      paint,
    );

    final Path upperCrown = Path();

    upperCrown.moveTo(
      x,
      groundY - (height * 1.20),
    );

    upperCrown.lineTo(
      x - (width * 0.27),
      groundY - (height * 0.66),
    );

    upperCrown.lineTo(
      x + (width * 0.27),
      groundY - (height * 0.66),
    );

    upperCrown.close();

    canvas.drawPath(
      upperCrown,
      paint,
    );
  }
}

class _TreeGroup {
  const _TreeGroup(
    this.startX,
    this.count,
    this.spacing,
  );

  final double startX;
  final int count;
  final double spacing;
}