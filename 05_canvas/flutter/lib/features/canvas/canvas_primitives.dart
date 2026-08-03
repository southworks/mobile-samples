import 'package:flutter/material.dart';

enum DrawingTool {
  move,
  pencil,
  marker,
  highlighter,
  eraser,
  rectangle,
  oval,
  diamond,
  arrow,
  text,
}

enum CanvasShapeType { rectangle, oval, diamond, arrow }

@immutable
class StrokeStyle {
  const StrokeStyle({
    required this.color,
    required this.width,
    required this.opacity,
    this.isEraser = false,
  });

  final Color color;
  final double width;
  final double opacity;
  final bool isEraser;

  Color resolveColor(Color backgroundColor) {
    if (isEraser) {
      return backgroundColor;
    }
    return color.withValues(alpha: opacity);
  }
}

@immutable
class Stroke {
  const Stroke({required this.points, required this.style});

  final List<Offset> points;
  final StrokeStyle style;

  Stroke copyWith({List<Offset>? points, StrokeStyle? style}) {
    return Stroke(points: points ?? this.points, style: style ?? this.style);
  }
}

@immutable
class CanvasShape {
  const CanvasShape({
    required this.type,
    required this.center,
    required this.size,
    required this.color,
    this.strokeWidth = 3,
  });

  final CanvasShapeType type;
  final Offset center;
  final Size size;
  final Color color;
  final double strokeWidth;
}

@immutable
class CanvasTextItem {
  const CanvasTextItem({
    required this.text,
    required this.position,
    required this.color,
    this.fontSize = 20,
  });

  final String text;
  final Offset position;
  final Color color;
  final double fontSize;
}
