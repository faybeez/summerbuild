// lib/features/outfit_creator/models/outfit_generation_request.dart

import '../../../data/wardrobe_repository.dart';

class OutfitGenerationRequest {
  final String occasion;
  final String weather;
  final String? colorPreference;
  final String? vibe;
  final WardrobeClothingItem? mustIncludeItem;

  const OutfitGenerationRequest({
    required this.occasion,
    required this.weather,
    this.colorPreference,
    this.vibe,
    this.mustIncludeItem,
  });

  Map<String, dynamic> toJson() => {
    'occasion': occasion,
    'weather': weather,
    if (colorPreference != null) 'colorPreference': colorPreference,
    if (vibe != null) 'vibe': vibe,
    if (mustIncludeItem != null) 'mustIncludeItemId': mustIncludeItem!.id,
  };
}
