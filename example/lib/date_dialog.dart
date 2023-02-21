import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vph_calendar/vph_calendar.dart';

import 'event_dialog.dart';

class DateDetailDialog extends StatefulWidget {
  const DateDetailDialog({
    super.key,
    required this.dataSource,
    required this.date,
  });

  final CalendarDataSource dataSource;
  final DateTime date;

  @override
  State<DateDetailDialog> createState() => _DateDetailDialogState();
}

class _DateDetailDialogState extends State<DateDetailDialog> {
  late List<CalendarEvent> _events;

  @override
  void initState() {
    super.initState();

    _events = widget.dataSource.events?[widget.date] ?? [];
    widget.dataSource.addListener(_handleDataSourceChanged);
  }

  @override
  void dispose() {
    widget.dataSource.removeListener(_handleDataSourceChanged);
    super.dispose();
  }

  void _handleDataSourceChanged() {
    final events = widget.dataSource.events?[widget.date] ?? [];
    if (!listEquals(events, _events)) {
      setState(() {
        _events = events;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall;
    return Card(
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(2.0),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                IconButton(
                  splashRadius: 20.0,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.black54),
                ),
              ],
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _events.map((e) {
                  final textColor = (e.color?.computeLuminance() ?? 1.0) > 0.5
                      ? Colors.black
                      : Colors.white;
                  final style = textStyle?.copyWith(color: textColor);
                  return Container(
                    margin: const EdgeInsets.only(top: 1.0),
                    child: Material(
                      color: e.color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.0)),
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0)),
                        onTap: () async {
                          await showPopupDialog(
                            context,
                            (context) => EventDialog(
                                dataSource: widget.dataSource,
                                date: widget.date,
                                event: e),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 4.0),
                          alignment: Alignment.centerLeft,
                          child: e.builder?.call(e) ??
                              Text(e.title!, style: style),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
