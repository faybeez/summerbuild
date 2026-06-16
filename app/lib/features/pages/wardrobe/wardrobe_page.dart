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

class WardrobePage extends StatefulWidget {
  const WardrobePage({super.key, required this.tagsRepository});

  final TagsRepository tagsRepository;

  @override
  State<WardrobePage> createState() => _WardrobePageState();
}

class _WardrobePageState extends State<WardrobePage> {
  late final WardrobeRepository _wardrobeRepo;
  late final Future<List<ClothingTag>> _categoryTagsFuture;
  late final ScrollController _scrollController;

  final _items = <WardrobeClothingItem>[];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _cursor;
  String _selectedCategory = 'All';

  List<WardrobeClothingItem> get _filteredItems {
    if (_selectedCategory == 'All') return _items;
    return _items
        .where((i) => i.category?.tagDisplayName == _selectedCategory)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _wardrobeRepo = WardrobeRepository(Supabase.instance.client);
    _categoryTagsFuture = widget.tagsRepository.getTags(type: 'CATEGORY');
    _scrollController = ScrollController()..addListener(_onScroll);
    _fetchNextPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    final pos = _scrollController.position.pixels;
    if (pos >= max - 500 && !_isLoading && _hasMore) {
      _fetchNextPage();
    }
  }

  Future<void> _fetchNextPage() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final page = await _wardrobeRepo.fetchPage(cursor: _cursor);
      debugPrint(
        'Fetched wardrobe page: ${page.items.length} items, hasMore: ${page.hasMore}, cursor: ${page.cursor}',
      );

      debugPrint('type of page.items: ${page.items.runtimeType}');
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

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return AppPage(
      title: 'Wardrobe',
      subtitle: '${_items.length} saved pieces',
      trailing: IconButton.filledTonal(
        onPressed: () => context.go('/wardrobe/add'),
        icon: const Icon(Icons.add),
      ),
      children: [
        FutureBuilder<List<String>>(
          future: _categoryTagsFuture.then(
            (tags) => ['All', ...tags.map((t) => t.tagDisplayName)],
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 40,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.appEspresso,
                    strokeWidth: 2,
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: snapshot.data!.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = category),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
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
        padding: const EdgeInsets.all(14),
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
            const SizedBox(height: 12),
            Text(
              item.tags
                  .firstWhere(
                    (x) => x.tagType == 'CATEGORY',
                    orElse: () => ClothingTag(
                      id: -1,
                      tagType: 'CATEGORY',
                      tagValue: 'test2',
                      tagDisplayName: 'test2',
                    ),
                  )
                  .tagValue,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              item.category?.tagDisplayName ?? '',
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
