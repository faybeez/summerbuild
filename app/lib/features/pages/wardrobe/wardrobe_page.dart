// lib/features/pages/wardrobe/wardrobe_page.dart
//
// KEY FIXES:
//  • Removed GridView inside SingleChildScrollView (caused unbounded scroll).
//  • Used CustomScrollView with SliverToBoxAdapter (filter bar) + SliverGrid.
//  • Pull-to-refresh preserved via RefreshIndicator wrapping the CustomScrollView.
//  • Filter bar redesigned with per-type compact chips.
//  • Tapping a chip opens WardrobeFilterSheet.
//  • WardrobeTile replaced by WardrobeItemCard for consistency.
//  • Added loading, empty, and error states.

import 'package:elytsx/classes/clothing_tag.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app_colors.dart';
import '../../../classes/classes.dart';
import '../../../functions.dart';
import '../../data/tags_repository.dart';
import '../../data/wardrobe_repository.dart';
import 'widgets/wardrobe_filter_bar.dart';
import 'widgets/wardrobe_filter_sheet.dart';
import 'widgets/wardrobe_item_card.dart';

// ─── Filter-key helper (shared with filter sheet) ────────────────────────────
String _filterKey(ClothingTag tag) {
  final t = tag.tagType.toUpperCase();
  if (t == 'COLOR' || t == 'MAIN_COLOR' || t == 'SECONDARY_COLOR') {
    return 'color:${tag.tagValue.trim().toLowerCase()}';
  }
  return 'id:${tag.id}';
}

// ─── Page ────────────────────────────────────────────────────────────────────

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key, required this.tagsRepository});

  final TagsRepository tagsRepository;

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  late final WardrobeRepository _wardrobeRepo;
  late final Future<Map<String, List<ClothingTag>>> _allTagsFuture;

  final _items = <WardrobeClothingItem>[];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _cursor;
  String? _errorMessage;

  // selectedFilters: filterKey → ClothingTag
  final Map<String, ClothingTag> _selectedFilters = {};

  // ── Derived ──────────────────────────────────────────────────────────────
  List<WardrobeClothingItem> get _filteredItems {
    if (_selectedFilters.isEmpty) return _items;
    return _items.where((item) {
      final itemKeys = item.tags.map(_filterKey).toSet();
      return _selectedFilters.keys.every((key) => itemKeys.contains(key));
    }).toList();
  }

  bool get _hasActiveFilters => _selectedFilters.isNotEmpty;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _wardrobeRepo = WardrobeRepository(Supabase.instance.client);
    _allTagsFuture = _loadAllTags();
    _fetchNextPage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final justSaved = GoRouterState.of(context).extra as bool? ?? false;
    if (justSaved) _refresh();
  }

  Future<Map<String, List<ClothingTag>>> _loadAllTags() async {
    final results = await Future.wait([
      widget.tagsRepository.getTags(type: 'CATEGORY'),
      widget.tagsRepository.getTags(type: 'COLOR'),
      widget.tagsRepository.getTags(type: 'OCCASION'),
      widget.tagsRepository.getTags(type: 'WEATHER'),
    ]);
    return {
      'Category': results[0],
      'Color': results[1],
      'Occasion': results[2],
      'Weather': results[3],
    };
  }

  // ── Data loading ──────────────────────────────────────────────────────────
  Future<void> _fetchNextPage() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final page = await _wardrobeRepo.fetchPage(cursor: _cursor);
      if (mounted) {
        setState(() {
          _items.addAll(page.items);
          _hasMore = page.hasMore;
          _cursor = page.cursor;
        });
      }
    } on FunctionException catch (e) {
      if (mounted) setState(() => _errorMessage = e.details?.toString());
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _cursor = null;
      _hasMore = true;
      _errorMessage = null;
    });
    await _fetchNextPage();
  }

  // ── Filter helpers ────────────────────────────────────────────────────────
  List<FilterGroup> _buildFilterGroups(Map<String, List<ClothingTag>> allTags) {
    return allTags.entries.map((entry) {
      final selected = entry.value
          .where((t) => _selectedFilters.containsKey(_filterKey(t)))
          .toList();
      return FilterGroup(
        label: entry.key,
        tagType: entry.key.toUpperCase(),
        allTags: entry.value,
        selected: selected,
      );
    }).toList();
  }

  Future<void> _openFilterSheet(
    Map<String, List<ClothingTag>> allTags, {
    int groupIndex = 0,
  }) async {
    final groups = _buildFilterGroups(allTags);
    final result = await showWardrobeFilterSheet(
      context: context,
      groups: groups,
      currentSelections: _selectedFilters,
      initialGroupIndex: groupIndex.clamp(0, groups.length - 1),
    );
    if (result != null && mounted) {
      setState(() {
        _selectedFilters.clear();
        _selectedFilters.addAll(result);
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<ClothingTag>>>(
      future: _allTagsFuture,
      builder: (context, snapshot) {
        final allTags = snapshot.data ?? {};
        final groups = _buildFilterGroups(allTags);
        final filtered = _filteredItems;

        return AppPage(
          title: 'Wardrobe',
          subtitle:
              '${_items.length} saved piece${_items.length == 1 ? '' : 's'}',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton.filledTonal(
                onPressed: () =>
                    context.push('/wardrobe/add').then((_) => _refresh()),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          children: [
            // ── Filter bar ───────────────────────────────────────────────
            if (allTags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: WardrobeFilterBar(
                  groups: groups,
                  onGroupTap: (index) {
                    _openFilterSheet(
                      allTags,
                      groupIndex: index < 0 ? 0 : index,
                    );
                  },
                  onClearAll: () => setState(() => _selectedFilters.clear()),
                ),
              ),

            // ── Content ───────────────────────────────────────────────────
            _buildContent(filtered),
          ],
        );
      },
    );
  }

  Widget _buildContent(List<WardrobeClothingItem> filtered) {
    // Error state
    if (_errorMessage != null && _items.isEmpty) {
      return _ErrorState(message: _errorMessage!, onRetry: _refresh);
    }

    // Initial loading
    if (_isLoading && _items.isEmpty) {
      return _LoadingGrid();
    }

    // Empty state
    if (!_isLoading && filtered.isEmpty) {
      return _EmptyState(
        hasFilter: _hasActiveFilters,
        onClearFilter: () => setState(() => _selectedFilters.clear()),
        onAddItem: () => context.push('/wardrobe/add').then((_) => _refresh()),
      );
    }

    // ── Grid wrapped in RefreshIndicator ──────────────────────────────────
    //
    // LAYOUT FIX:
    // We use a SliverGrid (not GridView inside SingleChildScrollView).
    // The AppPage widget wraps children in a Column; the grid itself
    // is sized via LayoutBuilder so it fills remaining vertical space.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Provide a minimum height so the scroll area is meaningful.
        final minHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height * 0.7;

        return SizedBox(
          height: minHeight,
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.appEspresso,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 24),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Loading sentinel
                        if (index == filtered.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                color: AppColors.appEspresso,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }

                        final item = filtered[index];
                        return WardrobeItemCard(
                          item: item,
                          onTap: () => context.push('/wardrobe/${item.id}'),
                        );
                      },
                      childCount: filtered.length + (_hasMore ? 1 : 0),
                      addRepaintBoundaries: true,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.82,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                  ),
                ),
                // Trigger next-page load when near bottom
                SliverToBoxAdapter(
                  child: _PaginationTrigger(
                    hasMore: _hasMore,
                    isLoading: _isLoading,
                    onTrigger: _fetchNextPage,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Supporting widgets ───────────────────────────────────────────────────────

/// Invisible widget at the bottom of the list that triggers next-page loading.
class _PaginationTrigger extends StatefulWidget {
  const _PaginationTrigger({
    required this.hasMore,
    required this.isLoading,
    required this.onTrigger,
  });

  final bool hasMore;
  final bool isLoading;
  final VoidCallback onTrigger;

  @override
  State<_PaginationTrigger> createState() => _PaginationTriggerState();
}

class _PaginationTriggerState extends State<_PaginationTrigger> {
  @override
  void didUpdateWidget(_PaginationTrigger old) {
    super.didUpdateWidget(old);
    if (widget.hasMore && !widget.isLoading) {
      // Trigger at next frame to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.hasMore && !widget.isLoading) {
          widget.onTrigger();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _LoadingGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppColors.appWarmCream,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasFilter,
    required this.onClearFilter,
    required this.onAddItem,
  });

  final bool hasFilter;
  final VoidCallback onClearFilter;
  final VoidCallback onAddItem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilter
                  ? Icons.filter_list_off_rounded
                  : Icons.checkroom_outlined,
              size: 64,
              color: AppColors.appTan,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter
                  ? 'No items match your filters'
                  : 'Your wardrobe is empty',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.appEspresso,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Try clearing some filters.'
                  : 'Tap + to add your first piece.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.appOlive),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (hasFilter)
              OutlinedButton(
                onPressed: onClearFilter,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.appTan),
                  foregroundColor: AppColors.appEspresso,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Clear filters'),
              )
            else
              FilledButton.icon(
                onPressed: onAddItem,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.appEspresso,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add clothes'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: AppColors.appTan,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load wardrobe',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.appEspresso,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.appOlive),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.appEspresso,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
