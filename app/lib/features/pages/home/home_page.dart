import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app_colors.dart';
import '../../../classes/classes.dart';
import '../../services/weather_service.dart';

import 'outfit_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? weather;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final result = await WeatherService().fetchWeather();
      setState(() {
        weather = result;
      });
    } catch (e) {
      setState(() {
        weather = {'error': true};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Today',
      subtitle: weather?['area'] ?? 'Loading area...',
      children: [
        ForecastCard(
          forecast: weather?['forecast'],
          temperature: weather?['temperature'],
          humidity: weather?['humidity'],
        ),
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
