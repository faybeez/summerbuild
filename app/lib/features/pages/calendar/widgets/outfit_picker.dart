import 'package:flutter/material.dart';
import 'package:elytsx/app_colors.dart';
import 'package:elytsx/features/data/outfit_repository.dart';

class OutfitPicker extends StatefulWidget {
  const OutfitPicker({
    super.key,
    required this.outfitRepository,
    this.initialOutfitId,
    required this.onSelected,
  });

  final OutfitRepository outfitRepository;
  final int? initialOutfitId;
  final ValueChanged<OutfitItem?> onSelected;

  @override
  State<OutfitPicker> createState() => _OutfitPickerState();
}

class _OutfitPickerState extends State<OutfitPicker> {
  List<OutfitItem> _items = [];
  bool _loading = true;
  OutfitItem? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await widget.outfitRepository.fetchPage();
      if (mounted) {
        setState(() {
          _items = result.items;
          _loading = false;
          if (widget.initialOutfitId != null) {
            _selected = _items
                .where((i) => i.id == widget.initialOutfitId)
                .firstOrNull;
          }
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
          'No saved outfits yet.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selected != null) ...[_selectedChip(), const SizedBox(height: 8)],
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = _items[index];
              final isSelected = _selected?.id == item.id;
              return GestureDetector(
                onTap: () {
                  setState(() => _selected = isSelected ? null : item);
                  widget.onSelected(isSelected ? null : item);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.appEspresso
                        : AppColors.appChipBg,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.appEspresso
                          : AppColors.border.withOpacity(0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item.name ?? 'Outfit #${item.id}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textMain,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _selectedChip() {
    return Wrap(
      children: [
        Chip(
          label: Text(
            _selected?.name ?? 'Outfit #${_selected?.id}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMain),
          ),
          deleteIcon: const Icon(
            Icons.close,
            size: 14,
            color: AppColors.textMuted,
          ),
          onDeleted: () {
            setState(() => _selected = null);
            widget.onSelected(null);
          },
          backgroundColor: AppColors.appChipBg,
          side: BorderSide(color: AppColors.border.withOpacity(0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ],
    );
  }
}
