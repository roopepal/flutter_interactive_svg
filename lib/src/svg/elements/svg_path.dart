import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';

import 'svg_element.dart';

class SvgPath extends SvgElement {
  SvgPath({required super.attributes}) {
    final String? d = attributes['d'];
    final Color? fillColor = attributeParser.fillColor;
    final Color? strokeColor = attributeParser.strokeColor;
    final double strokeWidth = attributeParser.strokeWidth ?? 0.0;

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

    if (d != null) {
      path = parseSvgPathData(d);
    }
  }
}
