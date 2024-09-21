import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:xml/xml.dart';

import 'elements/svg_circle.dart';
import 'elements/svg_element.dart';
import 'elements/svg_ellipse.dart';
import 'elements/svg_g.dart';
import 'elements/svg_line.dart';
import 'elements/svg_path.dart';
import 'elements/svg_polygon.dart';
import 'elements/svg_polyline.dart';
import 'elements/svg_rect.dart';

extension SvgParsingXmlNode on XmlNode {
  XmlAttribute? firstAttributeNamed(String name) {
    return attributes.firstWhereOrNull(
      (attr) => attr.name.local == name,
    );
  }
}

extension SvgParsing on XmlDocument {
  Size parseSvgSize() {
    final svg = findElements('svg').first;

    final width = svg.firstAttributeNamed('width');
    final height = svg.firstAttributeNamed('height');

    if (width != null && height != null) {
      final widthDouble = double.parse(width.value);
      final heightDouble = double.parse(height.value);

      return Size(widthDouble, heightDouble);
    }

    throw 'Could not parse <svg> size';
  }

  List<SvgElement> parseSvgElements() {
    final svg = findElements('svg').first;

    return svg.childElements
        .map((e) => _parseElement(e))
        .whereType<SvgElement>()
        .toList();
  }

  SvgElement? _parseElement(
    XmlElement element, {
    Map<String, String> parentAttributes = const {},
  }) {
    final elementAttributes = Map.fromEntries(element.attributes.map(
      (attr) => MapEntry(attr.name.local, attr.value),
    ));

    final attributes = {...parentAttributes, ...elementAttributes};

    return switch (element.name.local) {
      'circle' => SvgCircle(attributes: attributes),
      'ellipse' => SvgEllipse(attributes: attributes),
      'g' => SvgG(
          attributes: attributes,
          children: element.childElements
              .map((e) => _parseElement(e, parentAttributes: attributes))
              .whereType<SvgElement>()
              .toList(),
        ),
      'line' => SvgLine(attributes: attributes),
      'path' => SvgPath(attributes: attributes),
      'polygon' => SvgPolygon(attributes: attributes),
      'polyline' => SvgPolyline(attributes: attributes),
      'rect' => SvgRect(attributes: attributes),
      _ => null
    };
  }
}
