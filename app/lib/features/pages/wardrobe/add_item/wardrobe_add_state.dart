import 'dart:io';
import 'package:flutter/material.dart';

class WardrobeAddState {
  File? image;

  List<String> mainColors;
  List<String> secondaryColors;
  List<String> occasion;
  String? category;
  List<String> weather;

  WardrobeAddState({
    this.image,
    List<String>? mainColors,
    List<String>? secondaryColors,
    List<String>? occasion,
    this.category = '',
    List<String>? weather,
  }) : mainColors = mainColors ?? [],
       secondaryColors = secondaryColors ?? [],
       occasion = occasion ?? [],
       weather = weather ?? [];

  void applyFromEdgeFunction(Map<String, dynamic> json) {
    debugPrint('Applying Edge Function Data: $json');
    mainColors = List<String>.from(json['main_colors'] ?? []);
    secondaryColors = List<String>.from(json['secondary_colors'] ?? []);
    occasion = List<String>.from(json['occasion'] ?? []);
    category = json['category'] as String?;
    weather = List<String>.from(json['weather'] ?? []);

    debugPrint(
      'Applied Edge Function Data: mainColors=$mainColors, secondaryColors=$secondaryColors, occasion=$occasion, category=$category, weather=$weather',
    );
  }

  bool get isReadyToSave =>
      image != null && (category != null && category!.isNotEmpty);
}
