// lib/features/wardrobe/widgets/wardrobe_filter_bar.dart
//
// Compact horizontal chip row that summarises active filters.
// Tapping a chip opens the WardrobeFilterSheet for that group.
// Tapping the main "Filters" icon opens the sheet for all groups.

import 'package:elytsx/classes/clothing_tag.dart';
import 'package:flutter/material.dart';

import '../../../../app_colors.dart';

/// One filter group summary:  label + list of selected tags.
class FilterGroup {
  final String label; // e.g. "Category"
  final String tagType; // e.g. "CATEGORY"
  final List<ClothingTag> allTags;
  final List<ClothingTag> selected;

  const FilterGroup({
    required this.label,
    required this.tagType,
    required this.allTags,
    required this.selected,
  });

  String get chipLabel {
    if (selected.isEmpty) return label;
    if (selected.length == 1) return selected.first.tagDisplayName;
    return '$label +${selected.length}';
  }

  bool get hasSelection => selected.isNotEmpty;
}

class WardrobeFilterBar extends StatelessWidget {
  const WardrobeFilterBar({
    super.key,
    required this.groups,
    required this.onGroupTap,
    required this.onClearAll,
  });

  final List<FilterGroup> groups;

  /// Called with the index of the tapped group (or -1 for "all").
  final void Function(int groupIndex) onGroupTap;
  final VoidCallback onClearAll;

  bool get _hasAny => groups.any((g) => g.hasSelection);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // ── All-filters icon chip ──────────────────────────────────────
          _FilterIconChip(active: _hasAny, onTap: () => onGroupTap(-1)),
          const SizedBox(width: 8),

          // ── Per-group summary chips ────────────────────────────────────
          ...groups.asMap().entries.map((entry) {
            final i = entry.key;
            final g = entry.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _GroupChip(
                group: g,
                onTap: () => onGroupTap(i),
                onRemove: g.hasSelection ? onClearAll : null,
              ),
            );
          }),

          // ── Clear all link ─────────────────────────────────────────────
          if (_hasAny)
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onClearAll,
                child: Text(
                  'Clear all',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.appEspresso.withAlpha(160),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Private sub-widgets ──────────────────────────────────────────────────────

class _FilterIconChip extends StatelessWidget {
  const _FilterIconChip({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.appEspresso : AppColors.appCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.appEspresso : AppColors.appTan,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 14,
              color: active ? Colors.white : AppColors.appEspresso,
            ),
            if (active) ...[
              const SizedBox(width: 4),
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.appEspresso,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  const _GroupChip({required this.group, required this.onTap, this.onRemove});

  final FilterGroup group;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final active = group.hasSelection;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: 12,
          right: active ? 4 : 12,
          top: 6,
          bottom: 6,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.appChipBg : AppColors.appCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.appTerracotta : AppColors.appTan,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              group.chipLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active
                    ? AppColors.appTerracotta
                    : AppColors.appEspresso.withAlpha(180),
              ),
            ),
            // small chevron / count badge
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: active
                  ? AppColors.appTerracotta
                  : AppColors.appEspresso.withAlpha(120),
            ),
          ],
        ),
      ),
    );
  }
}
