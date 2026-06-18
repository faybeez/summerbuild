// lib/features/home/models/wardrobe_color_stat.dart

import 'package:flutter/material.dart';

class WardrobeColorStat {
  final String colorName;
  final String colorValue; // raw tag_value for resolving Color
  final int count;
  final double percentage; // 0.0 – 100.0, rounded to 1 decimal

  const WardrobeColorStat({
    required this.colorName,
    required this.colorValue,
    required this.count,
    required this.percentage,
  });

  /// Attempts to resolve a [Color] from [colorValue].
  /// Supports named colours (BLACK, WHITE, …) and hex strings (#RRGGBB, RRGGBB).
  Color? get resolvedColor {
    const namedColors = <String, Color>{
      'BLACK': Colors.black,
      'WHITE': Colors.white,
      'GRAY': Color.fromARGB(255, 124, 124, 130),
      'GREY': Color.fromARGB(255, 124, 124, 130),
      'RED': Color.fromARGB(255, 170, 31, 31),
      'BLUE': Color.fromARGB(255, 32, 106, 190),
      'GREEN': Color.fromARGB(255, 39, 115, 43),
      'YELLOW': Color.fromARGB(255, 255, 226, 99),
      'ORANGE': Color.fromARGB(255, 222, 126, 48),
      'PURPLE': Color.fromARGB(255, 130, 67, 170),
      'PINK': Color.fromARGB(255, 245, 105, 182),
      'BROWN': Color.fromARGB(255, 85, 57, 48),
      'BEIGE': Color.fromARGB(255, 209, 191, 159),
      'CREAM': Color.fromARGB(255, 255, 238, 197),
      'NAVY': Color.fromARGB(255, 15, 27, 57),
      'GOLD': const Color(0xFFD4A017),
      'SILVER': const Color(0xFFB0BEC5),
    };

    final key = colorValue.trim().toUpperCase();
    if (namedColors.containsKey(key)) return namedColors[key];

    final raw = colorValue.trim().replaceFirst('#', '');
    final hex = switch (raw.length) {
      6 => int.tryParse('FF$raw', radix: 16),
      8 => int.tryParse(raw, radix: 16),
      _ => null,
    };
    return hex != null ? Color(hex) : null;
  }
}
