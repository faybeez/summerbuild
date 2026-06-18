// lib/features/home/widgets/wardrobe_stat_summary_card.dart
//
// A compact summary card used in the top row grid (Total Items, Total Outfits, etc.)

import 'package:flutter/material.dart';
import '../../../../app_colors.dart';
import '../../../../functions.dart';

class WardrobeStatSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? accentColor;

  const WardrobeStatSummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.appTerracotta;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: cardDecoration(AppColors.appCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withAlpha(28),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.appEspresso.withAlpha(140),
            ),
          ),
        ],
      ),
    );
  }
}
