import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app_colors.dart';
import '../../../data/wardrobe_repository.dart';
import '../../../data/tags_repository.dart';
import '../../../../classes/clothing_tag.dart';

class ReviewBuildPage extends StatefulWidget {
  const ReviewBuildPage({
    super.key,
    required this.selectedItems,
    required this.tagsRepository,
  });

  final List<WardrobeClothingItem> selectedItems;
  final TagsRepository tagsRepository;

  @override
  State<ReviewBuildPage> createState() => _ReviewBuildPageState();
}

class _ReviewBuildPageState extends State<ReviewBuildPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? _rating;
  bool _isSaving = false;

  List<ClothingTag> _allTags = [];
  List<ClothingTag> _selectedTags = [];
  bool _tagsLoading = true;

  @override
  void initState() {
    super.initState();
    _initTags();
  }

  void _initTags() {
    final prefilled =
        widget.selectedItems
            .expand((item) => item.tags)
            .where((t) => t.tagType.toUpperCase() != 'CATEGORY')
            .fold<Map<int, ClothingTag>>({}, (map, tag) {
              map[tag.id] = tag;
              return map;
            })
            .values
            .toList()
          ..sort((a, b) => a.tagDisplayName.compareTo(b.tagDisplayName));

    setState(() {
      _allTags = List.from(prefilled);
      _selectedTags = List.from(prefilled);
      _tagsLoading = false;
    });
  }

  void _toggleTag(ClothingTag tag) {
    setState(() {
      if (_selectedTags.any((t) => t.id == tag.id)) {
        _selectedTags.removeWhere((t) => t.id == tag.id);
      } else {
        _selectedTags.add(tag);
        _selectedTags.sort(
          (a, b) => a.tagDisplayName.compareTo(b.tagDisplayName),
        );
      }
    });
  }

  void _showAddTagsSheet() async {
    List<ClothingTag> allRepoTags = [];
    try {
      allRepoTags = await widget.tagsRepository.getTags(type: 'ALL');
      allRepoTags = allRepoTags
          .where((t) => t.tagType.toUpperCase() != 'CATEGORY')
          .toList();
    } catch (_) {}

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddTagsSheet(
        allTags: allRepoTags,
        selectedTags: List.from(_selectedTags),
        onTagsConfirmed: (updatedSelected) {
          setState(() {
            for (final tag in updatedSelected) {
              if (!_allTags.any((t) => t.id == tag.id)) {
                _allTags.add(tag);
              }
            }
            _allTags.sort(
              (a, b) => a.tagType.compareTo(b.tagType) != 0
                  ? a.tagType.compareTo(b.tagType)
                  : a.tagDisplayName.compareTo(b.tagDisplayName),
            );
            _selectedTags = updatedSelected
              ..sort(
                (a, b) => a.tagType.compareTo(b.tagType) != 0
                    ? a.tagType.compareTo(b.tagType)
                    : a.tagDisplayName.compareTo(b.tagDisplayName),
              );
          });
        },
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final clothes = widget.selectedItems
          .asMap()
          .entries
          .map(
            (e) => {
              'clothesId': e.value.id,
              'slot': e.value.category?.tagValue == 'ACCESSORIES'
                  ? 'ACCESSORIES'
                  : 'OUTFIT',
              'sortOrder': e.key,
            },
          )
          .toList();

      final body = {
        'name': _nameController.text.trim(),
        if (_descriptionController.text.trim().isNotEmpty)
          'description': _descriptionController.text.trim(),
        if (_rating != null) 'rating': _rating,
        'tagIds': _selectedTags.map((t) => t.id).toList(),
        'clothes': clothes,
      };

      final response = await Supabase.instance.client.functions.invoke(
        'create-outfit',
        body: body,
      );

      if (response.data != null && mounted) {
        context.pop();
      }
    } on FunctionException catch (e) {
      debugPrint('Edge Function Error: $e, Details: ${e.details}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.details}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
          'Review your outfit',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.appEspresso,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _isSaving ? null : _save,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.appEspresso,
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
                        'Save',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.appCream,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: _CollagePreview(items: widget.selectedItems),
            ),
            Expanded(
              child: _DetailsPanel(
                formKey: _formKey,
                nameController: _nameController,
                descriptionController: _descriptionController,
                rating: _rating,
                selectedTags: _selectedTags,
                tagsLoading: _tagsLoading,
                onRatingChanged: (r) => setState(() => _rating = r),
                onTagToggle: _toggleTag,
                onAddTags: _showAddTagsSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollagePreview extends StatelessWidget {
  final List<WardrobeClothingItem> items;
  const _CollagePreview({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
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
      child: _CollageGrid(items: items),
    );
  }
}

class _CollageGrid extends StatelessWidget {
  final List<WardrobeClothingItem> items;
  const _CollageGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final count = items.length;
    if (count == 0) return Container(color: AppColors.appWarmCream);
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
    if (url == null) return Container(color: const Color(0xFFE8D0B0));
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => Container(color: const Color(0xFFE8D0B0)),
      errorWidget: (_, __, ___) => Container(
        color: const Color(0xFFE8D0B0),
        child: const Icon(
          Icons.image_not_supported_outlined,
          size: 16,
          color: Color(0xFFD9B88F),
        ),
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final int? rating;
  final List<ClothingTag> selectedTags;
  final bool tagsLoading;
  final void Function(int?) onRatingChanged;
  final void Function(ClothingTag) onTagToggle;
  final VoidCallback onAddTags;

  const _DetailsPanel({
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.rating,
    required this.selectedTags,
    required this.tagsLoading,
    required this.onRatingChanged,
    required this.onTagToggle,
    required this.onAddTags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: 'Name', required: true),
                    const SizedBox(height: 8),
                    _OutfitTextField(
                      controller: nameController,
                      hintText: 'e.g. Weekend vibes',
                      maxLines: 1,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Please enter a name';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _FieldLabel(text: 'Description', required: false),
                    const SizedBox(height: 8),
                    _OutfitTextField(
                      controller: descriptionController,
                      hintText: 'What\'s this outfit for?',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    _FieldLabel(text: 'Rating', required: false),
                    const SizedBox(height: 10),
                    _StarRating(rating: rating, onChanged: onRatingChanged),
                    const SizedBox(height: 24),
                    _FieldLabel(text: 'Tags', required: false),
                    const SizedBox(height: 10),
                    _TagsSection(
                      selectedTags: selectedTags,
                      loading: tagsLoading,
                      onTagToggle: onTagToggle,
                      onAddTags: onAddTags,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FieldLabel({required this.text, required this.required});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
            letterSpacing: 0.2,
          ),
        ),
        if (required)
          const Padding(
            padding: EdgeInsets.only(left: 3),
            child: Text(
              '*',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.appTerracotta,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _OutfitTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final String? Function(String?)? validator;

  const _OutfitTextField({
    required this.controller,
    required this.hintText,
    required this.maxLines,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textMain,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14,
          color: AppColors.textMuted.withOpacity(0.6),
        ),
        filled: true,
        fillColor: AppColors.appCream,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.appTerracotta,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 12, color: AppColors.error),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int? rating;
  final void Function(int?) onChanged;

  const _StarRating({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          final star = i + 1;
          final filled = rating != null && star <= rating!;
          return GestureDetector(
            onTap: () => onChanged(rating == star ? null : star),
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  key: ValueKey('$star-$filled'),
                  size: 30,
                  color: filled ? AppColors.appTerracotta : AppColors.appTan,
                ),
              ),
            ),
          );
        }),
        if (rating != null)
          GestureDetector(
            onTap: () => onChanged(null),
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'Clear',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TagsSection extends StatelessWidget {
  final List<ClothingTag> selectedTags;
  final bool loading;
  final void Function(ClothingTag) onTagToggle;
  final VoidCallback onAddTags;

  const _TagsSection({
    required this.selectedTags,
    required this.loading,
    required this.onTagToggle,
    required this.onAddTags,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return const SizedBox(height: 36);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...selectedTags.map(
          (tag) => _TagChip(tag: tag, onTap: () => onTagToggle(tag)),
        ),
        _AddTagChip(onTap: onAddTags),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final ClothingTag tag;
  final VoidCallback onTap;

  const _TagChip({required this.tag, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.appEspresso,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: AppColors.appEspresso),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            tag.tagWidget(size: 16, iconColor: AppColors.appOlive),
            const SizedBox(width: 5),
            Text(
              tag.tagDisplayName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.appCream,
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.close_rounded,
              size: 13,
              color: AppColors.appCream.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTagChip extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTagChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 15, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              'Add tags',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Tags Sheet ───────────────────────────────────────────────────────────

class _AddTagsSheet extends StatefulWidget {
  final List<ClothingTag> allTags;
  final List<ClothingTag> selectedTags;
  final void Function(List<ClothingTag> updatedSelected) onTagsConfirmed;

  const _AddTagsSheet({
    required this.allTags,
    required this.selectedTags,
    required this.onTagsConfirmed,
  });

  @override
  State<_AddTagsSheet> createState() => _AddTagsSheetState();
}

class _AddTagsSheetState extends State<_AddTagsSheet> {
  late List<ClothingTag> _localSelected;

  static const List<String> _typeOrder = [
    'WEATHER',
    'OCCASION',
    'MAIN_COLOR',
    'SECONDARY_COLOR',
  ];

  @override
  void initState() {
    super.initState();
    _localSelected = List.from(widget.selectedTags);
  }

  Map<String, List<ClothingTag>> get _grouped {
    final map = <String, List<ClothingTag>>{};
    for (final tag in widget.allTags) {
      final type = tag.tagType.toUpperCase();
      map.putIfAbsent(type, () => []).add(tag);
    }
    return map;
  }

  List<String> get _orderedTypes {
    final grouped = _grouped;
    final ordered = _typeOrder.where((t) => grouped.containsKey(t)).toList();
    return ordered;
  }

  String _typeLabel(String type) => type
      .split('_')
      .map((word) {
        if (word.isEmpty) return word;

        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      })
      .join(' ');

  bool _isSelected(ClothingTag tag) =>
      _localSelected.any((t) => t.id == tag.id);

  void _toggle(ClothingTag tag) {
    setState(() {
      if (_isSelected(tag)) {
        _localSelected.removeWhere((t) => t.id == tag.id);
      } else {
        _localSelected.add(tag);
      }
    });
    widget.onTagsConfirmed(List.from(_localSelected));
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final orderedTypes = _orderedTypes;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
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
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  const Text(
                    'Add tags',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.border.withOpacity(0.3)),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                itemCount: orderedTypes.length,
                itemBuilder: (_, i) {
                  final type = orderedTypes[i];
                  final tags = grouped[type] ?? [];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            _typeLabel(type),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tags.map((tag) {
                            final isSelected = _isSelected(tag);
                            return GestureDetector(
                              onTap: () => _toggle(tag),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 140),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.appEspresso
                                      : AppColors.appChipBg,
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.appEspresso
                                        : AppColors.appPeach,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    tag.tagWidget(
                                      size: 16,
                                      iconColor: isSelected
                                          ? AppColors.appCream
                                          : AppColors.appOlive,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      tag.tagDisplayName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.appCream
                                            : AppColors.appOlive,
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 5),
                                      Icon(
                                        Icons.close_rounded,
                                        size: 13,
                                        color: AppColors.appCream.withOpacity(
                                          0.8,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
