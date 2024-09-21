import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart';

import 'annotation.dart';
import 'svg/elements/svg_element.dart';
import 'svg/svg_painter.dart';
import 'svg/svg_parsing.dart';

class InteractiveSvg extends StatefulWidget {
  InteractiveSvg({
    super.key,
    this.onElementSelected,
    this.padding = 20.0,
    this.selectableElementIdPatterns,
    this.selectedElementFillColor,
    this.selectedElementStrokeColor,
    this.annotations,
    required this.svg,
  }) {
    final XmlDocument xml = XmlDocument.parse(svg);
    _svgSize = xml.parseSvgSize();
    _svgElements = xml.parseSvgElements().flattened;
    _hitTestElements = _svgElements.toList().reversed;
  }

  /// Called with null when the selection changes to nothing.
  final void Function(SvgElement?)? onElementSelected;

  final double padding;

  /// Elements whose id attribute value matches at least one of these patterns
  /// are be selectable.
  final Iterable<Pattern>? selectableElementIdPatterns;

  final Color? selectedElementFillColor;

  final Color? selectedElementStrokeColor;

  final List<Annotation>? annotations;

  late final Size _svgSize;

  final String svg;

  late final Iterable<SvgElement> _svgElements;

  /// Elements to be hit tested when detecting taps.
  late final Iterable<SvgElement> _hitTestElements;

  @override
  State<InteractiveSvg> createState() => _InteractiveSvgState();
}

class _InteractiveSvgState extends State<InteractiveSvg> {
  final _selectedElementNotifier = ValueNotifier<SvgElement?>(null);

  final _transformationController = TransformationController();

  final _interactiveViewerFlowDelegate = _InteractiveViewerFlowDelegate();

  final _annotationsFlowDelegate = _AnnotationsFlowDelegate();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final svgMaxWidth = constraints.maxWidth - 2 * widget.padding;
        final svgMaxHeight = constraints.maxHeight - 2 * widget.padding;
        final paintedSize =
            _paintedSize(svgMaxWidth, svgMaxHeight, constraints);
        final paintedOrigin = Offset(
          0.5 * (constraints.maxWidth - paintedSize.width),
          0.5 * (constraints.maxHeight - paintedSize.height),
        );
        final paintedScale = Offset(
          paintedSize.width / widget._svgSize.width,
          paintedSize.height / widget._svgSize.height,
        );

        _interactiveViewerFlowDelegate.paintedOrigin = paintedOrigin;
        _interactiveViewerFlowDelegate.paintedScale = paintedScale;
        _annotationsFlowDelegate.paintedOrigin = paintedOrigin;
        _annotationsFlowDelegate.paintedScale = paintedScale;

        return GestureDetector(
          onTapUp: (details) => _onTapUp(details, paintedOrigin, paintedSize),
          child: InteractiveViewer(
            transformationController: _transformationController,
            child: Flow.unwrapped(
              clipBehavior: Clip.none,
              delegate: _interactiveViewerFlowDelegate,
              children: [
                SizedBox(
                  width: paintedSize.width,
                  height: paintedSize.height,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: CustomPaint(
                      size: widget._svgSize,
                      painter: SvgPainter(
                        selectedElementFillColor:
                            widget.selectedElementFillColor,
                        selectedElementStrokeColor:
                            widget.selectedElementStrokeColor,
                        selectedElementNotifier: _selectedElementNotifier,
                        svgElements: widget._svgElements,
                      ),
                    ),
                  ),
                ),
                if (widget.annotations != null)
                  _Annotations(
                    annotations: widget.annotations!,
                    delegate: _annotationsFlowDelegate,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onTapUp(
    TapUpDetails details,
    Offset paintedOrigin,
    Size paintedSize,
  ) {
    final element = _elementContainingTap(
      details: details,
      paintedOrigin: paintedOrigin,
      paintedSize: paintedSize,
    );
    final selectedElement =
        element != null && _isElementSelectable(element) ? element : null;

    if (_selectedElementNotifier.value != selectedElement) {
      _selectedElementNotifier.value = selectedElement;
      widget.onElementSelected?.call(selectedElement);
    }
  }

  SvgElement? _elementContainingTap({
    required TapUpDetails details,
    required Offset paintedOrigin,
    required Size paintedSize,
  }) {
    final tapInScene = _transformationController.toScene(details.localPosition);

    final tapInPainted = tapInScene - paintedOrigin;

    final tapInSvg = Offset(
      tapInPainted.dx / (paintedSize.width / widget._svgSize.width),
      tapInPainted.dy / (paintedSize.width / widget._svgSize.width),
    );

    for (final element in widget._hitTestElements) {
      if (element.path?.contains(tapInSvg) == true) {
        return element;
      }
    }

    return null;
  }

  bool _isElementSelectable(SvgElement path) {
    final patterns = widget.selectableElementIdPatterns;
    if (patterns == null) return true;

    if (patterns.isEmpty) return false;

    final id = path.attributes['id'];
    if (id == null) return false;

    return patterns.any((pattern) => pattern.allMatches(id).isNotEmpty);
  }

  Size _paintedSize(
    double maxWidth,
    double maxHeight,
    BoxConstraints constraints,
  ) {
    if (constraints.isSatisfiedBy(widget._svgSize)) {
      // fits in constraints
      return widget._svgSize;
    } else {
      // scaled to fit constraints
      final maxAspectRatio = maxWidth / maxHeight;
      final svgAspectRatio = widget._svgSize.aspectRatio;

      return Size(
        svgAspectRatio > maxAspectRatio ? maxWidth : maxHeight * svgAspectRatio,
        svgAspectRatio > maxAspectRatio ? maxWidth / svgAspectRatio : maxHeight,
      );
    }
  }
}

class _InteractiveViewerFlowDelegate extends FlowDelegate {
  Offset paintedOrigin = Offset.zero;
  Offset paintedScale = Offset.zero;

  @override
  void paintChildren(FlowPaintingContext context) {
    // SVG painter
    context.paintChild(
      0,
      transform: Matrix4.translationValues(
        paintedOrigin.dx,
        paintedOrigin.dy,
        0,
      ),
    );
    // annotations
    context.paintChild(1);
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) {
    return false;
  }
}

class _Annotations extends StatelessWidget {
  const _Annotations({
    required this.annotations,
    required this.delegate,
  });

  final List<Annotation> annotations;
  final _AnnotationsFlowDelegate delegate;

  @override
  Widget build(BuildContext context) {
    delegate.annotations = annotations;

    return Flow.unwrapped(
      clipBehavior: Clip.none,
      delegate: delegate,
      children: annotations.map((a) => a.child).toList(),
    );
  }
}

class _AnnotationsFlowDelegate extends FlowDelegate {
  _AnnotationsFlowDelegate();

  List<Annotation> annotations = [];
  Offset paintedOrigin = Offset.zero;
  Offset paintedScale = Offset.zero;

  @override
  void paintChildren(FlowPaintingContext context) {
    for (int i = 0; i < context.childCount; ++i) {
      final annotation = annotations[i];

      final dx = paintedOrigin.dx +
          annotation.x * paintedScale.dx +
          annotation.offset.dx;
      final dy = paintedOrigin.dy +
          annotation.y * paintedScale.dy +
          annotation.offset.dy;

      context.paintChild(i, transform: Matrix4.translationValues(dx, dy, 0));
    }
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) {
    return false;
  }
}
