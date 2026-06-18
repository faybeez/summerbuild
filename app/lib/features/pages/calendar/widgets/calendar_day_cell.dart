import 'package:flutter/material.dart';
import 'package:elytsx/app_colors.dart';
import '../models/calendar_day_summary.dart';
import 'calendar_dot_indicator.dart';

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isCurrentMonth,
    this.summary,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool isCurrentMonth;
  final CalendarDaySummary? summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isCurrentMonth
        ? (isSelected ? Colors.white : AppColors.textMain)
        : AppColors.textMuted.withOpacity(0.4);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.appEspresso
              : isToday
              ? AppColors.appPeach.withOpacity(0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            CalendarDotIndicator(
              hasOotd: summary?.hasOotd ?? false,
              hasEvents: summary?.hasEvents ?? false,
            ),
          ],
        ),
      ),
    );
  }
}
