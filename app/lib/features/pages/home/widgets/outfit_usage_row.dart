// lib/features/home/widgets/outfit_usage_row.dart

import 'package:flutter/material.dart';
import '../../../../app_colors.dart';
import '../models/wardrobe_usage_stat.dart';

class OutfitUsageRow extends StatelessWidget {
  final OutfitUsageStat stat;
  final int rank;
  final VoidCallback? onTap;

  const OutfitUsageRow({
    required this.stat,
    required this.rank,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Rank badge
            SizedBox(
              width: 22,
              child: Text(
                '#$rank',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.appEspresso.withAlpha(100),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Icon box
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.appWarmCream,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.style_outlined,
                size: 22,
                color: AppColors.appTan,
              ),
            ),
            const SizedBox(width: 12),
            // Name
            Expanded(
              child: Text(
                stat.outfitName ?? 'Outfit #${stat.outfitId}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // OOTD count chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.appWarmCream,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.appEspresso.withAlpha(30)),
              ),
              child: Text(
                '${stat.usageCount} OOTD',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
