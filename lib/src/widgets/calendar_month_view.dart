import 'package:flutter/material.dart';
import 'package:vph_common_widgets/vph_common_widgets.dart';

import '../calendar.dart'
    show
        EventDetailDialogBuilder,
        DateDetailDialogBuilder,
        NewEventDialogBuilder;
import '../calendar_controller.dart';
import '../calendar_data_source.dart';
import '../helpers/datetime_extension.dart';
import 'calendar_month_cell.dart';

const _kSlideTransitionDuration = Duration(milliseconds: 300);
const _kFadeTransitionDuration = Duration(milliseconds: 200);

class CalendarMonthView extends StatefulWidget {
  const CalendarMonthView({
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

  final CalendarController? controller;
  final CalendarDataSource? dataSource;
  final DateTime? initialDate;
  final TextStyle? textStyle;
  final TextStyle? eventTextStyle;
  final EdgeInsets? eventPadding;
  final bool includeTrailingAndLeadingDates;

  final EventDetailDialogBuilder? eventDetailDialogBuilder;
  final DateDetailDialogBuilder? dateDetailDialogBuilder;
  final NewEventDialogBuilder? newEventDialogBuilder;

  @override
  State<CalendarMonthView> createState() => _CalendarMonthViewState();
}

class _CalendarMonthViewState extends State<CalendarMonthView>
    with SingleTickerProviderStateMixin {
  late AnimationController _eventAnimationController;

  late DateTime _selectedDate;
  late Map<DateTime, List<CalendarEvent>>? _events;

  double _slideDirection = 1.0;

  @override
  void initState() {
    super.initState();
    _eventAnimationController =
        AnimationController(duration: _kFadeTransitionDuration, vsync: this);
    _selectedDate = widget.controller?.selectedDate ?? DateTime.now();
    widget.controller
      ?..selectedDate = _selectedDate
      ..addListener(_handleControlEvent);
    widget.dataSource
      ?..fetchEvents(_selectedDate.monthDateTimeRange(
          includeTrailingAndLeadingDates:
              widget.includeTrailingAndLeadingDates))
      ..addListener(_handleDataSource);
    _events = widget.dataSource?.events;
  }

  @override
  void dispose() {
    _eventAnimationController.dispose();
    super.dispose();
  }

  List<Widget> _buildMonthCells(ThemeData theme) {
    final now = DateTime.now();
    final monthDateRange =
        _selectedDate.monthDateTimeRange(includeTrailingAndLeadingDates: true);

    Widget buidEvent(
        {required CalendarEvent event,
        GestureTapCallback? onTap,
        required Animation<double> animation}) {
      final textColor = (event.color?.computeLuminance() ?? 1.0) > 0.5
          ? Colors.black
          : Colors.white;
      return FadeTransition(
        opacity: animation,
        child: Material(
          color: event.color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
          child: InkWell(
            onTap: onTap,
            customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0)),
            child: Container(
              padding: widget.eventPadding,
              alignment: Alignment.centerLeft,
              child: event.builder?.call(event) ??
                  Text(event.title!,
                      style: widget.eventTextStyle?.copyWith(color: textColor)),
            ),
          ),
        ),
      );
    }

    /// Header
    final children = kWeekdayShortNames
        .map<Widget>(
          (x) => Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(x, style: widget.textStyle),
          ),
        )
        .toList();

    /// Days
    const kCellTitleHeight = 26.0;
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(kCellTitleHeight),
      color: theme.colorScheme.primary,
    );
    final animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _eventAnimationController,
      curve: Curves.easeInOut,
    ));
    for (int i = 0; i < kNumberCellsOfMonth; i++) {
      final date = monthDateRange.start.add(Duration(days: i));
      final isToday = date.dateCompareTo(now) == 0;
      final isFirst = date.day == 1;

      if (widget.includeTrailingAndLeadingDates ||
          date.month == _selectedDate.month) {
        final key = GlobalKey();
        Widget child = CalendarMonthCell(
          key: key,
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 1.0),
          title: Container(
            height: kCellTitleHeight,
            width: isFirst ? 2 * kCellTitleHeight : kCellTitleHeight,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            alignment: Alignment.center,
            decoration: isToday ? decoration : null,
            child: Text(
              isFirst
                  ? "${kMonthShortNames[date.month - 1]} ${date.day}"
                  : date.day.toString(),
              style: isToday
                  ? widget.textStyle
                      ?.copyWith(color: theme.colorScheme.onPrimary)
                  : widget.textStyle,
            ),
          ),
          events: _events?[date]
              ?.map<Widget>(
                (e) => buidEvent(
                  event: e,
                  onTap: widget.eventDetailDialogBuilder != null
                      ? () => showPopupDialog(
                            key.currentContext!,
                            (context) => widget.eventDetailDialogBuilder!(
                                context, date, e),
                          )
                      : null,
                  animation: animation,
                ),
              )
              .toList(),
          overflow: buidEvent(
            event: CalendarEvent(date: date, title: "more..."),
            onTap: widget.dateDetailDialogBuilder != null
                ? () => showPopupDialog(
                      key.currentContext!,
                      (context) => widget.dateDetailDialogBuilder!(
                          context, date, _events?[date]),
                    )
                : null,
            animation: animation,
          ),
        );

        child = GestureDetector(
          onTap: widget.newEventDialogBuilder != null
              ? () => showPopupDialog(
                    key.currentContext!,
                    (context) => widget.newEventDialogBuilder!(context, date),
                  )
              : null,
          child: Container(color: Colors.transparent, child: child),
        );
        children.add(child);
      } else {
        children.add(Container());
      }
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderSide = BorderSide(color: theme.dividerColor, width: 1.0);

    return ClipRRect(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedSwitcher(
            duration: _kSlideTransitionDuration,
            transitionBuilder: (child, animation) {
              double dx = ((child.key as ValueKey).value as DateTime)
                          .dateCompareTo(_selectedDate) ==
                      0
                  ? 1.0
                  : -1.0;
              animation.addStatusListener((status) {
                if (status == AnimationStatus.completed) {
                  _eventAnimationController.forward();
                } else {
                  _eventAnimationController.reset();
                }
              });
              return SlideTransition(
                position: Tween<Offset>(
                        begin: Offset(dx * _slideDirection, 0.0),
                        end: const Offset(0.0, 0.0))
                    .animate(animation),
                child: child,
              );
            },
            child: UniformGrid(
              key: ValueKey(_selectedDate),
              columnCount: kNumberOfWeekday,
              borderSide: borderSide,
              children: _buildMonthCells(theme),
            ),
          ),
          if (widget.dataSource?.isLoading ?? false)
            const CircularProgressIndicator(),
        ],
      ),
    );
  }

  void _handleControlEvent() {
    final selectedDate = widget.controller?.selectedDate ?? DateTime.now();
    if (selectedDate.dateCompareTo(_selectedDate) != 0) {
      setState(() {
        _slideDirection =
            selectedDate.dateCompareTo(_selectedDate) > 0 ? 1.0 : -1.0;
        _selectedDate = selectedDate;
      });
      widget.dataSource?.fetchEvents(selectedDate.monthDateTimeRange(
          includeTrailingAndLeadingDates:
              widget.includeTrailingAndLeadingDates));
    }
  }

  void _handleDataSource() {
    setState(() {
      _events = widget.dataSource?.events;
    });
  }
}
