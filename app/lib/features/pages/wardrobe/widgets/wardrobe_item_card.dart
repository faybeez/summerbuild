// lib/features/wardrobe/widgets/wardrobe_item_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app_colors.dart';
import '../../../../functions.dart';
import '../../../data/wardrobe_repository.dart';

class WardrobeItemCard extends StatelessWidget {
  const WardrobeItemCard({super.key, required this.item, this.onTap});

  final WardrobeClothingItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final category = item.category?.tagDisplayName;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: cardDecoration(AppColors.appCard),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ─────────────────────────────────────────────
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: item.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        memCacheHeight: 400,
                        placeholder: (_, __) => _placeholder(),
                        errorWidget: (_, __, ___) => _errorPlaceholder(),
                      )
                    : _placeholder(),
              ),
            ),

            // ── Bottom label ───────────────────────────────────────────
            if (category != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.appEspresso.withAlpha(180),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.appWarmCream,
    child: const Center(
      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.appTan),
    ),
  );

  Widget _errorPlaceholder() => Container(
    color: AppColors.appWarmCream,
    child: const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.appTan,
        size: 32,
      ),
    ),
  );
}
