import 'package:flutter/widgets.dart';

class Annotation {
  const Annotation({
    this.offset = Offset.zero,
    required this.x,
    required this.y,
    required this.child,
  });

  final Offset offset;
  final double x;
  final double y;
  final Widget child;
}
