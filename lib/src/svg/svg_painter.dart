import 'package:flutter/widgets.dart';

import 'elements/svg_element.dart';

class SvgPainter extends CustomPainter {
  const SvgPainter({
    this.selectedElementFillColor,
    this.selectedElementStrokeColor,
    required this.selectedElementNotifier,
    required this.svgElements,
  }) : super(repaint: selectedElementNotifier);

  final Color? selectedElementFillColor;

  final Color? selectedElementStrokeColor;

  final ValueNotifier<SvgElement?> selectedElementNotifier;

  final Iterable<SvgElement> svgElements;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final element in svgElements) {
      final isSelected = selectedElementNotifier.value == element;
      final overrideFillColor = isSelected ? selectedElementFillColor : null;
      final overrideStrokeColor =
          isSelected ? selectedElementStrokeColor : null;

      element.paint(canvas, overrideFillColor, overrideStrokeColor);
    }
  }
}
