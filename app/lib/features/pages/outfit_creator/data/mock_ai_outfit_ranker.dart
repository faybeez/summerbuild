import '../models/outfit_candidate.dart';
import '../models/outfit_generation_request.dart';
import '../models/outfit_suggestion.dart';

const _neutralColors = {
  'BLACK',
  'WHITE',
  'GREY',
  'GRAY',
  'NAVY',
  'BEIGE',
  'BROWN',
  'CREAM',
};

class MockAiOutfitRanker {
  List<OutfitSuggestion> rank(
    List<OutfitCandidate> candidates,
    OutfitGenerationRequest request,
  ) {
    return candidates.map((c) {
      final score = c.rawScore.round().clamp(0, 100);
      return OutfitSuggestion(
        items: c.items,
        score: score,
        reason: _buildReason(c, request),
        stylingTip: _buildStylingTip(c, request),
        confidenceLabel: _confidenceLabel(score),
      );
    }).toList();
  }

  // ── Reason builder ─────────────────────────────────────────────────────────
  String _buildReason(OutfitCandidate c, OutfitGenerationRequest request) {
    final colors = c.items
        .expand((i) => i.tags.where((t) => t.isColorTag))
        .map((t) => t.tagDisplayName)
        .toSet();

    final neutralCount = colors
        .where((col) => _neutralColors.contains(col.toUpperCase()))
        .length;
    final isNeutralHeavy = neutralCount >= colors.length ~/ 2;

    final occasion = request.occasion;
    final weather = request.weather;

    if (isNeutralHeavy) {
      return 'The neutral tones create a clean, versatile palette that works '
          'well for a $occasion occasion in $weather weather.';
    }

    if (colors.length <= 2) {
      return 'A tight color story of ${colors.join(' and ')} keeps this '
          '$occasion look cohesive and intentional.';
    }

    return 'This combination balances your wardrobe pieces for a $occasion '
        'setting while staying appropriate for $weather conditions.';
  }

  // ── Styling tip builder ────────────────────────────────────────────────────
  String _buildStylingTip(OutfitCandidate c, OutfitGenerationRequest request) {
    final hasAccessory = c.items.any(
      (i) => i.category?.tagValue.toUpperCase() == 'ACCESSORIES',
    );
    final hasOuterwear = c.items.any(
      (i) => i.category?.tagValue.toUpperCase() == 'OUTERWEAR',
    );
    final weather = request.weather.toUpperCase();

    if (hasOuterwear &&
        (weather == 'COLD' || weather == 'RAINY' || weather == 'WINDY')) {
      return 'Keep the outerwear on for warmth — or tie it around your waist '
          'for an effortless layered look when you move indoors.';
    }

    if (hasAccessory) {
      return 'Let the accessory be the statement piece — keep everything else '
          'understated so it takes centre stage.';
    }

    if (request.vibe?.toUpperCase() == 'CASUAL') {
      return 'Roll up the sleeves and tuck in loosely for a relaxed, '
          'put-together feel without trying too hard.';
    }

    return 'Finish with a minimal bag and clean footwear to elevate the '
        'overall look without overcrowding the palette.';
  }

  // ── Confidence label ───────────────────────────────────────────────────────
  String _confidenceLabel(int score) {
    if (score >= 75) return 'Great Match';
    if (score >= 50) return 'Good Match';
    return 'Fair Match';
  }
}
