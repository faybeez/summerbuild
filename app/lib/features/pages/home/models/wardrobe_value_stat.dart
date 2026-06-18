// lib/features/home/models/wardrobe_value_stat.dart

/// A single clothing item's cost-per-wear calculation.
class WardrobeValueStat {
  final int clothesId;
  final String? imageUrl;
  final String? categoryName;
  final double cost;
  final int timesWorn;

  const WardrobeValueStat({
    required this.clothesId,
    required this.imageUrl,
    required this.categoryName,
    required this.cost,
    required this.timesWorn,
  });

  /// Returns cost / timesWorn, or null if timesWorn == 0.
  double? get costPerWear =>
      timesWorn > 0 ? (cost / timesWorn) : null;

  String get costPerWearLabel {
    final cpw = costPerWear;
    if (cpw == null) return 'Not worn yet';
    return '\$${cpw.toStringAsFixed(2)} / wear';
  }
}
