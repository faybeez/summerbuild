// lib/features/outfit_creator/widgets/outfit_score_badge.dart

import 'package:flutter/material.dart';
import '../../../../app_colors.dart';

class OutfitScoreBadge extends StatelessWidget {
  const OutfitScoreBadge({
    super.key,
    required this.score,
    required this.label,
  });

  final int score;
  final String label;

  Color get _badgeColor {
    if (score >= 75) return AppColors.success;
    if (score >= 50) return AppColors.appOlive;
    return AppColors.appTerracotta;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: _badgeColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$score',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _badgeColor,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
