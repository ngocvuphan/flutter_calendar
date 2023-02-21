import 'package:example/date_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:vph_calendar/vph_calendar.dart';

import 'dummy_data_source.dart';
import 'event_dialog.dart';
import 'material_theme/color_schemes.g.dart';

const kWeekdayNames = <String>[
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday"
];
const kMonthNames = <String>[
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CalendarController _controller;
  late CalendarDataSource _dataSource;
  late DateTime? _selectedDate;

  final _dateFormat = DateFormat.yMMMMEEEEd();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(2023, 2, 9);
    _controller = CalendarController(initialDate: _selectedDate);
    _controller.addListener(
        () => setState(() => _selectedDate = _controller.selectedDate));
    _dataSource = DummyDataSource();
  }

  @override
  void dispose() {
    _controller.dispose();
    _dataSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(/* useMaterial3: true, */ colorScheme: lightColorScheme),
      darkTheme:
          ThemeData(/* useMaterial3: true, */ colorScheme: darkColorScheme),
      home: Scaffold(
        appBar: AppBar(
          title: Text(_dateFormat.format(_selectedDate!)),
          actions: [
            IconButton(
                onPressed: _controller.previousMonth,
                icon: const Icon(Icons.keyboard_arrow_left)),
            IconButton(
                onPressed: _controller.today, icon: const Icon(Icons.today)),
            IconButton(
                onPressed: _controller.nextMonth,
                icon: const Icon(Icons.keyboard_arrow_right)),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Calendar(
            controller: _controller,
            dataSource: _dataSource,
            newEventDialogBuilder: (context, date) => EventDialog(
              dataSource: _dataSource,
              date: date,
              defaultColor: Theme.of(context).colorScheme.primary,
            ),
            eventDetailDialogBuilder: (context, date, event) => EventDialog(
              dataSource: _dataSource,
              date: date,
              event: event,
              defaultColor: Theme.of(context).colorScheme.primary,
            ),
            dateDetailDialogBuilder: (context, date, events) =>
                DateDetailDialog(
              dataSource: _dataSource,
              date: date,
            ),
          ),
        ),
      ),
    );
  }
}
