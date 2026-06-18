// lib/features/home/widgets/color_ratio_card.dart

import 'package:flutter/material.dart';
import '../../../../app_colors.dart';
import '../../../../functions.dart';
import '../models/wardrobe_color_stat.dart';

class ColorRatioCard extends StatelessWidget {
  final List<WardrobeColorStat> colors;

  const ColorRatioCard({required this.colors, super.key});

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();

    // Build colour bar segments
    final total = colors.fold(0, (sum, c) => sum + c.count);
    final topColors = colors.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(AppColors.appCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: topColors.map((c) {
                  final flex = (c.count / total * 1000).round().clamp(1, 1000);
                  final resolved = c.resolvedColor;
                  return Expanded(
                    flex: flex,
                    child: Container(color: resolved ?? AppColors.appTan),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend rows
          ...topColors.map((c) => _ColorRow(stat: c)),
        ],
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  final WardrobeColorStat stat;

  const _ColorRow({required this.stat});

  @override
  Widget build(BuildContext context) {
    final resolved = stat.resolvedColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Swatch
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: resolved ?? AppColors.appTan,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.appEspresso.withAlpha(35)),
            ),
          ),
          const SizedBox(width: 8),
          // Name
          Expanded(
            child: Text(
              stat.colorName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          // Count + percentage
          Text(
            '${stat.count} · ${stat.percentage.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.appEspresso.withAlpha(140),
            ),
          ),
          const SizedBox(width: 6),
          // Mini progress bar
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: stat.percentage / 100,
                minHeight: 6,
                backgroundColor: AppColors.appEspresso.withAlpha(20),
                valueColor: AlwaysStoppedAnimation<Color>(
                  resolved ?? AppColors.appTan,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
