// lib/features/home/models/wardrobe_usage_stat.dart

/// Represents a single clothing item's usage data for statistics display.
class WardrobeUsageStat {
  final int clothesId;
  final String? imageUrl;
  final String? categoryName;
  final int timesWorn;

  const WardrobeUsageStat({
    required this.clothesId,
    required this.imageUrl,
    required this.categoryName,
    required this.timesWorn,
  });
}

/// Represents an outfit's usage count (proxied via OOTD links).
class OutfitUsageStat {
  final int outfitId;
  final String? outfitName;
  final int usageCount;

  const OutfitUsageStat({
    required this.outfitId,
    required this.outfitName,
    required this.usageCount,
  });
}
