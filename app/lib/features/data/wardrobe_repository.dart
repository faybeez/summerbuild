import 'package:elytsx/classes/clothing_tag.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../classes/classes.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class WardrobeClothingItem {
  final int id;
  final String? imageUrl;
  final String? imageType;
  final double cost;
  final int timesWorn;
  final String createdAt;
  final List<ClothingTag> tags;

  const WardrobeClothingItem({
    required this.id,
    required this.imageUrl,
    this.imageType,
    required this.cost,
    required this.timesWorn,
    required this.createdAt,
    required this.tags,
  });

  factory WardrobeClothingItem.fromJson(Map<dynamic, dynamic> json) {
    final rawTags = json['tags'] as List? ?? [];
    return WardrobeClothingItem(
      id: (json['id'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      imageType: json['imageType'] as String?,
      cost: (json['cost'] as num? ?? 0).toDouble(),
      timesWorn: (json['timesWorn'] as num? ?? 0).toInt(),
      createdAt: json['createdAt'] as String,
      tags: rawTags.map((t) {
        final map = t as Map;
        return ClothingTag(
          id: (map['id'] as num).toInt(),
          tagType: (map['tag_type'] as String?) ?? '',
          tagValue: (map['tag_value'] as String?) ?? '',
          tagDisplayName: (map['tag_display_name'] as String?) ?? '',
        );
      }).toList(),
    );
  }

  @override
  String toString() {
    return 'WardrobeClothingItem('
        'id: $id, '
        'imageUrl: $imageUrl, '
        'cost: $cost, '
        'timesWorn: $timesWorn, '
        'createdAt: $createdAt, '
        'category: ${category?.tagDisplayName}, '
        'tags: $tags'
        ')';
  }

  ClothingTag? get category =>
      tags.where((t) => t.tagType.toUpperCase() == 'CATEGORY').firstOrNull;

  List<ClothingTag> get colorTags =>
      tags.where((t) => t.tagType.toUpperCase() == 'COLOR').toList();

  List<ClothingTag> get occasionTags =>
      tags.where((t) => t.tagType.toUpperCase() == 'OCCASION').toList();

  List<ClothingTag> get weatherTags =>
      tags.where((t) => t.tagType.toUpperCase() == 'WEATHER').toList();
}

class WardrobeItems {
  final List<WardrobeClothingItem> items;
  final bool hasMore;
  final String? cursor;

  const WardrobeItems({
    required this.items,
    required this.hasMore,
    required this.cursor,
  });
}

// ─── Repository ───────────────────────────────────────────────────────────────

class WardrobeRepository {
  WardrobeRepository(this._supabase);

  final SupabaseClient _supabase;

  // ── Existing: paginated fetch via Edge Function ───────────────────────────
  Future<WardrobeItems> fetchPage({String? cursor}) async {
    final response = await _supabase.functions.invoke(
      'get-wardrobe',
      method: HttpMethod.get,
      queryParameters: cursor != null ? {'cursor': cursor} : {},
    );

    if (response.data == null) {
      throw Exception('Failed to fetch wardrobe: empty response');
    }

    final json = response.data as Map;
    final rawItems = json['items'] as List? ?? [];
    final items = rawItems.map((i) => WardrobeClothingItem.fromJson(i as Map));

    return WardrobeItems(
      items: items.toList(),
      hasMore: json['hasMore'] as bool? ?? false,
      cursor: json['cursor'] as String?,
    );
  }

  // ── NEW: fetch all items with optional Dart-side tag filtering ────────────
  Future<List<WardrobeClothingItem>> fetchWardrobeItems({
    List<int> categoryTagIds = const [],
    List<int> colorTagIds = const [],
    List<int> occasionTagIds = const [],
    List<int> weatherTagIds = const [],
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw StateError('User not authenticated');

    // 1. Fetch clothes rows
    final clothesResponse = await _supabase
        .from('clothes')
        .select('id, image_type, cost, times_worn, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final rows = clothesResponse as List;
    if (rows.isEmpty) return [];

    final ids = rows.map((r) => r['id'] as int).toList();

    // 2. Fetch clothes_tags with joined tags
    final tagsResponse = await _supabase
        .from('clothes_tags')
        .select('clothes_id, tags(*)')
        .inFilter('clothes_id', ids);

    final tagsData = tagsResponse as List;

    // 3. Signed URLs
    final paths = rows
        .map((r) => '$userId/${r['id']}.${r['image_type']}')
        .toList();
    final signedResult = await _supabase.storage
        .from('clothes_photos')
        .createSignedUrls(paths, 3600);

    final urlMap = <String, String>{};
    for (final s in signedResult) {
      if (s.signedUrl != null) urlMap[s.path] = s.signedUrl!;
    }

    // 4. Assemble
    final items = rows.map((row) {
      final itemId = row['id'] as int;
      final imageType = row['image_type'] as String? ?? 'png';
      final path = '$userId/$itemId.$imageType';

      final rawTagRows = tagsData
          .where((x) => x['clothes_id'] == itemId)
          .expand((x) {
            final t = x['tags'];
            if (t == null) return <Map>[];
            if (t is List) return t.cast<Map>();
            return [t as Map];
          })
          .toList();

      final tags = rawTagRows
          .map(
            (t) => ClothingTag(
              id: (t['id'] as num).toInt(),
              tagType: (t['tag_type'] as String?) ?? '',
              tagValue: (t['tag_value'] as String?) ?? '',
              tagDisplayName: (t['tag_display_name'] as String?) ?? '',
            ),
          )
          .toList();

      return WardrobeClothingItem(
        id: itemId,
        imageUrl: urlMap[path],
        imageType: imageType,
        cost: (row['cost'] as num? ?? 0).toDouble(),
        timesWorn: (row['times_worn'] as num? ?? 0).toInt(),
        createdAt: row['created_at'] as String,
        tags: tags,
      );
    }).toList();

    // 5. Dart-side filter
    return _applyTagFilters(
      items,
      categoryTagIds: categoryTagIds,
      colorTagIds: colorTagIds,
      occasionTagIds: occasionTagIds,
      weatherTagIds: weatherTagIds,
    );
  }

  List<WardrobeClothingItem> _applyTagFilters(
    List<WardrobeClothingItem> items, {
    required List<int> categoryTagIds,
    required List<int> colorTagIds,
    required List<int> occasionTagIds,
    required List<int> weatherTagIds,
  }) {
    if (categoryTagIds.isEmpty &&
        colorTagIds.isEmpty &&
        occasionTagIds.isEmpty &&
        weatherTagIds.isEmpty)
      return items;

    return items.where((item) {
      final tagIds = item.tags.map((t) => t.id).toSet();
      if (categoryTagIds.isNotEmpty &&
          !categoryTagIds.any((id) => tagIds.contains(id)))
        return false;
      if (colorTagIds.isNotEmpty &&
          !colorTagIds.any((id) => tagIds.contains(id)))
        return false;
      if (occasionTagIds.isNotEmpty &&
          !occasionTagIds.any((id) => tagIds.contains(id)))
        return false;
      if (weatherTagIds.isNotEmpty &&
          !weatherTagIds.any((id) => tagIds.contains(id)))
        return false;
      return true;
    }).toList();
  }

  // ── NEW: Fetch single clothing item detail ────────────────────────────────
  Future<WardrobeClothingItem?> fetchClothingDetail(int clothesId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw StateError('User not authenticated');

    final clothesResponse = await _supabase
        .from('clothes')
        .select('id, image_type, cost, times_worn, created_at, user_id')
        .eq('id', clothesId)
        .eq('user_id', userId)
        .limit(1);

    final rows = clothesResponse as List;
    if (rows.isEmpty) return null;

    final row = rows[0] as Map;
    final imageType = row['image_type'] as String? ?? 'png';
    final path = '$userId/$clothesId.$imageType';

    // Fetch tags
    final tagsResponse = await _supabase
        .from('clothes_tags')
        .select('clothes_id, tags(*)')
        .eq('clothes_id', clothesId);

    final tagsData = tagsResponse as List;

    final rawTagRows = tagsData.expand((x) {
      final t = x['tags'];
      if (t == null) return <Map>[];
      if (t is List) return t.cast<Map>();
      return [t as Map];
    }).toList();

    final tags = rawTagRows
        .map(
          (t) => ClothingTag(
            id: (t['id'] as num).toInt(),
            tagType: (t['tag_type'] as String?) ?? '',
            tagValue: (t['tag_value'] as String?) ?? '',
            tagDisplayName: (t['tag_display_name'] as String?) ?? '',
          ),
        )
        .toList();

    // Signed URL
    final signedResult = await _supabase.storage
        .from('clothes_photos')
        .createSignedUrls([path], 3600);

    final imageUrl = signedResult
        .where((s) => s.signedUrl != null)
        .map((s) => s.signedUrl!)
        .firstOrNull;

    return WardrobeClothingItem(
      id: clothesId,
      imageUrl: imageUrl,
      imageType: imageType,
      cost: (row['cost'] as num? ?? 0).toDouble(),
      timesWorn: (row['times_worn'] as num? ?? 0).toInt(),
      createdAt: row['created_at'] as String,
      tags: tags,
    );
  }

  // ── NEW: Delete a clothing item ───────────────────────────────────────────
  Future<void> deleteClothingItem(int clothesId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw StateError('User not authenticated');

    // Verify ownership
    final checkResponse = await _supabase
        .from('clothes')
        .select('id, image_type')
        .eq('id', clothesId)
        .eq('user_id', userId)
        .limit(1);

    final rows = checkResponse as List;
    if (rows.isEmpty) {
      throw Exception('Item not found or not owned by current user');
    }

    final row = rows[0] as Map;
    final imageType = row['image_type'] as String? ?? 'png';

    // 1. Delete clothes_tags
    await _supabase.from('clothes_tags').delete().eq('clothes_id', clothesId);

    // 2. Delete clothes row
    await _supabase
        .from('clothes')
        .delete()
        .eq('id', clothesId)
        .eq('user_id', userId);

    // 3. Best-effort storage delete — non-fatal
    try {
      final path = '$userId/$clothesId.$imageType';
      await _supabase.storage.from('clothes_photos').remove([path]);
    } catch (e) {
      debugPrint('deleteClothingItem: storage delete failed (non-fatal): $e');
    }
  }
}
