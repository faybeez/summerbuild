import 'package:flutter/material.dart';
import 'package:elytsx/app_colors.dart';
import 'package:elytsx/features/data/wardrobe_repository.dart';

class WardrobePiecePicker extends StatefulWidget {
  const WardrobePiecePicker({
    super.key,
    required this.wardrobeRepository,
    this.initialSelectedIds = const [],
    required this.onSelectionChanged,
  });

  final WardrobeRepository wardrobeRepository;
  final List<int> initialSelectedIds;
  final ValueChanged<List<WardrobeClothingItem>> onSelectionChanged;

  @override
  State<WardrobePiecePicker> createState() => _WardrobePiecePickerState();
}

class _WardrobePiecePickerState extends State<WardrobePiecePicker> {
  List<WardrobeClothingItem> _items = [];
  Set<int> _selectedIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.initialSelectedIds.toSet();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await widget.wardrobeRepository.fetchWardrobeItems();
      if (mounted) {
        setState(() {
          _items = items;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No wardrobe items yet.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _items.map((item) {
        final isSelected = _selectedIds.contains(item.id);
        final label = item.category?.tagDisplayName ?? 'Item #${item.id}';
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedIds.remove(item.id);
              } else {
                _selectedIds.add(item.id);
              }
            });
            final selected = _items
                .where((i) => _selectedIds.contains(i.id))
                .toList();
            widget.onSelectionChanged(selected);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.appEspresso : AppColors.appChipBg,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isSelected
                    ? AppColors.appEspresso
                    : AppColors.border.withOpacity(0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.imageUrl!,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const SizedBox(width: 24, height: 24),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
