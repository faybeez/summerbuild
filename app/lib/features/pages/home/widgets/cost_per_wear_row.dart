// lib/features/home/widgets/cost_per_wear_row.dart

import 'package:flutter/material.dart';
import '../../../../app_colors.dart';
import '../models/wardrobe_value_stat.dart';

class CostPerWearRow extends StatelessWidget {
  final WardrobeValueStat stat;
  final int rank;
  final VoidCallback? onTap;

  const CostPerWearRow({
    required this.stat,
    required this.rank,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cpw = stat.costPerWear;

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
            // Thumbnail
            _Thumb(imageUrl: stat.imageUrl),
            const SizedBox(width: 12),
            // Category & cost
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.categoryName ?? 'Item #${stat.clothesId}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '\$${stat.cost.toStringAsFixed(2)}  ·  ${stat.timesWorn}×',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.appEspresso.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ),
            // CPW chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cpw != null
                    ? AppColors.appOlive.withAlpha(30)
                    : AppColors.appWarmCream,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.appEspresso.withAlpha(30)),
              ),
              child: Text(
                cpw != null ? '\$${cpw.toStringAsFixed(2)}/wear' : 'Not worn',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cpw != null
                      ? AppColors.appOlive
                      : AppColors.appEspresso.withAlpha(140),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? imageUrl;
  const _Thumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 48,
        height: 48,
        color: AppColors.appWarmCream,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _Placeholder(),
              )
            : const _Placeholder(),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();
  @override
  Widget build(BuildContext context) => const Center(
    child: Icon(Icons.checkroom_outlined, size: 22, color: AppColors.appTan),
  );
}
