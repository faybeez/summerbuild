// lib/features/outfit_creator/pages/outfit_detail_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_colors.dart';
import '../models/outfit_suggestion.dart';
import '../widgets/outfit_item_card.dart';
import '../widgets/outfit_score_badge.dart';

class OutfitDetailPage extends StatelessWidget {
  const OutfitDetailPage({
    super.key,
    required this.suggestion,
  });

  final OutfitSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textMain,
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Outfit Detail',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.appEspresso,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            // Score banner
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.appWarmCream,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Score',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        OutfitScoreBadge(
                          score: suggestion.score,
                          label: suggestion.confidenceLabel,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.auto_awesome,
                      size: 28, color: AppColors.appOlive),
                ],
              ),
            ),

            // Items grid
            const _SectionHeading(text: 'Items in this outfit'),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: suggestion.items.length,
              itemBuilder: (_, i) {
                final item = suggestion.items[i];
                return Column(
                  children: [
                    Expanded(child: OutfitItemCard(item: item, size: 90)),
                    const SizedBox(height: 4),
                    Text(
                      item.category?.tagDisplayName ?? '',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Tags per item
            const _SectionHeading(text: 'Tags'),
            const SizedBox(height: 10),
            ...suggestion.items.map((item) {
              final nonCatTags = item.tags
                  .where((t) => t.tagType.toUpperCase() != 'CATEGORY')
                  .toList();
              if (nonCatTags.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category?.tagDisplayName ?? 'Item',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: nonCatTags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.appChipBg,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              tag.tagWidget(
                                size: 12,
                                iconColor: AppColors.appOlive,
                                haveBorderColor: true,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tag.tagDisplayName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.appEspresso,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // AI reason
            const _SectionHeading(text: 'Why this works'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 18, color: AppColors.appOlive),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      suggestion.reason,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMain,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Styling tip
            const _SectionHeading(text: 'Styling tip'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.appChipBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.appPeach.withOpacity(0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline,
                      size: 18, color: AppColors.appTerracotta),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      suggestion.stylingTip,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMain,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Save button (placeholder — wire to OutfitRepository as needed)
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Outfit saved! 🎉'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.appEspresso,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_add_outlined,
                          size: 18, color: AppColors.appCream),
                      SizedBox(width: 8),
                      Text(
                        'Save Outfit',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.appCream,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.appEspresso,
      ),
    );
  }
}
