import 'package:flutter/material.dart';
import 'package:elytsx/app_colors.dart';
import '../../../../classes/ootd_entry.dart';

class OotdCard extends StatelessWidget {
  const OotdCard({super.key, required this.ootd, required this.onEdit});

  final OotdEntry ootd;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ootd.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  ootd.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.appPeach.withOpacity(0.3),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: AppColors.appTan,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ootd.caption ?? 'Outfit of the Day',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMain,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onEdit,
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                if (ootd.linkedOutfitName != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.checkroom,
                        size: 13,
                        color: AppColors.appTerracotta,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ootd.linkedOutfitName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.appTerracotta,
                        ),
                      ),
                    ],
                  ),
                ],
                if (ootd.linkedEventTitle != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.event,
                        size: 13,
                        color: Color(0xFF4A7FC1),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ootd.linkedEventTitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4A7FC1),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
