import 'package:flutter/material.dart';

import 'calendar_controller.dart';
import 'calendar_data_source.dart';
import 'widgets/calendar_month_view.dart';

typedef EventDetailDialogBuilder = Widget Function(
    BuildContext context, DateTime date, CalendarEvent event);
typedef DateDetailDialogBuilder = Widget Function(
    BuildContext context, DateTime date, List<CalendarEvent>? events);
typedef NewEventDialogBuilder = Widget Function(
    BuildContext context, DateTime date);

class Calendar extends StatelessWidget {
  /// Calendar month view
  const Calendar({
    super.key,
    this.controller,
    this.dataSource,
    this.initialDate,
    this.textStyle,
    this.eventTextStyle,
    this.eventPadding,
    this.includeTrailingAndLeadingDates = false,
    this.eventDetailDialogBuilder,
    this.dateDetailDialogBuilder,
    this.newEventDialogBuilder,
  });

  /// Control the calendar
  final CalendarController? controller;

  /// Events source
  final CalendarDataSource? dataSource;

  /// Initial date
  final DateTime? initialDate;

  /// Style of date cell title. Default is textTheme.bodyMedium
  final TextStyle? textStyle;

  /// Style of date cell event. Default is textTheme.bodySmall
  final TextStyle? eventTextStyle;

  /// Event padding. Default is EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0)
  final EdgeInsets? eventPadding;

  /// Include the trailing and leading dates in the month view. Default is false
  final bool includeTrailingAndLeadingDates;

  /// Event detail dialog builder. Be invoked when click on the event widget
  final EventDetailDialogBuilder? eventDetailDialogBuilder;

  /// Events of date detail dialog builder. Be invoked when click on the 'more' widget
  final DateDetailDialogBuilder? dateDetailDialogBuilder;

  /// New event dialog builder. Be invoked when click on the blank space of month cell
  final NewEventDialogBuilder? newEventDialogBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CalendarMonthView(
      controller: controller,
      dataSource: dataSource,
      initialDate: initialDate,
      textStyle: textStyle ?? theme.textTheme.bodyMedium,
      eventTextStyle: eventTextStyle ?? theme.textTheme.bodySmall,
      eventPadding: eventPadding ??
          const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      includeTrailingAndLeadingDates: includeTrailingAndLeadingDates,
      eventDetailDialogBuilder: eventDetailDialogBuilder,
      dateDetailDialogBuilder: dateDetailDialogBuilder,
      newEventDialogBuilder: newEventDialogBuilder,
    );
  }
}
