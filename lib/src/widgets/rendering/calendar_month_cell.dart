import 'dart:math' as math;
import 'package:flutter/rendering.dart';

class _ParentData extends ContainerBoxParentData<RenderBox> {
  bool needsPaint = false;
}

class RenderCalendarMonthCell extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _ParentData> {
  RenderCalendarMonthCell({
    required EdgeInsets padding,
    required double eventSpacing,
    required double titleSpacing,
  })  : _padding = padding,
        _eventSpacing = eventSpacing,
        _titleSpacing = titleSpacing;

  EdgeInsets get padding => _padding;
  EdgeInsets _padding;
  set padding(EdgeInsets value) {
    if (_padding == value) {
      return;
    }
    _padding = value;
    markNeedsLayout();
  }

  double get eventSpacing => _eventSpacing;
  double _eventSpacing;
  set eventSpacing(double value) {
    if (_eventSpacing == value) {
      return;
    }
    _eventSpacing = value;
    markNeedsLayout();
  }

  double get titleSpacing => _titleSpacing;
  double _titleSpacing;
  set titleSpacing(double value) {
    if (_titleSpacing == value) {
      return;
    }
    _titleSpacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _ParentData) {
      child.parentData = _ParentData();
    }
  }

  @override
  void performLayout() {
    final deflatedConstraints =
        BoxConstraints(maxWidth: constraints.maxWidth - _padding.horizontal);
    double height = _padding.top;
    double width = 0;
    Offset lastOffset = Offset.zero;
    bool overflowed = false;

    /// Layout title
    RenderBox? child = firstChild;
    if (child != null) {
      final childParentData = child.parentData as _ParentData;
      child.layout(deflatedConstraints, parentUsesSize: true);
      childParentData.offset = Offset(_padding.left, height);
      childParentData.needsPaint = true;
      height += child.size.height;
      width = child.size.width;
      child = childParentData.nextSibling;
      overflowed = height + _padding.bottom > constraints.maxHeight;
      if (!overflowed) {
        height += titleSpacing;
      }
    }

    /// Layout events
    while (child != null && child != lastChild) {
      final childParentData = child.parentData as _ParentData;
      if (overflowed) {
        childParentData.needsPaint = false;
      } else {
        child.layout(deflatedConstraints, parentUsesSize: true);

        if (height + child.size.height + _eventSpacing + _padding.bottom <
            constraints.maxHeight) {
          childParentData.needsPaint = true;
          childParentData.offset = Offset(_padding.left, height);
          height += child.size.height + _eventSpacing;
          width = math.max(width, child.size.width);
        } else {
          childParentData.needsPaint = false;
          overflowed = true;
          if (childParentData.previousSibling != firstChild) {
            final prevChildParentData =
                childParentData.previousSibling!.parentData as _ParentData;
            lastOffset = prevChildParentData.offset;
            prevChildParentData.needsPaint = false;
          }
        }
      }
      child = childParentData.nextSibling;
    }

    /// Layout overflow
    if (child != null) {
      final childParentData = child.parentData as _ParentData;
      if (lastOffset != Offset.zero) {
        child.layout(deflatedConstraints, parentUsesSize: true);
        childParentData.needsPaint = true;
        childParentData.offset = lastOffset;
        height = lastOffset.dy + child.size.height;
        width = math.max(width, child.size.width);
      } else {
        childParentData.needsPaint = false;
      }
    }

    size = constraints
        .constrain(Size(width + _padding.horizontal, height + _padding.bottom));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as _ParentData;
      if (childParentData.needsPaint) {
        context.paintChild(child, childParentData.offset + offset);
      }
      child = childParentData.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = lastChild;
    while (child != null) {
      final childParentData = child.parentData as _ParentData;
      if (childParentData.needsPaint) {
        final bool isHit = result.addWithPaintOffset(
          offset: childParentData.offset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            assert(transformed == position - childParentData.offset);
            return child!.hitTest(result, position: transformed);
          },
        );
        if (isHit) {
          return true;
        }
      }
      child = childParentData.previousSibling;
    }
    return false;
  }
}
