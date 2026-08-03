import 'package:flutter/material.dart';

import 'canvas_primitives.dart';

class CanvasScenePainter extends CustomPainter {
  const CanvasScenePainter({
    required this.backgroundColor,
    this.strokes = const <Stroke>[],
    this.activeStroke,
    this.shapes = const <CanvasShape>[],
    this.textItems = const <CanvasTextItem>[],
    this.showGrid = false,
  });

  final Color backgroundColor;
  final List<Stroke> strokes;
  final Stroke? activeStroke;
  final List<CanvasShape> shapes;
  final List<CanvasTextItem> textItems;
  final bool showGrid;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);

    if (showGrid) {
      _drawGrid(canvas, size);
    }

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    final currentStroke = activeStroke;
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke);
    }

    for (final shape in shapes) {
      _drawShape(canvas, shape);
    }

    for (final textItem in textItems) {
      _drawText(canvas, textItem);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    const spacing = 80.0;
    final gridPaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) {
      return;
    }

    final paint = Paint()
      ..color = stroke.style.resolveColor(backgroundColor)
      ..strokeWidth = stroke.style.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.points.length == 1) {
      canvas.drawCircle(
        stroke.points.first,
        stroke.style.width / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }

    final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
    for (final point in stroke.points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, paint);
  }

  void _drawShape(Canvas canvas, CanvasShape shape) {
    final paint = Paint()
      ..color = shape.color
      ..strokeWidth = shape.strokeWidth
      ..style = PaintingStyle.stroke;
    final rect = Rect.fromCenter(
      center: shape.center,
      width: shape.size.width,
      height: shape.size.height,
    );

    switch (shape.type) {
      case CanvasShapeType.rectangle:
        canvas.drawRect(rect, paint);
      case CanvasShapeType.oval:
        canvas.drawOval(rect, paint);
      case CanvasShapeType.diamond:
        final path = Path()
          ..moveTo(shape.center.dx, rect.top)
          ..lineTo(rect.right, shape.center.dy)
          ..lineTo(shape.center.dx, rect.bottom)
          ..lineTo(rect.left, shape.center.dy)
          ..close();
        canvas.drawPath(path, paint);
      case CanvasShapeType.arrow:
        final start = Offset(rect.left, shape.center.dy);
        final end = Offset(rect.right, shape.center.dy);
        canvas.drawLine(start, end, paint);
        final arrowHead = Path()
          ..moveTo(end.dx, end.dy)
          ..lineTo(end.dx - 18, end.dy - 12)
          ..moveTo(end.dx, end.dy)
          ..lineTo(end.dx - 18, end.dy + 12);
        canvas.drawPath(arrowHead, paint);
    }
  }

  void _drawText(Canvas canvas, CanvasTextItem textItem) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: textItem.text,
        style: TextStyle(
          color: textItem.color,
          fontSize: textItem.fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 240);

    textPainter.paint(canvas, textItem.position);
  }

  @override
  bool shouldRepaint(covariant CanvasScenePainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokes != strokes ||
        oldDelegate.activeStroke != activeStroke ||
        oldDelegate.shapes != shapes ||
        oldDelegate.textItems != textItems ||
        oldDelegate.showGrid != showGrid;
  }
}
