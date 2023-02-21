import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vph_calendar/vph_calendar.dart';

@immutable
class EventData {
  const EventData({
    required this.title,
    required this.date,
    required this.color,
  });
  final String title;
  final String date;
  final String color;

  factory EventData.fromJson(dynamic json) {
    return EventData(
      title: json["title"] as String,
      date: json["date"] as String,
      color: json["color"] as String,
    );
  }
}

class DummyDataSource extends CalendarDataSource {
  final Map<DateTime, List<CalendarEvent>> _events = {};
  final List<EventData> _json = [];

  late DateTimeRange _dateTimeRange;

  @override
  bool get isLoading => _isLoading;
  bool _isLoading = false;

  @override
  Map<DateTime, List<CalendarEvent>>? get events => Map.unmodifiable(_events);

  @override
  Future<void> fetchEvents(DateTimeRange range) async {
    _dateTimeRange = range;
    _isLoading = true;
    _events.clear();
    notifyListeners();

    if (_json.isEmpty) {
      final String response = await rootBundle.loadString('MOCK_DATA.json');
      final json = jsonDecode(response) as List;
      for (final j in json) {
        _json.add(EventData.fromJson(j));
      }
    }

    json2Event();

    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> deleteEvent(CalendarEvent event) async {
    _isLoading = true;
    notifyListeners();

    _json.remove(event.data);
    json2Event();

    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> editEvent(
      {required CalendarEvent oldEvent,
      required CalendarEvent newEvent}) async {
    _isLoading = true;
    notifyListeners();

    final idx = _json.indexOf(oldEvent.data as EventData);
    if (idx != -1) {
      _json[idx] = newEvent.data as EventData;
      json2Event();
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> addEvent(CalendarEvent event) async {
    _isLoading = true;
    notifyListeners();

    final idx = _json.indexOf(event.data as EventData);
    if (idx == -1) {
      _json.add(event.data as EventData);
      json2Event();
    }

    _isLoading = false;
    notifyListeners();
  }

  void json2Event() {
    _events.clear();
    for (final item in _json) {
      final date = DateTime.parse(item.date);
      if (date.difference(_dateTimeRange.start).inDays >= 0 &&
          date.difference(_dateTimeRange.end).inDays <= 0) {
        final color =
            Color(int.parse((item.color).replaceFirst("#", "ff"), radix: 16));
        final event = CalendarEvent(
            date: date, title: item.title, color: color, data: item);
        if (_events.keys.contains(date)) {
          _events[date]!.add(event);
        } else {
          _events[date] = [event];
        }
      }
    }
  }
}
