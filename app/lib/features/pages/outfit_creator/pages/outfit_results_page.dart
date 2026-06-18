// lib/features/outfit_creator/pages/outfit_results_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app_colors.dart';
import '../models/outfit_suggestion.dart';
import '../state/outfit_creator_controller.dart';
import '../widgets/outfit_suggestion_card.dart';

class OutfitResultsPage extends StatelessWidget {
  const OutfitResultsPage({
    super.key,
    required this.controller,
  });

  final OutfitCreatorController controller;

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
          'Your Outfits',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.appEspresso,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () async {
                await controller.generate();
                // Controller notifies listeners — router stays, list rebuilds.
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.appChipBg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded,
                        size: 15, color: AppColors.appEspresso),
                    const SizedBox(width: 5),
                    const Text(
                      'Regenerate',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.appEspresso,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            if (controller.status == OutfitCreatorStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.appOlive,
                ),
              );
            }

            if (controller.status == OutfitCreatorStatus.insufficientWardrobe) {
              return const _InsufficientWardrobeState();
            }

            if (controller.suggestions.isEmpty) {
              return const _EmptyState();
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Styled for ${_display(controller.occasion)} · ${_display(controller.weather)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                ...controller.suggestions.asMap().entries.map(
                  (e) => OutfitSuggestionCard(
                    suggestion: e.value,
                    index: e.key,
                    onTap: () => context.push(
                      '/studio/ai/detail',
                      extra: e.value,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _display(String val) {
    if (val.isEmpty) return val;
    return val[0].toUpperCase() + val.substring(1).toLowerCase();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checkroom_outlined, size: 40, color: AppColors.appTan),
            SizedBox(height: 12),
            Text(
              'No outfits found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Try changing your occasion or weather and regenerate.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsufficientWardrobeState extends StatelessWidget {
  const _InsufficientWardrobeState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_circle_outline,
                size: 40, color: AppColors.appTan),
            const SizedBox(height: 12),
            const Text(
              'Not enough clothes',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your wardrobe needs at least a top (or dress) and shoes to '
              'create an outfit. Add more items and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.go('/wardrobe/add'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.appEspresso,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text(
                  'Add to Wardrobe',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.appCream,
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
