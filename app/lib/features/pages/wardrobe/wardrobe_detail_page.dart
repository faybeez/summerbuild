import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app_colors.dart';
import '../../../classes.dart';
import '../../../functions.dart';

class WardrobeDetailPage extends StatelessWidget {
  const WardrobeDetailPage({required this.item, super.key});

  final WardrobeItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                color: item.color.withAlpha(46),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: item.imagePath != null
                  ? Image.file(
                      File(item.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Icon(item.icon, size: 80, color: item.color),
                    )
                  : Icon(item.icon, size: 80, color: item.color),
            ),
            const SizedBox(height: 20),
            Text(
              item.name,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              item.category,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.appEspresso.withAlpha(150),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _ColorSwatch(
                    label: 'Primary colour',
                    color: item.color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _ColorSwatch(
                    label: 'Sub colour',
                    color: item.subColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color, required this.label});

  final Color? color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(AppColors.appCard),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color ?? Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.appTan),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.appEspresso.withAlpha(150),
                  ),
                ),
                Text(
                  color != null
                      ? '#${(color!.r * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}${(color!.g * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}${(color!.b * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}'
                      : 'None',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
