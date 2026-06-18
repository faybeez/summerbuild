import 'package:flutter/material.dart';
import 'package:elytsx/app_colors.dart';

class CalendarDotIndicator extends StatelessWidget {
  const CalendarDotIndicator({
    super.key,
    required this.hasOotd,
    required this.hasEvents,
  });

  final bool hasOotd;
  final bool hasEvents;

  static const Color ootdColor = AppColors.appTerracotta;
  static const Color eventColor = Color(0xFF4A7FC1);

  @override
  Widget build(BuildContext context) {
    if (!hasOotd && !hasEvents) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasOotd) _dot(ootdColor),
        if (hasOotd && hasEvents) const SizedBox(width: 2),
        if (hasEvents) _dot(eventColor),
      ],
    );
  }

  Widget _dot(Color color) => Container(
    width: 5,
    height: 5,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
