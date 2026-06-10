import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app_colors.dart';
import '../../../classes.dart';
import '../../../functions.dart';

import 'wardrobe_detail_page.dart';
import 'add_item_page.dart';

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key});

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  final _allItems = <WardrobeItem>[
    const WardrobeItem(
      'Silk blouse',
      'Tops',
      AppColors.appPeach,
      Icons.dry_cleaning,
      subColor: AppColors.appWarmCream,
    ),
    const WardrobeItem(
      'Wide-leg jeans',
      'Bottoms',
      AppColors.appOlive,
      Icons.style,
      subColor: AppColors.appTan,
    ),
    const WardrobeItem(
      'Trench coat',
      'Outerwear',
      AppColors.appWarmCream,
      Icons.layers,
      subColor: AppColors.appCard,
    ),
    const WardrobeItem(
      'Loafers',
      'Shoes',
      AppColors.appEspresso,
      Icons.ice_skating,
      subColor: AppColors.appCream,
    ),
    const WardrobeItem(
      'Midi dress',
      'Dresses',
      AppColors.appTerracotta,
      Icons.woman,
      subColor: AppColors.appPeach,
    ),
    const WardrobeItem(
      'Tote bag',
      'Accessories',
      AppColors.appTan,
      Icons.work_outline,
      subColor: AppColors.appOlive,
    ),
  ];

  static const _categories = [
    'All',
    'Tops',
    'Bottoms',
    'Outerwear',
    'Shoes',
    'Dresses',
    'Accessories',
  ];

  String _selectedCategory = 'All';

  List<WardrobeItem> get _filteredItems => _selectedCategory == 'All'
      ? _allItems
      : _allItems.where((i) => i.category == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return AppPage(
      title: 'Wardrobe',
      subtitle: '${filtered.length} saved pieces',
      trailing: IconButton.filledTonal(
        onPressed: () async {
          final item = await Navigator.of(context).push<WardrobeItem>(
            MaterialPageRoute(builder: (_) => const AddItemPage()),
          );
          if (item != null && mounted) {
            setState(() => _allItems.add(item));
          }
        },
        icon: const Icon(Icons.add),
      ),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final selected = _selectedCategory == category;
            return FilterChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) {
                setState(() => _selectedCategory = category);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          itemCount: filtered.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.82,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemBuilder: (context, index) => WardrobeTile(
            item: filtered[index],
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WardrobeDetailPage(item: filtered[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class WardrobeTile extends StatelessWidget {
  const WardrobeTile({required this.item, this.onTap, super.key});

  final WardrobeItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: cardDecoration(AppColors.appCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: item.color.withAlpha(46),
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: item.imagePath != null
                    ? Image.file(
                        File(item.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Icon(item.icon, size: 46, color: item.color),
                      )
                    : Icon(item.icon, size: 46, color: item.color),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              item.category,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.appEspresso.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
