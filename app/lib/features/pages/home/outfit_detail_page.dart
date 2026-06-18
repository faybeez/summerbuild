import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app_colors.dart';
import '../../../classes/classes.dart';
import '../../../functions.dart';

import '../wardrobe/wardrobe_detail_page.dart';

class OutfitDetailPage extends StatelessWidget {
  const OutfitDetailPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
    required this.pieces,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<Color> colors;
  final List<OutfitPiece> pieces;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: AppColors.appWarmCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1DFC8), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 56,
                    color: AppColors.appEspresso.withAlpha(60),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Outfit image',
                    style: TextStyle(
                      color: AppColors.appEspresso.withAlpha(120),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.appEspresso.withAlpha(180),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: colors.map((color) {
                return Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.appEspresso.withAlpha(35),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Text(
              'Pieces',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              itemCount: pieces.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (context, index) {
                final piece = pieces[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => WardrobeDetailPage(
                          item: WardrobeItem(
                            piece.name,
                            piece.category,
                            piece.color ?? AppColors.appTan,
                            piece.icon ?? Icons.checkroom_outlined,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: cardDecoration(AppColors.appCard),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          piece.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          piece.category,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.appEspresso.withAlpha(150),
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
