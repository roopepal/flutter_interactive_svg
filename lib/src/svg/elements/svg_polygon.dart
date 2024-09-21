import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';

import 'svg_element.dart';

class SvgPolygon extends SvgElement {
  SvgPolygon({required super.attributes}) {
    final String? points = attributes['points'];
    final Color? fillColor = attributeParser.fillColor;
    final Color? strokeColor = attributeParser.strokeColor;
    final double strokeWidth = attributeParser.strokeWidth ?? 0;

    if (fillColor != null) {
      fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
    }

    if (strokeColor != null) {
      strokePaint = Paint()
        ..color = strokeColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;
    }

    if (points != null) {
      path = parseSvgPathData('M $points z');
    }
  }
}
