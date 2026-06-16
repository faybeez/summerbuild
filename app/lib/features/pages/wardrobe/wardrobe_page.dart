import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app_colors.dart';
import '../../../classes.dart';
import '../../../functions.dart';
import '../../data/tags_repository.dart';
import '../../data/wardrobe_repository.dart';
import 'wardrobe_detail_page.dart';

String _filterKey(ClothingTag tag) {
  final t = tag.tagType.toUpperCase();
  if (t == 'COLOR' || t == 'MAIN_COLOR' || t == 'SECONDARY_COLOR') {
    return 'color:${tag.tagValue.trim().toLowerCase()}';
  }
  return 'id:${tag.id}';
}

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key, required this.tagsRepository});

  final TagsRepository tagsRepository;

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  late final WardrobeRepository _wardrobeRepo;
  late final Future<Map<String, List<ClothingTag>>> _allTagsFuture;
  late final ScrollController _scrollController;

  final _items = <WardrobeClothingItem>[];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _cursor;

  final Map<String, ClothingTag> _selectedFilters = {};

  List<WardrobeClothingItem> get _filteredItems {
    if (_selectedFilters.isEmpty) return _items;
    return _items.where((item) {
      final itemKeys = item.tags.map(_filterKey).toSet();
      return _selectedFilters.keys.every((key) => itemKeys.contains(key));
    }).toList();
  }

  bool get _hasActiveFilters => _selectedFilters.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _wardrobeRepo = WardrobeRepository(Supabase.instance.client);
    _allTagsFuture = _loadAllTags();
    _scrollController = ScrollController()..addListener(_onScroll);
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    final pos = _scrollController.position.pixels;
    if (pos >= max - 500 && !_isLoading && _hasMore) _fetchNextPage();
  }

  Future<void> _fetchNextPage() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final page = await _wardrobeRepo.fetchPage(cursor: _cursor);
      setState(() {
        _items.addAll(page.items);
        _hasMore = page.hasMore;
        _cursor = page.cursor;
      });
    } on FunctionException catch (e) {
      debugPrint('Wardrobe fetch error 1: ${e.details}');
    } catch (e) {
      debugPrint('Wardrobe fetch error 2: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _cursor = null;
      _hasMore = true;
    });
    await _fetchNextPage();
  }

  void _openFilterSheet(Map<String, List<ClothingTag>> allTags) {
    final pending = Map<String, ClothingTag>.from(_selectedFilters);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.95,
              minChildSize: 0.4,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          Text(
                            'Filter',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () =>
                                setSheetState(() => pending.clear()),
                            child: Text(
                              'Clear all',
                              style: TextStyle(
                                color: AppColors.appEspresso.withAlpha(150),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.appEspresso,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedFilters
                                  ..clear()
                                  ..addAll(pending);
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        children: allTags.entries.map((entry) {
                          final groupLabel = entry.key;
                          final groupTags = entry.value;
                          if (groupTags.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                groupLabel.toUpperCase(),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: AppColors.appEspresso.withAlpha(
                                        150,
                                      ),
                                      letterSpacing: 1.2,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: groupTags.map((tag) {
                                  final key = _filterKey(tag);
                                  final selected = pending.containsKey(key);
                                  return FilterChip(
                                    label: Text(tag.tagDisplayName),
                                    selected: selected,
                                    onSelected: (_) {
                                      setSheetState(() {
                                        if (selected) {
                                          pending.remove(key);
                                        } else {
                                          pending[key] = tag;
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return FutureBuilder<Map<String, List<ClothingTag>>>(
      future: _allTagsFuture,
      builder: (context, snapshot) {
        final allTags = snapshot.data ?? {};

        return AppPage(
          title: 'Wardrobe',
          subtitle: '${_items.length} saved pieces',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  IconButton(
                    onPressed: allTags.isEmpty
                        ? null
                        : () => _openFilterSheet(allTags),
                    icon: const Icon(Icons.tune_rounded),
                  ),
                  if (_hasActiveFilters)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.appEspresso,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              IconButton.filledTonal(
                onPressed: () => context.push('/wardrobe/add'),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          children: [
            if (_hasActiveFilters)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ..._selectedFilters.entries.map((entry) {
                        final tag = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(tag.tagDisplayName),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => setState(
                              () => _selectedFilters.remove(entry.key),
                            ),
                          ),
                        );
                      }),
                      TextButton(
                        onPressed: () =>
                            setState(() => _selectedFilters.clear()),
                        child: const Text('Clear all'),
                      ),
                    ],
                  ),
                ),
              ),
            RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.appEspresso,
              child: GridView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: filtered.length + (_hasMore ? 1 : 0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
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
                  return WardrobeTile(
                    item: item,
                    onTap: () => context.push('/wardrobe/${item.id}'),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class WardrobeTile extends StatelessWidget {
  const WardrobeTile({required this.item, this.onTap, super.key});

  final WardrobeClothingItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: cardDecoration(AppColors.appCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        memCacheWidth: 200,
                        memCacheHeight: 200,
                        placeholder: (_, __) => Container(
                          color: AppColors.appWarmCream,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.appTan,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.appWarmCream,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.appTan,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.appWarmCream,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.appTan,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
