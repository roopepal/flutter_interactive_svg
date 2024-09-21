import 'dart:ui';

import 'package:collection/collection.dart';

import '../attribute_parser.dart';

abstract class SvgElement {
  SvgElement({
    required this.attributes,
    this.children,
  }) : attributeParser = AttributeParser(attributes: attributes);

  final Map<String, String> attributes;

  final AttributeParser attributeParser;

  final Iterable<SvgElement>? children;

  Path? path;

  Paint? fillPaint;

  Paint? strokePaint;

  void paint(
    Canvas canvas,
    Color? overrideFillColor,
    Color? overrideStrokeColor,
  ) {
    final path_ = path;
    if (path_ == null) return;

    final fillPaint_ = overrideFillColor != null
        ? (fillPaint?.copy?..color = overrideFillColor)
        : fillPaint;

    if (fillPaint_ != null) {
      canvas.drawPath(path_, fillPaint_);
    }

    final strokePaint_ = overrideStrokeColor != null
        ? (strokePaint?.copy?..color = overrideStrokeColor)
        : strokePaint;

    if (strokePaint_ != null) {
      canvas.drawPath(path_, strokePaint_);
    }
  }
}

extension SvgElementFlattened on SvgElement {
  Iterable<SvgElement> get flattened {
    return [this, ...?children?.map((e) => e.flattened).flattened];
  }
}

extension IterableSvgElementFlattened on Iterable<SvgElement> {
  Iterable<SvgElement> get flattened {
    return map((e) => e.flattened).flattened;
  }
}

extension _Copy on Paint {
  Paint get copy => Paint.from(this);
}
