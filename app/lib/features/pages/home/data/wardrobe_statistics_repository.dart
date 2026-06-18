// lib/features/home/data/wardrobe_statistics_repository.dart
//
// Fetches all data needed for the Wardrobe Statistics dashboard.
// Reuses the same Supabase client pattern as WardrobeRepository and
// CalendarRepository — no new dependencies required.

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../features/data/wardrobe_repository.dart'
    show WardrobeClothingItem;
import '../models/wardrobe_color_stat.dart';
import '../models/wardrobe_statistics.dart';
import '../models/wardrobe_usage_stat.dart';
import '../models/wardrobe_value_stat.dart';

class WardrobeStatisticsRepository {
  WardrobeStatisticsRepository(this._supabase);

  final SupabaseClient _supabase;

  String get _userId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw StateError('User not authenticated');
    return id;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Public API
  // ───────────────────────────────────────────────────────────────────────────

  Future<WardrobeStatistics> fetchWardrobeStatistics() async {
    // Run all Supabase fetches in parallel where possible.
    final results = await Future.wait([
      _fetchAllClothes(), // index 0
      _fetchAllClothesTagIds(), // index 1 — {clothesId: [tagId,...]}
      _fetchAllTags(), // index 2 — [tag rows]
      _fetchOutfitCount(), // index 3
      _fetchOotdOutfitLinks(), // index 4 — [{outfit_id, ...}]
    ]);

    final clothes = results[0] as List<_ClothesRow>;
    final clothesTagIds = results[1] as Map<int, List<int>>;
    final allTags = results[2] as List<_TagRow>;
    final totalOutfits = results[3] as int;
    final ootdLinks = results[4] as List<_OotdOutfitLink>;

    // ── Signed URLs (batched) ────────────────────────────────────────────────
    final urlMap = await _fetchSignedUrls(clothes);

    // ── Build tag lookup {id → TagRow} ───────────────────────────────────────
    final tagById = {for (final t in allTags) t.id: t};

    // ── Attach tags and URLs to each clothes row ─────────────────────────────
    final enriched = clothes.map((c) {
      final tagIds = clothesTagIds[c.id] ?? [];
      final tags = tagIds
          .map((tid) => tagById[tid])
          .whereType<_TagRow>()
          .toList();
      final url = urlMap['$_userId/${c.id}.${c.imageType}'];
      return _EnrichedClothes(c, tags, url);
    }).toList();

    return _calculate(enriched, totalOutfits, ootdLinks);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Private Supabase fetchers
  // ───────────────────────────────────────────────────────────────────────────

  Future<List<_ClothesRow>> _fetchAllClothes() async {
    final res = await _supabase
        .from('clothes')
        .select('id, image_type, cost, times_worn, is_favorite, created_at')
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (res as List)
        .map((r) => _ClothesRow.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<Map<int, List<int>>> _fetchAllClothesTagIds() async {
    final res = await _supabase
        .from('clothes_tags')
        .select('clothes_id, tag_id');

    final rows = res as List;
    final map = <int, List<int>>{};
    for (final row in rows) {
      final cid = (row['clothes_id'] as num).toInt();
      final tid = (row['tag_id'] as num).toInt();
      (map[cid] ??= []).add(tid);
    }
    return map;
  }

  Future<List<_TagRow>> _fetchAllTags() async {
    final res = await _supabase
        .from('tags')
        .select('id, tag_type, tag_value, tag_display_name');

    return (res as List)
        .map((r) => _TagRow.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<int> _fetchOutfitCount() async {
    final res = await _supabase
        .from('outfits')
        .select('id')
        .eq('user_id', _userId);
    return (res as List).length;
  }

  /// Returns a list of {outfit_id} rows from ootd_entries for this user
  /// where outfit_id is not null. Used as a proxy for most-used outfits.
  Future<List<_OotdOutfitLink>> _fetchOotdOutfitLinks() async {
    final res = await _supabase
        .from('ootd_entries')
        .select('outfit_id')
        .eq('user_id', _userId)
        .not('outfit_id', 'is', null);

    return (res as List)
        .map((r) => _OotdOutfitLink(outfitId: (r['outfit_id'] as num).toInt()))
        .toList();
  }

  // ── Outfit names for top-used list ─────────────────────────────────────────
  Future<Map<int, String?>> _fetchOutfitNames(List<int> ids) async {
    if (ids.isEmpty) return {};
    final res = await _supabase
        .from('outfits')
        .select('id, name')
        .inFilter('id', ids)
        .eq('user_id', _userId);

    return {
      for (final r in (res as List))
        (r['id'] as num).toInt(): r['name'] as String?,
    };
  }

  Future<Map<String, String>> _fetchSignedUrls(
    List<_ClothesRow> clothes,
  ) async {
    if (clothes.isEmpty) return {};
    final paths = clothes
        .map((c) => '$_userId/${c.id}.${c.imageType}')
        .toList();

    try {
      final results = await _supabase.storage
          .from('clothes_photos')
          .createSignedUrls(paths, 3600);

      return {
        for (final s in results)
          if (s.path != null && s.signedUrl != null) s.path!: s.signedUrl!,
      };
    } catch (_) {
      return {};
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Statistics calculation (pure Dart, no division by zero)
  // ───────────────────────────────────────────────────────────────────────────

  Future<WardrobeStatistics> _calculate(
    List<_EnrichedClothes> enriched,
    int totalOutfits,
    List<_OotdOutfitLink> ootdLinks,
  ) async {
    final total = enriched.length;

    // ── Cost aggregates ──────────────────────────────────────────────────────
    final costedItems = enriched.where((e) => e.clothes.cost != null).toList();
    final totalCost = costedItems.fold(0.0, (sum, e) => sum + e.clothes.cost!);
    final averageCost = costedItems.isNotEmpty
        ? (totalCost / costedItems.length)
        : null;

    // ── Utilisation ──────────────────────────────────────────────────────────
    final wornCount = enriched.where((e) => e.clothes.timesWorn > 0).length;
    final utilizationRate = total > 0 ? (wornCount / total) : null;
    final unwornCount = total - wornCount;
    final favoriteCount = enriched.where((e) => e.clothes.isFavorite).length;

    // ── Most-used outfits (OOTD proxy) ───────────────────────────────────────
    final outfitUsageMap = <int, int>{};
    for (final link in ootdLinks) {
      outfitUsageMap[link.outfitId] = (outfitUsageMap[link.outfitId] ?? 0) + 1;
    }
    final sortedOutfitIds = outfitUsageMap.keys.toList()
      ..sort((a, b) => outfitUsageMap[b]!.compareTo(outfitUsageMap[a]!));
    final topOutfitIds = sortedOutfitIds.take(5).toList();
    final outfitNames = await _fetchOutfitNames(topOutfitIds);

    final mostUsedOutfits = topOutfitIds.map((id) {
      return OutfitUsageStat(
        outfitId: id,
        outfitName: outfitNames[id],
        usageCount: outfitUsageMap[id]!,
      );
    }).toList();

    // ── Color ratio ──────────────────────────────────────────────────────────
    final colorCount = <String, int>{};
    final colorDisplay = <String, String>{}; // value → displayName
    for (final e in enriched) {
      for (final t in e.colorTags) {
        final key = t.tagValue.trim().toUpperCase();
        colorCount[key] = (colorCount[key] ?? 0) + 1;
        colorDisplay[key] = t.tagDisplayName;
      }
    }
    final totalColorCount = colorCount.values.fold(0, (sum, c) => sum + c);
    final colorRatio = colorCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final colorStats = colorRatio.map((e) {
      final pct = totalColorCount > 0
          ? double.parse(((e.value / totalColorCount) * 100).toStringAsFixed(1))
          : 0.0;
      return WardrobeColorStat(
        colorName: colorDisplay[e.key] ?? e.key,
        colorValue: e.key,
        count: e.value,
        percentage: pct,
      );
    }).toList();

    // ── Most-used clothes ────────────────────────────────────────────────────
    final sortedByWorn = [...enriched]
      ..sort((a, b) => b.clothes.timesWorn.compareTo(a.clothes.timesWorn));
    final mostUsedClothes = sortedByWorn.take(5).map((e) {
      return WardrobeUsageStat(
        clothesId: e.clothes.id,
        imageUrl: e.imageUrl,
        categoryName: e.categoryTag?.tagDisplayName,
        timesWorn: e.clothes.timesWorn,
      );
    }).toList();

    // ── Best value clothes (cost != null AND timesWorn > 0) ──────────────────
    final valueable = costedItems.where((e) => e.clothes.timesWorn > 0).toList()
      ..sort((a, b) {
        final cpwA = a.clothes.cost! / a.clothes.timesWorn;
        final cpwB = b.clothes.cost! / b.clothes.timesWorn;
        return cpwA.compareTo(cpwB);
      });
    final bestValueClothes = valueable.take(5).map((e) {
      return WardrobeValueStat(
        clothesId: e.clothes.id,
        imageUrl: e.imageUrl,
        categoryName: e.categoryTag?.tagDisplayName,
        cost: e.clothes.cost!,
        timesWorn: e.clothes.timesWorn,
      );
    }).toList();

    // ── Needs more wear (cost != null, timesWorn == 0) ───────────────────────
    final needsMoreWear = costedItems
        .where((e) => e.clothes.timesWorn == 0)
        .take(5)
        .map(
          (e) => WardrobeValueStat(
            clothesId: e.clothes.id,
            imageUrl: e.imageUrl,
            categoryName: e.categoryTag?.tagDisplayName,
            cost: e.clothes.cost!,
            timesWorn: 0,
          ),
        )
        .toList();

    // ── High cost, low usage ─────────────────────────────────────────────────
    List<WardrobeValueStat> highCostLowUsage = [];
    if (costedItems.isNotEmpty) {
      final costs = costedItems.map((e) => e.clothes.cost!).toList()..sort();
      final medianCost = costs[costs.length ~/ 2];
      highCostLowUsage = costedItems
          .where(
            (e) => e.clothes.cost! > medianCost && e.clothes.timesWorn <= 1,
          )
          .take(5)
          .map(
            (e) => WardrobeValueStat(
              clothesId: e.clothes.id,
              imageUrl: e.imageUrl,
              categoryName: e.categoryTag?.tagDisplayName,
              cost: e.clothes.cost!,
              timesWorn: e.clothes.timesWorn,
            ),
          )
          .toList();
    }

    // ── Recently added ───────────────────────────────────────────────────────
    // enriched is already sorted by created_at desc
    final recentlyAdded = enriched.take(5).map((e) {
      return WardrobeUsageStat(
        clothesId: e.clothes.id,
        imageUrl: e.imageUrl,
        categoryName: e.categoryTag?.tagDisplayName,
        timesWorn: e.clothes.timesWorn,
      );
    }).toList();

    // ── Tag insights ─────────────────────────────────────────────────────────
    String? _topTagDisplay(String tagType) {
      final freq = <String, int>{};
      final display = <String, String>{};
      for (final e in enriched) {
        for (final t in e.tags) {
          if (t.tagType.toUpperCase() != tagType) continue;
          final key = t.tagValue.trim().toUpperCase();
          freq[key] = (freq[key] ?? 0) + 1;
          display[key] = t.tagDisplayName;
        }
      }
      if (freq.isEmpty) return null;
      final topKey = freq.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      return display[topKey];
    }

    return WardrobeStatistics(
      totalItems: total,
      totalOutfits: totalOutfits,
      totalWardrobeCost: double.parse(totalCost.toStringAsFixed(2)),
      averageCostPerItem: averageCost != null
          ? double.parse(averageCost.toStringAsFixed(2))
          : null,
      utilizationRate: utilizationRate,
      unwornCount: unwornCount,
      favoriteCount: favoriteCount,
      mostUsedOutfits: mostUsedOutfits,
      colorRatio: colorStats,
      mostUsedClothes: mostUsedClothes,
      bestValueClothes: bestValueClothes,
      needsMoreWear: needsMoreWear,
      highCostLowUsage: highCostLowUsage,
      recentlyAdded: recentlyAdded,
      mostCommonCategory: _topTagDisplay('CATEGORY'),
      mostCommonOccasion: _topTagDisplay('OCCASION'),
      mostCommonWeather: _topTagDisplay('WEATHER'),
    );
  }
}

// ─── Private data transfer objects ────────────────────────────────────────────

class _ClothesRow {
  final int id;
  final String imageType;
  final double? cost;
  final int timesWorn;
  final bool isFavorite;
  final String createdAt;

  _ClothesRow({
    required this.id,
    required this.imageType,
    required this.cost,
    required this.timesWorn,
    required this.isFavorite,
    required this.createdAt,
  });

  factory _ClothesRow.fromJson(Map<String, dynamic> json) {
    return _ClothesRow(
      id: (json['id'] as num).toInt(),
      imageType: json['image_type'] as String? ?? 'png',
      cost: (json['cost'] as num?)?.toDouble(),
      timesWorn: (json['times_worn'] as num? ?? 0).toInt(),
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: json['created_at'] as String,
    );
  }
}

class _TagRow {
  final int id;
  final String tagType;
  final String tagValue;
  final String tagDisplayName;

  _TagRow({
    required this.id,
    required this.tagType,
    required this.tagValue,
    required this.tagDisplayName,
  });

  factory _TagRow.fromJson(Map<String, dynamic> json) {
    return _TagRow(
      id: (json['id'] as num).toInt(),
      tagType: json['tag_type'] as String? ?? '',
      tagValue: json['tag_value'] as String? ?? '',
      tagDisplayName: json['tag_display_name'] as String? ?? '',
    );
  }
}

class _OotdOutfitLink {
  final int outfitId;
  _OotdOutfitLink({required this.outfitId});
}

class _EnrichedClothes {
  final _ClothesRow clothes;
  final List<_TagRow> tags;
  final String? imageUrl;

  _EnrichedClothes(this.clothes, this.tags, this.imageUrl);

  List<_TagRow> get colorTags =>
      tags.where((t) => t.tagType.toUpperCase() == 'COLOR').toList();

  _TagRow? get categoryTag =>
      tags.where((t) => t.tagType.toUpperCase() == 'CATEGORY').firstOrNull;
}
