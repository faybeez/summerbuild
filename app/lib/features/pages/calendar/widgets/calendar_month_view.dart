import 'package:flutter/material.dart';
import 'package:elytsx/app_colors.dart';
import '../../../../classes/calendar_day_summary.dart';
import 'calendar_day_cell.dart';

class CalendarMonthView extends StatelessWidget {
  const CalendarMonthView({
    super.key,
    required this.focusedMonth,
    required this.summaries,
    required this.selectedDate,
    required this.onDaySelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final DateTime focusedMonth;
  final List<CalendarDaySummary> summaries;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  static const _weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = _buildDayGrid();
    final summaryMap = {
      for (final s in summaries)
        '${s.date.year}-${s.date.month}-${s.date.day}': s,
    };

    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 8),
        _buildWeekdayRow(),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final date = days[index];
            final key = '${date.year}-${date.month}-${date.day}';
            final isCurrentMonth = date.month == focusedMonth.month;
            final isToday =
                date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;
            final isSelected =
                selectedDate != null &&
                date.year == selectedDate!.year &&
                date.month == selectedDate!.month &&
                date.day == selectedDate!.day;

            return CalendarDayCell(
              date: date,
              isToday: isToday,
              isSelected: isSelected,
              isCurrentMonth: isCurrentMonth,
              summary: summaryMap[key],
              onTap: () => onDaySelected(date),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildLegend(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPreviousMonth,
          icon: const Icon(Icons.chevron_left, color: AppColors.textMain),
        ),
        Text(
          '${_months[focusedMonth.month - 1]} ${focusedMonth.year}',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
        ),
        IconButton(
          onPressed: onNextMonth,
          icon: const Icon(Icons.chevron_right, color: AppColors.textMain),
        ),
      ],
    );
  }

  Widget _buildWeekdayRow() {
    return Row(
      children: _weekdays.map((d) {
        return Expanded(
          child: Center(
            child: Text(
              d,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(color: const Color(0xFFA65F46), label: 'OOTD'),
        const SizedBox(width: 16),
        _legendItem(color: const Color(0xFF4A7FC1), label: 'Event'),
      ],
    );
  }

  Widget _legendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  List<DateTime> _buildDayGrid() {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDay = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    final startPadding = firstDay.weekday % 7;
    final endPadding = (6 - (lastDay.weekday % 7));

    final days = <DateTime>[];
    for (int i = startPadding; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }
    for (int i = 0; i < lastDay.day; i++) {
      days.add(DateTime(firstDay.year, firstDay.month, i + 1));
    }
    for (int i = 1; i <= endPadding; i++) {
      days.add(lastDay.add(Duration(days: i)));
    }
    return days;
  }
}
