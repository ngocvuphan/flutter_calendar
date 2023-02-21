import 'package:flutter/widgets.dart';

import 'rendering/calendar_month_cell.dart';

@immutable
class CalendarMonthCell extends MultiChildRenderObjectWidget {
  CalendarMonthCell({
    super.key,
    this.padding = EdgeInsets.zero,
    this.eventSpacing = 1.0,
    this.titleSpacing = 4.0,
    required Widget title,
    List<Widget>? events,
    required Widget overflow,
  }) : super(children: [
          title,
          if (events != null) ...events,
          overflow,
        ]);

  final EdgeInsets padding;
  final double eventSpacing;
  final double titleSpacing;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCalendarMonthCell(
      padding: padding,
      eventSpacing: eventSpacing,
      titleSpacing: titleSpacing,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    (renderObject as RenderCalendarMonthCell)
      ..padding = padding
      ..eventSpacing = eventSpacing
      ..titleSpacing = titleSpacing;
  }
}
