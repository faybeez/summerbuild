// lib/features/home/widgets/clothing_usage_row.dart

import 'package:flutter/material.dart';
import '../../../../app_colors.dart';
import '../models/wardrobe_usage_stat.dart';

class ClothingUsageRow extends StatelessWidget {
  final WardrobeUsageStat stat;
  final int rank;
  final VoidCallback? onTap;

  const ClothingUsageRow({
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
            // Thumbnail
            _ClothingThumb(imageUrl: stat.imageUrl),
            const SizedBox(width: 12),
            // Name / category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.categoryName ?? 'Unknown',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Item #${stat.clothesId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.appEspresso.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ),
            // Wear count chip
            _WearChip(count: stat.timesWorn),
          ],
        ),
      ),
    );
  }
}

class _ClothingThumb extends StatelessWidget {
  final String? imageUrl;

  const _ClothingThumb({required this.imageUrl});

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
                errorBuilder: (_, __, ___) => const _PlaceholderIcon(),
              )
            : const _PlaceholderIcon(),
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.checkroom_outlined, size: 22, color: AppColors.appTan),
    );
  }
}

class _WearChip extends StatelessWidget {
  final int count;

  const _WearChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.appWarmCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.appEspresso.withAlpha(30)),
      ),
      child: Text(
        '$count×',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
