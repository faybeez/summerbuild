import 'package:flutter/foundation.dart';
import '../../../data/calendar_repository.dart';
import '../../../../classes/calendar_day_summary.dart';
import '../../../../classes/calendar_event.dart';
import '../../../../classes/ootd_entry.dart';

class CalendarController extends ChangeNotifier {
  CalendarController(this._repository);

  final CalendarRepository _repository;

  // ── State ─────────────────────────────────────────────────────────────────
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  List<CalendarDaySummary> _monthSummaries = [];
  List<CalendarEvent> _upcomingEvents = [];
  bool _isLoading = false;
  String? _error;

  // ── Getters ───────────────────────────────────────────────────────────────
  DateTime get focusedMonth => _focusedMonth;
  List<CalendarDaySummary> get monthSummaries => _monthSummaries;
  List<CalendarEvent> get upcomingEvents => _upcomingEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CalendarDaySummary? summaryFor(DateTime date) {
    return _monthSummaries
        .where(
          (s) =>
              s.date.year == date.year &&
              s.date.month == date.month &&
              s.date.day == date.day,
        )
        .firstOrNull;
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  Future<void> loadMonth(DateTime month) async {
    _focusedMonth = DateTime(month.year, month.month);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.fetchMonthSummary(month: month),
        _repository.fetchUpcomingEvents(),
      ]);
      _monthSummaries = results[0] as List<CalendarDaySummary>;
      _upcomingEvents = results[1] as List<CalendarEvent>;
    } catch (e) {
      _error = e.toString();
      debugPrint('CalendarController.loadMonth error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadMonth(_focusedMonth);

  Future<void> goToMonth(DateTime month) => loadMonth(month);
}
