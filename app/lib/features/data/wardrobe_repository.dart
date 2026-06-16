import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../../../supabase_config.dart';

import '../../classes.dart';

class WardrobeClothingItem {
  final int id;
  final String? imageUrl;
  final double cost;
  final int timesWorn;
  final String createdAt;
  final List<ClothingTag> tags;

  const WardrobeClothingItem({
    required this.id,
    required this.imageUrl,
    required this.cost,
    required this.timesWorn,
    required this.createdAt,
    required this.tags,
  });

  factory WardrobeClothingItem.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing WardrobeClothingItem from JSON: $json');
    final rawTags = json['tags'] as List<dynamic>? ?? [];

    debugPrint('Raw tags data: $rawTags');
    return WardrobeClothingItem(
      id: (json['id'] as num).toInt(),
      imageUrl: (json['imageUrl'] as String?),
      cost: (json['cost'] as num? ?? 0).toDouble(),
      timesWorn: (json['timesWorn'] as num? ?? 0).toInt(),
      createdAt: json['createdAt'] as String,
      tags: rawTags.map((t) {
        final map = t as Map<String, dynamic>;
        return ClothingTag(
          id: (map['id'] as num).toInt(),
          tagType: (map['tag_type'] as String?) ?? '',
          tagValue: (map['tag_name'] as String?) ?? '',
          tagDisplayName: (map['tag_name'] as String?) ?? '',
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
      tags.where((t) => t.tagType.toUpperCase() == 'CLOTHES TYPE').firstOrNull;
}

class WardrobePage {
  final List<WardrobeClothingItem> items;
  final bool hasMore;
  final String? cursor;

  const WardrobePage({
    required this.items,
    required this.hasMore,
    required this.cursor,
  });
}

class WardrobeRepository {
  WardrobeRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<WardrobePage> fetchPage({String? cursor}) async {
    final response = await _supabase.functions.invoke(
      'get-wardrobe',
      method: HttpMethod.get,
      queryParameters: cursor != null ? {'cursor': cursor} : {},
    );

    if (response.data == null) {
      throw Exception('Failed to fetch wardrobe: empty response');
    }

    final json = response.data as Map<String, dynamic>;
    debugPrint('get-wardrobe response: $json');
    debugPrint('get-wardrobe items: ${json["items"].runtimeType}');

    final rawItems = json['items'] as List<dynamic>? ?? [];

    debugPrint('get-wardrobe raw items count: ${rawItems.length}');

    if (rawItems.isNotEmpty) {
      debugPrint('first item type: ${rawItems.first.runtimeType}');
      debugPrint('first item value: ${rawItems.first}');
    }

    final items = rawItems.map(
      (i) => WardrobeClothingItem.fromJson(i as Map<String, dynamic>),
    );

    debugPrint('Items: ${items}');

    return WardrobePage(
      items: items.toList(),
      hasMore: json['hasMore'] as bool? ?? false,
      cursor: json['cursor'] as String?,
    );
  }
}
