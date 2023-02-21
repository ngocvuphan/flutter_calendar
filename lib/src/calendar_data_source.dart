import 'package:flutter/material.dart';

@immutable
class CalendarEvent {
  /// Calendar event definition
  const CalendarEvent({
    required this.date,
    this.title,
    this.color,
    this.data,
    this.builder,
  }) : assert(title != null || builder != null);

  /// The date of event
  final DateTime date;

  /// The title of event
  final String? title;

  /// The color of event
  final Color? color;

  /// The raw data of event
  final Object? data;

  /// The widget builder which will be invoked to generate the event title widget
  final Widget Function(CalendarEvent? event)? builder;
}

abstract class CalendarDataSource extends ChangeNotifier {
  bool get isLoading;
  Map<DateTime, List<CalendarEvent>>? get events;
  Future<void> fetchEvents(DateTimeRange range);
  Future<void> deleteEvent(CalendarEvent event);
  Future<void> editEvent(
      {required CalendarEvent oldEvent, required CalendarEvent newEvent});
  Future<void> addEvent(CalendarEvent event);
}
