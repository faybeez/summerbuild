import 'package:elytsx/classes/clothing_tag.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app_colors.dart';
import '../../../data/wardrobe_repository.dart';
import '../../../data/tags_repository.dart';

class ManualBuildPage extends StatefulWidget {
  const ManualBuildPage({
    super.key,
    required this.wardrobeRepository,
    required this.tagsRepository,
  });

  final WardrobeRepository wardrobeRepository;
  final TagsRepository tagsRepository;

  @override
  State<ManualBuildPage> createState() => _ManualBuildPageState();
}

class _ManualBuildPageState extends State<ManualBuildPage> {
  List<WardrobeClothingItem> _allItems = [];
  List<WardrobeClothingItem> _selectedItems = [];
  bool _loading = true;
  bool _hasError = false;
  bool _isSaving = false;

  List<ClothingTag> _allTags = [];
  final Map<String, Set<int>> _activeTagIdsByType = {};

  static const List<String> _filterTypes = [
    'CATEGORY',
    'OCCASION',
    'WEATHER',
    'COLOR',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final results = await Future.wait([
        _fetchAllWardrobeItems(),
        widget.tagsRepository.getTags(type: 'ALL'),
      ]);
      setState(() {
        _allItems = results[0] as List<WardrobeClothingItem>;
        _allTags = results[1] as List<ClothingTag>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _loading = false;
      });
    }
  }

  Future<List<WardrobeClothingItem>> _fetchAllWardrobeItems() async {
    final List<WardrobeClothingItem> all = [];
    String? cursor;
    do {
      final page = await widget.wardrobeRepository.fetchPage(cursor: cursor);
      all.addAll(page.items);
      cursor = page.hasMore ? page.cursor : null;
    } while (cursor != null);
    return all;
  }

  List<ClothingTag> _tagsForType(String type) {
    return _allTags.where((t) => t.tagType.toUpperCase() == type).toList();
  }

  Set<int> _activeIdsForType(String type) => _activeTagIdsByType[type] ?? {};

  void _toggleTagValue(String type, ClothingTag tag) {
    setState(() {
      final set = _activeTagIdsByType.putIfAbsent(type, () => {});
      if (set.contains(tag.id)) {
        set.remove(tag.id);
      } else {
        set.add(tag.id);
      }
      if (set.isEmpty) _activeTagIdsByType.remove(type);
    });
  }

  void _clearType(String type) {
    setState(() => _activeTagIdsByType.remove(type));
  }

  void _toggleItem(WardrobeClothingItem item) {
    setState(() {
      if (_selectedItems.any((i) => i.id == item.id)) {
        _selectedItems.removeWhere((i) => i.id == item.id);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  Future<void> _reviewOutfit() async {
    context.go('/studio/add/review', extra: _selectedItems);
  }

  bool get _hasActiveFilters => _activeTagIdsByType.isNotEmpty;

  List<WardrobeClothingItem> get _filteredItems {
    if (!_hasActiveFilters) return _allItems;
    return _allItems.where((item) {
      return _activeTagIdsByType.entries.every((entry) {
        final activeIds = entry.value;
        return item.tags.any((t) => activeIds.contains(t.id));
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textMain,
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Build Outfit',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.appEspresso,
          ),
        ),
        centerTitle: false,
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _selectedItems.isNotEmpty
                ? Padding(
                    key: const ValueKey('review-btn'),
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: _isSaving ? null : _reviewOutfit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.appOlive,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.appCream,
                                ),
                              )
                            : const Text(
                                'Review',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.appCream,
                                ),
                              ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('review-empty')),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _CollagePanel(selectedItems: _selectedItems),
            ),
            Expanded(
              child: _WardrobeSelector(
                loading: _loading,
                hasError: _hasError,
                items: _filteredItems,
                selectedItems: _selectedItems,
                allTags: _allTags,
                filterTypes: _filterTypes,
                activeTagIdsByType: _activeTagIdsByType,
                tagsForType: _tagsForType,
                activeIdsForType: _activeIdsForType,
                onToggleTagValue: _toggleTagValue,
                onClearType: _clearType,
                onItemTap: _toggleItem,
                onRetry: _loadData,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollagePanel extends StatelessWidget {
  final List<WardrobeClothingItem> selectedItems;
  const _CollagePanel({required this.selectedItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.appEspresso.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: selectedItems.isEmpty
          ? _CollagePlaceholder()
          : _CollageGrid(items: selectedItems),
    );
  }
}

class _CollagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 40,
            color: AppColors.appTan,
          ),
          const SizedBox(height: 10),
          Text(
            'Select clothes below to build your outfit',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CollageGrid extends StatelessWidget {
  final List<WardrobeClothingItem> items;
  const _CollageGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final count = items.length;
    if (count == 1) return _cell(items[0].imageUrl);
    if (count == 2) {
      return Row(
        children: [
          Expanded(child: _cell(items[0].imageUrl)),
          const SizedBox(width: 2),
          Expanded(child: _cell(items[1].imageUrl)),
        ],
      );
    }
    if (count == 3) {
      return Row(
        children: [
          Expanded(child: _cell(items[0].imageUrl)),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _cell(items[1].imageUrl)),
                const SizedBox(height: 2),
                Expanded(child: _cell(items[2].imageUrl)),
              ],
            ),
          ),
        ],
      );
    }
    final rows = (count / 2).ceil();
    return Column(
      children: List.generate(rows, (row) {
        final l = row * 2;
        final r = l + 1;
        return Expanded(
          child: Row(
            children: [
              Expanded(child: _cell(l < count ? items[l].imageUrl : null)),
              const SizedBox(width: 2),
              Expanded(child: _cell(r < count ? items[r].imageUrl : null)),
            ],
          ),
        );
      }),
    );
  }

  Widget _cell(String? url) {
    if (url == null) return Container(color: const Color(0xFFE0E0E0));
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => Container(color: const Color(0xFFE0E0E0)),
      errorWidget: (_, __, ___) => Container(
        color: const Color(0xFFE0E0E0),
        child: const Icon(
          Icons.image_not_supported_outlined,
          size: 16,
          color: Color(0xFFBDBDBD),
        ),
      ),
    );
  }
}

class _WardrobeSelector extends StatelessWidget {
  final bool loading;
  final bool hasError;
  final List<WardrobeClothingItem> items;
  final List<WardrobeClothingItem> selectedItems;
  final List<ClothingTag> allTags;
  final List<String> filterTypes;
  final Map<String, Set<int>> activeTagIdsByType;
  final List<ClothingTag> Function(String) tagsForType;
  final Set<int> Function(String) activeIdsForType;
  final void Function(String, ClothingTag) onToggleTagValue;
  final void Function(String) onClearType;
  final void Function(WardrobeClothingItem) onItemTap;
  final VoidCallback onRetry;

  const _WardrobeSelector({
    required this.loading,
    required this.hasError,
    required this.items,
    required this.selectedItems,
    required this.allTags,
    required this.filterTypes,
    required this.activeTagIdsByType,
    required this.tagsForType,
    required this.activeIdsForType,
    required this.onToggleTagValue,
    required this.onClearType,
    required this.onItemTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final showFilters = !loading && !hasError && allTags.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.border.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.appEspresso.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.appHandleBar,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          if (showFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _TagFilterRow(
                filterTypes: filterTypes,
                tagsForType: tagsForType,
                activeIdsForType: activeIdsForType,
                onToggleTagValue: onToggleTagValue,
                onClearType: onClearType,
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: loading
                ? const _WardrobeSkeletonGrid()
                : hasError
                ? _WardrobeErrorState(onRetry: onRetry)
                : items.isEmpty
                ? const _WardrobeEmptyState()
                : _WardrobeItemGrid(
                    items: items,
                    selectedItems: selectedItems,
                    onItemTap: onItemTap,
                  ),
          ),
        ],
      ),
    );
  }
}

class _TagFilterRow extends StatelessWidget {
  final List<String> filterTypes;
  final List<ClothingTag> Function(String) tagsForType;
  final Set<int> Function(String) activeIdsForType;
  final void Function(String, ClothingTag) onToggleTagValue;
  final void Function(String) onClearType;

  const _TagFilterRow({
    required this.filterTypes,
    required this.tagsForType,
    required this.activeIdsForType,
    required this.onToggleTagValue,
    required this.onClearType,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filterTypes.map((type) {
          final tags = tagsForType(type);
          if (tags.isEmpty) return const SizedBox.shrink();
          final activeIds = activeIdsForType(type);
          final isActive = activeIds.isNotEmpty;
          final label = _chipLabel(type, activeIds, tags);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterChip(
              label: label,
              active: isActive,
              onTap: () => _showDropdown(context, type, tags, activeIds),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _chipLabel(String type, Set<int> activeIds, List<ClothingTag> tags) {
    if (activeIds.isEmpty) return _typeDisplayName(type);
    if (activeIds.length == 1) {
      return tags
          .firstWhere((t) => t.id == activeIds.first, orElse: () => tags.first)
          .tagDisplayName;
    }
    final first = tags.firstWhere(
      (t) => t.id == activeIds.first,
      orElse: () => tags.first,
    );
    return '${first.tagDisplayName} +${activeIds.length - 1}';
  }

  String _typeDisplayName(String type) {
    return type[0] + type.substring(1).toLowerCase();
  }

  void _showDropdown(
    BuildContext context,
    String type,
    List<ClothingTag> tags,
    Set<int> activeIds,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _TagDropdownSheet(
        title: _typeDisplayName(type),
        tags: tags,
        activeIds: activeIds,
        onToggle: (tag) => onToggleTagValue(type, tag),
        onClear: () => onClearType(type),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.appOlive : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: active
                ? AppColors.appOlive
                : AppColors.border.withOpacity(0.6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active ? AppColors.appCream : AppColors.textMain,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 15,
              color: active ? AppColors.appCream : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _TagDropdownSheet extends StatefulWidget {
  final String title;
  final List<ClothingTag> tags;
  final Set<int> activeIds;
  final void Function(ClothingTag) onToggle;
  final VoidCallback onClear;

  const _TagDropdownSheet({
    required this.title,
    required this.tags,
    required this.activeIds,
    required this.onToggle,
    required this.onClear,
  });

  @override
  State<_TagDropdownSheet> createState() => _TagDropdownSheetState();
}

class _TagDropdownSheetState extends State<_TagDropdownSheet> {
  late Set<int> _localActive;

  @override
  void initState() {
    super.initState();
    _localActive = Set.from(widget.activeIds);
  }

  void _toggle(ClothingTag tag) {
    setState(() {
      if (_localActive.contains(tag.id)) {
        _localActive.remove(tag.id);
      } else {
        _localActive.add(tag.id);
      }
    });
    widget.onToggle(tag);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.appHandleBar,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMain,
                  ),
                ),
                if (_localActive.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      widget.onClear();
                      setState(() => _localActive.clear());
                    },
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
              itemCount: widget.tags.length,
              itemBuilder: (context, index) {
                final tag = widget.tags[index];
                final isActive = _localActive.contains(tag.id);
                return GestureDetector(
                  onTap: () => _toggle(tag),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.appEspresso.withOpacity(0.06)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isActive
                            ? AppColors.appEspresso.withOpacity(0.3)
                            : AppColors.border.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            tag.tagDisplayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isActive
                                  ? AppColors.textMain
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                        if (isActive)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: AppColors.appOlive,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: AppColors.appCream,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WardrobeItemGrid extends StatelessWidget {
  final List<WardrobeClothingItem> items;
  final List<WardrobeClothingItem> selectedItems;
  final void Function(WardrobeClothingItem) onItemTap;

  const _WardrobeItemGrid({
    required this.items,
    required this.selectedItems,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedItems.any((i) => i.id == item.id);
        return _WardrobeItemCard(
          item: item,
          isSelected: isSelected,
          onTap: () => onItemTap(item),
        );
      },
    );
  }
}

class _WardrobeItemCard extends StatefulWidget {
  final WardrobeClothingItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _WardrobeItemCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_WardrobeItemCard> createState() => _WardrobeItemCardState();
}

class _WardrobeItemCardState extends State<_WardrobeItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: widget.isSelected
                ? Border.all(
                    color: AppColors.appOlive,
                    width: widget.isSelected ? 2 : 1,
                  )
                : null,
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.appEspresso.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: widget.item.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: widget.item.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 20,
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFE0E0E0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
              ),
              if (widget.isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.appOlive,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: AppColors.appCream,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WardrobeSkeletonGrid extends StatelessWidget {
  const _WardrobeSkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: 9,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _WardrobeErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _WardrobeErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 32, color: AppColors.appTan),
          const SizedBox(height: 10),
          const Text(
            'Couldn\'t load wardrobe',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Check your connection and try again.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.appEspresso,
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.appCream,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WardrobeEmptyState extends StatelessWidget {
  const _WardrobeEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checkroom_outlined, size: 32, color: AppColors.appTan),
          SizedBox(height: 10),
          Text(
            'No clothes found',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try a different filter or add clothes to your wardrobe.',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
