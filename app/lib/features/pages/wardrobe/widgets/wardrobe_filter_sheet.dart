// lib/features/wardrobe/widgets/wardrobe_filter_sheet.dart
//
// Bottom sheet that shows per-group tag chips.
// Accepts an optional initialGroupIndex to pre-scroll to a group.

import 'package:elytsx/classes/clothing_tag.dart';
import 'package:flutter/material.dart';

import '../../../../app_colors.dart';
import 'wardrobe_filter_bar.dart';

/// Shows the filter bottom sheet.
/// [pending] is a working copy of the selections — caller owns the original.
/// Returns the final selections map when the user taps Apply, or null if dismissed.
Future<Map<String, ClothingTag>?> showWardrobeFilterSheet({
  required BuildContext context,
  required List<FilterGroup> groups,
  required Map<String, ClothingTag> currentSelections,
  int initialGroupIndex = 0,
}) {
  return showModalBottomSheet<Map<String, ClothingTag>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _WardrobeFilterSheet(
      groups: groups,
      initialSelections: currentSelections,
      initialGroupIndex: initialGroupIndex,
    ),
  );
}

// ─── Private sheet widget ────────────────────────────────────────────────────

class _WardrobeFilterSheet extends StatefulWidget {
  const _WardrobeFilterSheet({
    required this.groups,
    required this.initialSelections,
    required this.initialGroupIndex,
  });

  final List<FilterGroup> groups;
  final Map<String, ClothingTag> initialSelections;
  final int initialGroupIndex;

  @override
  State<_WardrobeFilterSheet> createState() => _WardrobeFilterSheetState();
}

class _WardrobeFilterSheetState extends State<_WardrobeFilterSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late Map<String, ClothingTag> _pending;

  @override
  void initState() {
    super.initState();
    _pending = Map.from(widget.initialSelections);
    final safeIndex = widget.initialGroupIndex.clamp(
      0,
      widget.groups.length - 1,
    );
    _tabController = TabController(
      length: widget.groups.length,
      vsync: this,
      initialIndex: safeIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _filterKey(ClothingTag tag) {
    final t = tag.tagType.toUpperCase();
    if (t == 'COLOR' || t == 'MAIN_COLOR' || t == 'SECONDARY_COLOR') {
      return 'color:${tag.tagValue.trim().toLowerCase()}';
    }
    return 'id:${tag.id}';
  }

  int _selectedCountForGroup(FilterGroup group) {
    return group.allTags
        .where((tag) => _pending.containsKey(_filterKey(tag)))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.45,
      builder: (_, scrollController) {
        return Column(
          children: [
            // ── Handle ────────────────────────────────────────────────────
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.appHandleBar,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Filter',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.appEspresso,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _pending.clear()),
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        color: AppColors.appEspresso.withAlpha(160),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.appEspresso,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(_pending),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),

            // ── Tab Bar ───────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.appTan.withAlpha(100)),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.appEspresso,
                unselectedLabelColor: AppColors.appOlive,
                indicatorColor: AppColors.appEspresso,
                indicatorWeight: 2,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                tabs: widget.groups.map((g) {
                  final count = _selectedCountForGroup(g);
                  return Tab(
                    child: Row(
                      children: [
                        Text(g.label),
                        if (count > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.appEspresso,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // ── Tab Content ───────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: widget.groups.map((group) {
                  if (group.allTags.isEmpty) {
                    return Center(
                      child: Text(
                        'No ${group.label.toLowerCase()} options available',
                        style: TextStyle(color: AppColors.appOlive),
                      ),
                    );
                  }

                  return StatefulBuilder(
                    builder: (ctx, setInner) {
                      return ListView(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(
                          20,
                          20,
                          20,
                          20 + bottomPad,
                        ),
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: group.allTags.map((tag) {
                              final key = _filterKey(tag);
                              final selected = _pending.containsKey(key);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    setInner(() {
                                      if (selected) {
                                        _pending.remove(key);
                                      } else {
                                        _pending[key] = tag;
                                      }
                                    });
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.appEspresso
                                        : AppColors.appCard,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.appEspresso
                                          : AppColors.appTan,
                                    ),
                                  ),
                                  child: Text(
                                    tag.tagDisplayName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.appEspresso,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
