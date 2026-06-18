// lib/features/outfit_creator/widgets/outfit_item_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app_colors.dart';
import '../../../data/wardrobe_repository.dart';

class OutfitItemCard extends StatelessWidget {
  const OutfitItemCard({super.key, required this.item, this.size = 80});

  final WardrobeClothingItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.appEspresso.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: item.imageUrl != null
          ? CachedNetworkImage(
              imageUrl: item.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: AppColors.appHandleBar.withOpacity(0.3)),
              errorWidget: (_, __, ___) => _Placeholder(size: size),
            )
          : _Placeholder(size: size),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.appHandleBar.withOpacity(0.3),
      child: Icon(
        Icons.checkroom_outlined,
        size: size * 0.35,
        color: AppColors.appTan,
      ),
    );
  }
}
