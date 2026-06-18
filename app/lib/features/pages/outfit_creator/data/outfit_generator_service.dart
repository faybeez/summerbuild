// lib/features/outfit_creator/data/outfit_generator_service.dart
//
// Responsibilities:
//   1. Fetch all wardrobe items (paginated).
//   2. Build outfit candidates from valid templates.
//   3. Score each candidate.
//   4. Hand the top N candidates to the AI ranker.
//
// To connect a real Supabase Edge Function later, replace the
// MockAiOutfitRanker call in generateSuggestions() with a
// SupabaseAiOutfitRanker that POSTs to your function.

import 'dart:math';

import '../../../data/wardrobe_repository.dart';
import '../models/outfit_candidate.dart';
import '../models/outfit_generation_request.dart';
import '../models/outfit_suggestion.dart';
import 'mock_ai_outfit_ranker.dart';

// ── Scoring weights (must sum to 100) ──────────────────────────────────────
const _wOccasion = 25;
const _wWeather = 20;
const _wColorHarmony = 20;
const _wVibe = 15;
const _wCompleteness = 15;
const _wIncludedItem = 5;

// ── Neutral color values ────────────────────────────────────────────────────
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

// ── Valid outfit templates (category values as uppercase strings) ───────────
const _templates = [
  ['TOPS', 'PANTS', 'SHOES'],
  ['TOPS', 'PANTS', 'OUTERWEAR', 'SHOES'],
  ['DRESSES', 'SHOES'],
  ['DRESSES', 'OUTERWEAR', 'SHOES'],
  ['TOPS', 'PANTS', 'SHOES', 'ACCESSORIES'],
  ['DRESSES', 'SHOES', 'ACCESSORIES'],
];

class OutfitGeneratorService {
  OutfitGeneratorService({
    required this.wardrobeRepository,
    MockAiOutfitRanker? ranker,
  }) : _ranker = ranker ?? MockAiOutfitRanker();

  final WardrobeRepository wardrobeRepository;
  final MockAiOutfitRanker _ranker;

  // ── Public API ─────────────────────────────────────────────────────────────
  Future<List<OutfitSuggestion>> generateSuggestions(
    OutfitGenerationRequest request,
  ) async {
    final allItems = await _fetchAllItems();

    if (allItems.isEmpty) return [];

    final candidates = _buildCandidates(allItems, request);
    if (candidates.isEmpty) return [];

    final scored =
        candidates.map((c) => _ScoredCandidate(c, _score(c, request))).toList()
          ..sort((a, b) => b.score.compareTo(a.score));

    final top3 = scored.take(3).toList();

    return _ranker.rank(
      top3
          .map(
            (s) => OutfitCandidate(items: s.candidate.items, rawScore: s.score),
          )
          .toList(),
      request,
    );
  }

  // ── Wardrobe fetching ──────────────────────────────────────────────────────
  Future<List<WardrobeClothingItem>> _fetchAllItems() async {
    final List<WardrobeClothingItem> all = [];
    String? cursor;
    do {
      final page = await wardrobeRepository.fetchPage(cursor: cursor);
      all.addAll(page.items);
      cursor = page.hasMore ? page.cursor : null;
    } while (cursor != null);
    return all;
  }

  // ── Candidate builder ──────────────────────────────────────────────────────
  List<_RawCandidate> _buildCandidates(
    List<WardrobeClothingItem> allItems,
    OutfitGenerationRequest request,
  ) {
    // Group items by their normalised category value.
    final Map<String, List<WardrobeClothingItem>> byCategory = {};
    for (final item in allItems) {
      final cat = item.category?.tagValue.trim().toUpperCase();
      if (cat != null) {
        byCategory.putIfAbsent(cat, () => []).add(item);
      }
    }

    final List<_RawCandidate> candidates = [];
    final rng = Random();

    for (final template in _templates) {
      // Check that every required category has at least one item.
      final isAccessoryTemplate = template.contains('ACCESSORIES');
      final requiredCats = isAccessoryTemplate
          ? template.where((c) => c != 'ACCESSORIES').toList()
          : template;

      if (requiredCats.any((c) => (byCategory[c]?.isEmpty ?? true))) continue;

      // Build up to 6 combos per template by sampling randomly.
      for (var attempt = 0; attempt < 6; attempt++) {
        final items = <WardrobeClothingItem>[];

        bool ok = true;
        for (final cat in template) {
          final pool = byCategory[cat];
          if (pool == null || pool.isEmpty) {
            if (cat == 'ACCESSORIES') continue; // optional
            ok = false;
            break;
          }
          // Honour mustIncludeItem in the correct slot.
          if (request.mustIncludeItem != null &&
              request.mustIncludeItem!.category?.tagValue
                      .trim()
                      .toUpperCase() ==
                  cat) {
            items.add(request.mustIncludeItem!);
          } else {
            items.add(pool[rng.nextInt(pool.length)]);
          }
        }

        if (!ok) continue;

        // Deduplicate item IDs within one outfit.
        final ids = items.map((i) => i.id).toSet();
        if (ids.length != items.length) continue;

        candidates.add(_RawCandidate(items));
      }
    }

    // Deduplicate candidates by their item-ID set.
    final seen = <String>{};
    return candidates.where((c) {
      final key = (c.items.map((i) => i.id).toList()..sort()).join(',');
      return seen.add(key);
    }).toList();
  }

  // ── Scorer ─────────────────────────────────────────────────────────────────
  double _score(_RawCandidate candidate, OutfitGenerationRequest request) {
    double total = 0;

    total += _scoreOccasion(candidate, request.occasion) * _wOccasion / 100;
    total += _scoreWeather(candidate, request.weather) * _wWeather / 100;
    total += _scoreColorHarmony(candidate) * _wColorHarmony / 100;
    total += _scoreVibe(candidate, request.vibe) * _wVibe / 100;
    total += _scoreCompleteness(candidate) * _wCompleteness / 100;
    total +=
        _scoreIncludedItem(candidate, request.mustIncludeItem) *
        _wIncludedItem /
        100;

    return total.clamp(0, 100);
  }

  double _scoreOccasion(_RawCandidate c, String occasion) {
    final occ = occasion.trim().toUpperCase();
    int matches = 0;
    for (final item in c.items) {
      if (item.tags.any(
        (t) =>
            t.tagType.toUpperCase() == 'OCCASION' &&
            t.tagValue.trim().toUpperCase() == occ,
      )) {
        matches++;
      }
    }
    return matches == 0 ? 0 : (matches / c.items.length * 100).clamp(0, 100);
  }

  double _scoreWeather(_RawCandidate c, String weather) {
    final w = weather.trim().toUpperCase();
    int matches = 0;
    for (final item in c.items) {
      if (item.tags.any(
        (t) =>
            t.tagType.toUpperCase() == 'WEATHER' &&
            t.tagValue.trim().toUpperCase() == w,
      )) {
        matches++;
      }
    }
    return matches == 0 ? 0 : (matches / c.items.length * 100).clamp(0, 100);
  }

  double _scoreColorHarmony(_RawCandidate c) {
    final colors = <String>{};
    for (final item in c.items) {
      for (final tag in item.tags) {
        if (tag.isColorTag) colors.add(tag.tagValue.trim().toUpperCase());
      }
    }
    if (colors.isEmpty) return 50; // no color data — neutral score

    final strongColors = colors
        .where((col) => !_neutralColors.contains(col))
        .length;
    // Ideal: 1–3 total colors, ≤1 strong
    if (colors.length <= 3 && strongColors <= 1) return 100;
    if (colors.length <= 3 && strongColors <= 2) return 75;
    if (colors.length <= 4 && strongColors <= 2) return 55;
    return max(0, 55 - (strongColors - 2) * 15).toDouble();
  }

  double _scoreVibe(_RawCandidate c, String? vibe) {
    if (vibe == null || vibe.isEmpty) return 50; // not specified — neutral
    final v = vibe.trim().toUpperCase();
    int matches = 0;
    for (final item in c.items) {
      if (item.tags.any(
        (t) =>
            t.tagType.toUpperCase() == 'OCCASION' &&
            t.tagValue.trim().toUpperCase() == v,
      )) {
        matches++;
      }
    }
    return matches == 0 ? 20 : (matches / c.items.length * 100).clamp(0, 100);
  }

  double _scoreCompleteness(_RawCandidate c) {
    final cats = c.items
        .map((i) => i.category?.tagValue.trim().toUpperCase())
        .whereType<String>()
        .toSet();
    // Bonus for having both top/dress + shoes
    final hasFootwear = cats.contains('SHOES');
    final hasTorso = cats.contains('TOPS') || cats.contains('DRESSES');
    if (hasFootwear && hasTorso && cats.length >= 2) return 100;
    if (hasFootwear || hasTorso) return 60;
    return 20;
  }

  double _scoreIncludedItem(
    _RawCandidate c,
    WardrobeClothingItem? mustInclude,
  ) {
    if (mustInclude == null) return 50;
    return c.items.any((i) => i.id == mustInclude.id) ? 100 : 0;
  }
}

class _RawCandidate {
  final List<WardrobeClothingItem> items;
  const _RawCandidate(this.items);
}

class _ScoredCandidate {
  final _RawCandidate candidate;
  final double score;
  const _ScoredCandidate(this.candidate, this.score);
}
