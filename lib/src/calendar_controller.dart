import 'package:flutter/widgets.dart';
import 'helpers/datetime_extension.dart';

class CalendarController extends ChangeNotifier {
  CalendarController({DateTime? initialDate}) : _selectedDate = initialDate;

  DateTime? get selectedDate => _selectedDate;
  DateTime? _selectedDate;
  set selectedDate(DateTime? value) {
    if (_selectedDate == value) {
      return;
    }
    _selectedDate = value;
    notifyListeners();
  }

  void nextMonth() {
    assert(_selectedDate != null);
    _selectedDate = _selectedDate!.nextMonth;
    notifyListeners();
  }

  void previousMonth() {
    assert(_selectedDate != null);
    _selectedDate = _selectedDate!.previousMonth;
    notifyListeners();
  }

  void today() {
    _selectedDate = DateTime.now();
    notifyListeners();
  }
}
