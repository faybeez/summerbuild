import '../../../data/wardrobe_repository.dart';

/// A raw outfit candidate produced by the generator before AI ranking.
class OutfitCandidate {
  final List<WardrobeClothingItem> items;
  final double rawScore;

  const OutfitCandidate({required this.items, required this.rawScore});
}
