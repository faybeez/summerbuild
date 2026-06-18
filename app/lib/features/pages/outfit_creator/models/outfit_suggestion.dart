// lib/features/outfit_creator/models/outfit_suggestion.dart
import '../../../data/wardrobe_repository.dart';

/// A ranked outfit suggestion ready to display to the user.
class OutfitSuggestion {
  final List<WardrobeClothingItem> items;
  final int score; // 0–100
  final String reason;
  final String stylingTip;
  final String confidenceLabel; // 'Great Match' | 'Good Match' | 'Fair Match'

  const OutfitSuggestion({
    required this.items,
    required this.score,
    required this.reason,
    required this.stylingTip,
    required this.confidenceLabel,
  });
}
