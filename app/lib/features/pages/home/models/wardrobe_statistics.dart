// lib/features/home/models/wardrobe_statistics.dart

import 'wardrobe_color_stat.dart';
import 'wardrobe_usage_stat.dart';
import 'wardrobe_value_stat.dart';

class WardrobeStatistics {
  // ── Summary ────────────────────────────────────────────────────────────────
  final int totalItems;
  final int totalOutfits;
  final double totalWardrobeCost;       // sum of non-null costs
  final double? averageCostPerItem;     // null if no costed items
  final double? utilizationRate;        // wornItems / totalItems, null if 0 items
  final int unwornCount;
  final int favoriteCount;

  // ── Top Lists ──────────────────────────────────────────────────────────────
  final List<OutfitUsageStat> mostUsedOutfits;   // top 5 by OOTD count
  final List<WardrobeColorStat> colorRatio;      // all colors, sorted by count desc
  final List<WardrobeUsageStat> mostUsedClothes; // top 5 by timesWorn
  final List<WardrobeValueStat> bestValueClothes; // top 5 by costPerWear asc
  final List<WardrobeValueStat> needsMoreWear;    // cost != null, timesWorn == 0
  final List<WardrobeValueStat> highCostLowUsage; // cost > median, timesWorn <= 1
  final List<WardrobeUsageStat> recentlyAdded;   // newest 5

  // ── Tag Insights ──────────────────────────────────────────────────────────
  final String? mostCommonCategory;
  final String? mostCommonOccasion;
  final String? mostCommonWeather;

  const WardrobeStatistics({
    required this.totalItems,
    required this.totalOutfits,
    required this.totalWardrobeCost,
    required this.averageCostPerItem,
    required this.utilizationRate,
    required this.unwornCount,
    required this.favoriteCount,
    required this.mostUsedOutfits,
    required this.colorRatio,
    required this.mostUsedClothes,
    required this.bestValueClothes,
    required this.needsMoreWear,
    required this.highCostLowUsage,
    required this.recentlyAdded,
    required this.mostCommonCategory,
    required this.mostCommonOccasion,
    required this.mostCommonWeather,
  });
}
