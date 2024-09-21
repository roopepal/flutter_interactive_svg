import 'dart:ui';

import 'svg_element.dart';

class SvgLine extends SvgElement {
  SvgLine({required super.attributes}) {
    final double x1 = attributeParser.x1 ?? 0;
    final double y1 = attributeParser.y1 ?? 0;
    final double x2 = attributeParser.x2 ?? 0;
    final double y2 = attributeParser.y2 ?? 0;
    final Color? strokeColor = attributeParser.strokeColor;
    final double strokeWidth = attributeParser.strokeWidth ?? 0.0;

    if (strokeColor != null) {
      strokePaint = Paint()
        ..color = strokeColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;
    }

    if (x1 != x2 || y1 != y2) {
      path = Path()
        ..moveTo(x1, y1)
        ..lineTo(x2, y2);
    }
  }
}
