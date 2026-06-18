// lib/features/outfit_creator/widgets/outfit_suggestion_card.dart

import 'package:flutter/material.dart';

import '../../../../app_colors.dart';
import '../models/outfit_suggestion.dart';
import 'outfit_item_card.dart';
import 'outfit_score_badge.dart';

class OutfitSuggestionCard extends StatelessWidget {
  const OutfitSuggestionCard({
    super.key,
    required this.suggestion,
    required this.index,
    required this.onTap,
  });

  final OutfitSuggestion suggestion;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.appEspresso.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Text(
                    'Outfit ${index + 1}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                  const Spacer(),
                  OutfitScoreBadge(
                    score: suggestion.score,
                    label: suggestion.confidenceLabel,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Item thumbnails
              SizedBox(
                height: 76,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: suggestion.items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => OutfitItemCard(
                    item: suggestion.items[i],
                    size: 76,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Category chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: suggestion.items.map((item) {
                  final cat = item.category?.tagDisplayName ?? '?';
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.appChipBg,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      cat,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.appEspresso,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Reason snippet
              Text(
                suggestion.reason,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 8),

              // "View details" hint
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View details',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.appTerracotta,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(Icons.chevron_right,
                      size: 16, color: AppColors.appTerracotta),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
