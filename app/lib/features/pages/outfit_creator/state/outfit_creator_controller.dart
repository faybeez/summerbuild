// lib/features/outfit_creator/state/outfit_creator_controller.dart

import 'package:flutter/foundation.dart';

import '../../../data/wardrobe_repository.dart';
import '../data/outfit_generator_service.dart';
import '../models/outfit_generation_request.dart';
import '../models/outfit_suggestion.dart';

enum OutfitCreatorStatus {
  idle,
  loading,
  success,
  empty,
  insufficientWardrobe,
  error,
}

class OutfitCreatorController extends ChangeNotifier {
  OutfitCreatorController({required this.generatorService});

  final OutfitGeneratorService generatorService;

  // ── Form state ─────────────────────────────────────────────────────────────
  String occasion = 'CASUAL';
  String weather = 'MILD';
  String? colorPreference;
  String? vibe;
  WardrobeClothingItem? mustIncludeItem;

  // ── Result state ───────────────────────────────────────────────────────────
  OutfitCreatorStatus status = OutfitCreatorStatus.idle;
  List<OutfitSuggestion> suggestions = [];
  String? errorMessage;

  // ── Setters ────────────────────────────────────────────────────────────────
  void setOccasion(String v) {
    occasion = v;
    notifyListeners();
  }

  void setWeather(String v) {
    weather = v;
    notifyListeners();
  }

  void setColorPreference(String? v) {
    colorPreference = v;
    notifyListeners();
  }

  void setVibe(String? v) {
    vibe = v;
    notifyListeners();
  }

  void setMustIncludeItem(WardrobeClothingItem? item) {
    mustIncludeItem = item;
    notifyListeners();
  }

  // ── Generation ─────────────────────────────────────────────────────────────
  Future<void> generate() async {
    status = OutfitCreatorStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final request = OutfitGenerationRequest(
        occasion: occasion,
        weather: weather,
        colorPreference: colorPreference,
        vibe: vibe,
        mustIncludeItem: mustIncludeItem,
      );

      final results = await generatorService.generateSuggestions(request);

      if (results.isEmpty) {
        // Decide whether it's a wardrobe-size problem or just no matches.
        status = OutfitCreatorStatus.insufficientWardrobe;
      } else {
        suggestions = results;
        status = OutfitCreatorStatus.success;
      }
    } catch (e) {
      errorMessage = e.toString();
      status = OutfitCreatorStatus.error;
    }

    notifyListeners();
  }

  void reset() {
    status = OutfitCreatorStatus.idle;
    suggestions = [];
    errorMessage = null;
    notifyListeners();
  }
}
