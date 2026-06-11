import 'package:supabase_flutter/supabase_flutter.dart';

import '../../classes.dart';

class TagsRepository {
  TagsRepository(this._supabase);

  final SupabaseClient _supabase;

  List<ClothingTag>? _cachedTags;
  Future<List<ClothingTag>>? _inFlightRequest;

  static const Set<String> _allowedTagTypes = {
    'ALL',
    'WEATHER',
    'OCCASION',
    'CATEGORY',
    'COLOR',
  };

  Future<List<ClothingTag>> getTags({
    bool forceRefresh = false,
    String type = 'ALL',
  }) async {
    final normalizedType = type.trim().toUpperCase();

    if (!_allowedTagTypes.contains(normalizedType)) {
      throw ArgumentError(
        'Invalid tag type: $type. Allowed values are: ${_allowedTagTypes.join(', ')}',
      );
    }

    final tags = await _getAllTags(forceRefresh: forceRefresh);

    if (normalizedType == 'ALL') {
      return tags;
    }

    return tags.where((tag) {
      return tag.tagType.trim().toUpperCase() == normalizedType;
    }).toList();
  }

  Future<List<ClothingTag>> _getAllTags({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedTags != null) {
      return _cachedTags!;
    }

    if (!forceRefresh && _inFlightRequest != null) {
      return _inFlightRequest!;
    }

    _inFlightRequest = _fetchTags();

    try {
      final tags = await _inFlightRequest!;
      _cachedTags = tags;
      return tags;
    } finally {
      _inFlightRequest = null;
    }
  }

  Future<List<ClothingTag>> _fetchTags() async {
    final response = await _supabase
        .from('tags')
        .select('id, tag_type, tag_value, tag_display_name')
        .or(
          'created_by.eq.${_supabase.auth.currentUser!.id},created_by.is.null',
        )
        .order('tag_type')
        .order('tag_display_name');

    return (response as List)
        .map((json) => ClothingTag.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  void clearCache() {
    _cachedTags = null;
  }
}
