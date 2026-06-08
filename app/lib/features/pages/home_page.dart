import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app_colors.dart';
import '../../classes.dart';

import 'outfit_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Today',
      subtitle: 'Warm afternoon, light breeze',
      children: [
        const ForecastCard(),
        SectionHeader(
          title: 'Recommended Outfits',
          actionLabel: 'Refresh',
          onPressed: () {},
        ),
        OutfitRecommendation(
          title: 'Cafe catch-up',
          description: 'Linen shirt, straight jeans, leather sandals',
          icon: Icons.local_cafe,
          colors: const [
            AppColors.appWarmCream,
            AppColors.appOlive,
            AppColors.appTerracotta,
          ],
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const OutfitDetailPage(
                  title: 'Cafe catch-up',
                  description: 'Linen shirt, straight jeans, leather sandals',
                  icon: Icons.local_cafe,
                  colors: [
                    AppColors.appWarmCream,
                    AppColors.appOlive,
                    AppColors.appTerracotta,
                  ],
                  pieces: [
                    OutfitPiece(
                      'Linen shirt',
                      'Tops',
                      color: AppColors.appPeach,
                      icon: Icons.dry_cleaning,
                    ),
                    OutfitPiece(
                      'Straight jeans',
                      'Bottoms',
                      color: AppColors.appOlive,
                      icon: Icons.style,
                    ),
                    OutfitPiece(
                      'Leather sandals',
                      'Shoes',
                      color: AppColors.appEspresso,
                      icon: Icons.ice_skating,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        OutfitRecommendation(
          title: 'Evening errands',
          description: 'Ribbed tank, relaxed trousers, cropped overshirt',
          icon: Icons.shopping_bag_outlined,
          colors: const [
            AppColors.appPeach,
            AppColors.appEspresso,
            AppColors.appTan,
          ],
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const OutfitDetailPage(
                  title: 'Evening errands',
                  description:
                      'Ribbed tank, relaxed trousers, cropped overshirt',
                  icon: Icons.shopping_bag_outlined,
                  colors: [
                    AppColors.appPeach,
                    AppColors.appEspresso,
                    AppColors.appTan,
                  ],
                  pieces: [
                    OutfitPiece(
                      'Ribbed tank',
                      'Tops',
                      color: AppColors.appPeach,
                      icon: Icons.dry_cleaning,
                    ),
                    OutfitPiece(
                      'Relaxed trousers',
                      'Bottoms',
                      color: AppColors.appOlive,
                      icon: Icons.style,
                    ),
                    OutfitPiece(
                      'Cropped overshirt',
                      'Outerwear',
                      color: AppColors.appWarmCream,
                      icon: Icons.layers,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
