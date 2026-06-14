import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../classes.dart';
import '../../../data/tags_repository.dart';

class WardrobeAddState {
  File? image;

  List<ClothingTag> mainColors;
  List<ClothingTag> secondaryColors;
  List<ClothingTag> occasion;
  ClothingTag? category;
  List<ClothingTag> weather;

  double cost;
  int timesWorn;

  final TagsRepository tagsRepository;

  WardrobeAddState({
    required this.tagsRepository,
    this.image,
    List<ClothingTag>? mainColors,
    List<ClothingTag>? secondaryColors,
    List<ClothingTag>? occasion,
    this.category,
    this.cost = 0.0,
    this.timesWorn = 0, // <-- new
    List<ClothingTag>? weather,
  }) : mainColors = mainColors ?? [],
       secondaryColors = secondaryColors ?? [],
       occasion = occasion ?? [],
       weather = weather ?? [];

  /// Parses the new edge function response shape:
  /// {
  ///   "mainColors":      [ { "id", "tagType", "tagValue", "tagDisplayName" }, ... ],
  ///   "secondaryColors": [ ... ],
  ///   "occasion":        [ ... ],
  ///   "weather":         [ ... ],
  ///   "category":        { "id", "tagType", "tagValue", "tagDisplayName" } | null
  /// }
  void applyFromEdgeFunction(Map<String, dynamic> json) {
    debugPrint('Applying Edge Function Data: $json');

    try {
      mainColors = _parseTagList(json['mainColors']);
      secondaryColors = _parseTagList(json['secondaryColors']);
      occasion = _parseTagList(json['occasion']);
      weather = _parseTagList(json['weather']);

      final rawCategory = json['category'];
      category = rawCategory != null
          ? ClothingTag.fromJson(rawCategory as Map<String, dynamic>)
          : null;

      debugPrint(
        'Applied Edge Function Data: mainColors=$mainColors, '
        'secondaryColors=$secondaryColors, occasion=$occasion, '
        'category=$category, weather=$weather',
      );
    } catch (e) {
      debugPrint('Error in applyFromEdgeFunction: $e');
    }
  }

  List<ClothingTag> _parseTagList(dynamic raw) {
    if (raw == null) return [];
    return (raw as List<dynamic>)
        .map((t) => ClothingTag.fromJson(t as Map<String, dynamic>))
        .where((t) => t.tagType.isNotEmpty && t.tagValue.isNotEmpty)
        .toList();
  }

  bool get isReadyToSave => image != null && category != null;
}
