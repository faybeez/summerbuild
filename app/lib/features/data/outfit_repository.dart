import 'package:elytsx/classes/clothing_tag.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OutfitClothesItem {
  final int clothesId;
  final String? slot;
  final int sortOrder;
  final String? imageUrl;

  const OutfitClothesItem({
    required this.clothesId,
    required this.slot,
    required this.sortOrder,
    required this.imageUrl,
  });

  factory OutfitClothesItem.fromJson(Map<dynamic, dynamic> json) {
    return OutfitClothesItem(
      clothesId: (json['clothesId'] as num).toInt(),
      slot: json['slot'] as String?,
      sortOrder: (json['sortOrder'] as num? ?? 0).toInt(),
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class OutfitItem {
  final int id;
  final String? name;
  final String? description;
  final int? rating;
  final String createdAt;
  final String? editedAt;
  final List<ClothingTag> tags;
  final List<OutfitClothesItem> clothes;

  const OutfitItem({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.createdAt,
    required this.editedAt,
    required this.tags,
    required this.clothes,
  });

  factory OutfitItem.fromJson(Map<dynamic, dynamic> json) {
    final rawTags = json['tags'] as List? ?? [];
    final rawClothes = json['clothes'] as List? ?? [];

    return OutfitItem(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      rating: (json['rating'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String,
      editedAt: json['editedAt'] as String?,
      tags: rawTags.map((t) {
        final map = t as Map<dynamic, dynamic>;
        return ClothingTag(
          id: (map['id'] as num).toInt(),
          tagType: (map['tag_type'] as String?) ?? '',
          tagValue: (map['tag_value'] as String?) ?? '',
          tagDisplayName: (map['tag_display_name'] as String?) ?? '',
        );
      }).toList(),
      clothes: rawClothes
          .map((c) => OutfitClothesItem.fromJson(c as Map<dynamic, dynamic>))
          .toList(),
    );
  }

  List<String?> get imageUrls => clothes.map((c) => c.imageUrl).toList();
}

class OutfitItems {
  final List<OutfitItem> items;
  final bool hasMore;
  final String? cursor;

  const OutfitItems({
    required this.items,
    required this.hasMore,
    required this.cursor,
  });
}

class OutfitRepository {
  OutfitRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<OutfitItems> fetchPage({String? cursor}) async {
    final response = await _supabase.functions.invoke(
      'get-outfits',
      method: HttpMethod.get,
      queryParameters: cursor != null ? {'cursor': cursor} : {},
    );

    if (response.data == null) {
      throw Exception('Failed to fetch outfits: empty response');
    }

    final json = response.data as Map<dynamic, dynamic>;
    final rawItems = json['items'] as List? ?? [];

    final items = rawItems.map(
      (i) => OutfitItem.fromJson(i as Map<dynamic, dynamic>),
    );

    return OutfitItems(
      items: items.toList(),
      hasMore: json['hasMore'] as bool? ?? false,
      cursor: json['cursor'] as String?,
    );
  }
}
