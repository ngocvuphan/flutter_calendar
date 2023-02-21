import 'package:example/dummy_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:vph_calendar/vph_calendar.dart';
import 'package:vph_web_date_picker/vph_web_date_picker.dart';

extension ColorExtension on Color {
  String toHexString() {
    return "#${red.toRadixString(16).padLeft(2, "0")}"
            "${green.toRadixString(16).padLeft(2, "0")}"
            "${blue.toRadixString(16).padLeft(2, "0")}"
        .toUpperCase();
  }
}

class EventDialog extends StatefulWidget {
  const EventDialog({
    super.key,
    required this.dataSource,
    required this.date,
    this.event,
    this.defaultColor = Colors.white,
  });

  final DateTime date;
  final CalendarEvent? event;
  final Color defaultColor;
  final CalendarDataSource dataSource;

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  late bool _editable;
  late TextEditingController _titleTextController;
  late TextEditingController _dateTextController;
  late TextEditingController _colorTextController;

  late DateTime _date;
  late Color _color;

  final _dateFormat = DateFormat.yMMMEd();

  @override
  void initState() {
    super.initState();
    _editable = widget.event == null;
    _color = widget.event?.color ?? widget.defaultColor;
    _date = widget.date;

    _titleTextController =
        TextEditingController(text: widget.event?.title ?? "");
    _dateTextController =
        TextEditingController(text: _dateFormat.format(_date));
    _colorTextController = TextEditingController(text: _color.toHexString());
  }

  @override
  void dispose() {
    _titleTextController.dispose();
    _dateTextController.dispose();
    _colorTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateKey = GlobalKey();
    final colorKey = GlobalKey();
    return Card(
      child: Container(
        width: 360.0,
        padding: const EdgeInsets.only(left: 2, top: 2, right: 2, bottom: 18.0),
        child: Table(
          columnWidths: const {0: FixedColumnWidth(56.0), 1: FlexColumnWidth()},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            /// Title bar
            TableRow(
              children: [
                TableCell(child: Container()),
                TableCell(
                  child: Row(
                    children: [
                      const Spacer(),
                      if (widget.event != null) ...[
                        IconButton(
                          splashRadius: 20.0,
                          onPressed: () => setState(() {
                            _editable = !_editable;
                          }),
                          icon: Icon(_editable ? Icons.edit_off : Icons.edit,
                              color: Colors.black54),
                        ),
                        IconButton(
                          splashRadius: 20.0,
                          onPressed: widget.event == null
                              ? null
                              : () {
                                  widget.dataSource.deleteEvent(widget.event!);
                                  Navigator.of(context).pop();
                                },
                          icon: const Icon(Icons.delete, color: Colors.black54),
                        ),
                      ],
                      IconButton(
                        splashRadius: 20.0,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// Title textfield
            TableRow(
              children: [
                TableCell(child: Container()),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: TextField(
                      controller: _titleTextController,
                      readOnly: !_editable,
                      decoration: InputDecoration(
                        hintText: "Title",
                        border: _editable
                            ? const UnderlineInputBorder()
                            : InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            /// Date textfield
            TableRow(
              children: [
                TableCell(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16.0),
                    child: const Icon(Icons.schedule, color: Colors.black54),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: TextField(
                      key: dateKey,
                      controller: _dateTextController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "Date",
                        border: _editable
                            ? const UnderlineInputBorder()
                            : InputBorder.none,
                      ),
                      onTap: _editable
                          ? () async {
                              final pickedDate = await showWebDatePicker(
                                context: dateKey.currentContext!,
                                initialDate: _date,
                              );
                              if (pickedDate != null) {
                                _date = pickedDate;
                                _dateTextController.text =
                                    _dateFormat.format(pickedDate);
                              }
                            }
                          : null,
                    ),
                  ),
                ),
              ],
            ),

            /// Color textfield
            TableRow(
              children: [
                TableCell(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Container(
                      width: 20.0,
                      height: 20.0,
                      margin: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        color: _color,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: TextField(
                      key: colorKey,
                      controller: _colorTextController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "Color",
                        border: _editable
                            ? const UnderlineInputBorder()
                            : InputBorder.none,
                      ),
                      onTap: _editable
                          ? () async {
                              final pickedColor = await showPopupDialog<Color?>(
                                colorKey.currentContext!,
                                (context) {
                                  final theme = Theme.of(context);
                                  Color color = _color;
                                  return Card(
                                    margin: const EdgeInsets.only(
                                        top: 4.0,
                                        bottom: 2.0,
                                        left: 1.0,
                                        right: 1.0),
                                    child: Column(
                                      children: [
                                        HueRingPicker(
                                          pickerColor: color,
                                          onColorChanged: (value) =>
                                              color = value,
                                          portraitOnly: true,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: theme
                                                      .colorScheme.secondary),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text("CANCEL",
                                                  style: TextStyle(
                                                      color: theme.colorScheme
                                                          .onSecondary)),
                                            ),
                                            const SizedBox(width: 8.0),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(color),
                                              child: const Text("OK"),
                                            ),
                                            const SizedBox(width: 8.0),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                      ],
                                    ),
                                  );
                                },
                                asDropDown: true,
                                useTargetWidth: true,
                              );
                              if (pickedColor != null) {
                                _colorTextController.text =
                                    pickedColor.toHexString();
                                setState(() => _color = pickedColor);
                              }
                            }
                          : null,
                    ),
                  ),
                ),
              ],
            ),

            /// Action buttons
            if (_editable)
              TableRow(
                children: [
                  TableCell(child: Container()),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, right: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              final newEvent = CalendarEvent(
                                date: _date,
                                title: _titleTextController.text,
                                color: _color,
                                data: EventData(
                                  date: _date.toIso8601String(),
                                  title: _titleTextController.text,
                                  color: _colorTextController.text,
                                ),
                              );
                              if (widget.event == null) {
                                widget.dataSource.addEvent(newEvent);
                              } else {
                                widget.dataSource.editEvent(
                                    oldEvent: widget.event!,
                                    newEvent: newEvent);
                              }
                              Navigator.of(context).pop();
                            },
                            child: const Text("SAVE"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
