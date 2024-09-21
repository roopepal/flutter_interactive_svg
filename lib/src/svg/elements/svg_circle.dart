import 'dart:ui';

import 'svg_element.dart';

class SvgCircle extends SvgElement {
  SvgCircle({required super.attributes}) {
    final double cX = attributeParser.cX ?? 0;
    final double cY = attributeParser.cY ?? 0;
    final double r = attributeParser.r ?? 0;
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

    if (r > 0) {
      path = Path()
        ..addOval(Rect.fromCenter(
          center: Offset(cX, cY),
          width: 2 * r,
          height: 2 * r,
        ));
    }
  }
}
