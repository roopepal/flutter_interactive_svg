import 'dart:ui';

import 'svg_element.dart';

class SvgRect extends SvgElement {
  SvgRect({required super.attributes}) {
    final double x = attributeParser.x ?? 0;
    final double y = attributeParser.y ?? 0;
    final double? width = attributeParser.width;
    final double? height = attributeParser.height;
    final double? rX = attributeParser.rX;
    final double? rY = attributeParser.rY;
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

    if (width != null && height != null) {
      final Rect rect = Rect.fromLTWH(x, y, width, height);

      Radius? radius;
      if (rX != null || rY != null) {
        radius = Radius.elliptical(rX ?? rY ?? 0, rY ?? rX ?? 0);
      }

      if (radius != null) {
        path = Path()..addRRect(RRect.fromRectAndRadius(rect, radius));
      } else {
        path = Path()..addRect(rect);
      }
    }
  }
}
