import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_colors.dart';

Future<List<String>> getClothesCategories() async {
  final data = await Supabase.instance.client
      .from('tags')
      .select('tag_name')
      .eq('tag_type', 'Clothes Type');

  final categories = (data as List)
      .map((item) => item['tag_name'] as String)
      .toList();

  return ['All', ...categories];
}

Future<List<String>> getClothesOccasions() async {
  final data = await Supabase.instance.client
      .from('tags')
      .select('tag_name')
      .eq('tag_type', 'Occasion');

  final categories = (data as List)
      .map((item) => item['tag_name'] as String)
      .toList();

  return ['All', ...categories];
}

Future<List<String>> getWeatherTypes() async {
  final data = await Supabase.instance.client
      .from('tags')
      .select('tag_name')
      .eq('tag_type', 'Weather Fit');

  final categories = (data as List)
      .map((item) => item['tag_name'] as String)
      .toList();

  return ['All', ...categories];
}

Future<List<String>> getColors() async {
  final data = await Supabase.instance.client
      .from('tags')
      .select('tag_name')
      .eq('tag_type', 'Colors');

  final categories = (data as List)
      .map((item) => item['tag_name'] as String)
      .toList();

  return ['All', ...categories];
}

BoxDecoration cardDecoration(Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: const Color(0xFFF3E3CC)),
    boxShadow: [
      BoxShadow(
        color: AppColors.appTan.withAlpha(35),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
