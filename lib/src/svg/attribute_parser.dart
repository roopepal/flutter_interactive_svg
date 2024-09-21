import 'dart:ui';

class AttributeParser {
  AttributeParser({
    required this.attributes,
  });

  final Map<String, String> attributes;

  double? get cX => double.tryParse(attributes['cx'] ?? '');

  double? get cY => double.tryParse(attributes['cy'] ?? '');

  Color? get fillColor {
    Color? color = _parseColor('fill', 'fill-opacity');
    // Transparent black is used for fill="none".
    return color?.value == 0 ? null : color ?? const Color(0xFF000000);
  }

  double? get height => double.tryParse(attributes['height'] ?? '');

  double? get r => double.tryParse(attributes['r'] ?? '');

  double? get rX => double.tryParse(attributes['rx'] ?? '');

  double? get rY => double.tryParse(attributes['ry'] ?? '');

  Color? get strokeColor => _parseColor('stroke', 'stroke-opacity');

  double? get strokeWidth => double.tryParse(attributes['stroke-width'] ?? '');

  double? get width => double.tryParse(attributes['width'] ?? '');

  double? get x => double.tryParse(attributes['x'] ?? '');

  double? get x1 => double.tryParse(attributes['x1'] ?? '');

  double? get x2 => double.tryParse(attributes['x2'] ?? '');

  double? get y => double.tryParse(attributes['y'] ?? '');

  double? get y1 => double.tryParse(attributes['y1'] ?? '');

  double? get y2 => double.tryParse(attributes['y2'] ?? '');
}

extension _ParseColor on AttributeParser {
  Color? _parseColor(
    String colorAttribute,
    String opacityAttribute,
  ) {
    final colorStr = attributes[colorAttribute];

    if (colorStr == null) return null;

    if (['none', ''].contains(colorStr)) return const Color(0x00000000);

    if (!colorStr.startsWith('#')) return null;

    var color = Color(int.parse(colorStr.replaceAll('#', '0xff')));

    final opacityStr = attributes[opacityAttribute];

    if (opacityStr != null) {
      color = color.withOpacity(double.parse(opacityStr));
    }

    return color;
  }
}
