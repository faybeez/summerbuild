import 'package:flutter/material.dart';
import 'app_colors.dart';

BoxDecoration cardDecoration(Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: const Color(0xFFF3E3CC)),
    boxShadow: [
      BoxShadow(
        color: AppColors.appTan.withAlpha(35),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
