import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../app_colors.dart';
import '../../../../classes.dart';
import 'tag_widget.dart';
import 'wardrobe_add_state.dart';

class WardrobeReviewPage extends StatefulWidget {
  final WardrobeAddState state;
  final VoidCallback onConfirm;
  final bool isLoading;

  const WardrobeReviewPage({
    super.key,
    required this.state,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  State<WardrobeReviewPage> createState() => _WardrobeReviewPageState();
}

class _WardrobeReviewPageState extends State<WardrobeReviewPage> {
  late Future<List<ClothingTag>> _categoryOptionsFuture;
  late Future<List<ClothingTag>> _occasionOptionsFuture;
  late Future<List<ClothingTag>> _colorOptionsFuture;
  late Future<List<ClothingTag>> _weatherOptionsFuture;

  late final TextEditingController _costController;
  late final TextEditingController _timesWornController;

  @override
  void initState() {
    super.initState();
    final repo = widget.state.tagsRepository;
    _categoryOptionsFuture = repo.getTags(type: 'CATEGORY');
    _occasionOptionsFuture = repo.getTags(type: 'OCCASION');
    _colorOptionsFuture = repo.getTags(type: 'COLOR');
    _weatherOptionsFuture = repo.getTags(type: 'WEATHER');

    _costController = TextEditingController(
      text: widget.state.cost > 0 ? widget.state.cost.toStringAsFixed(2) : '',
    );
    _timesWornController = TextEditingController(
      text: widget.state.timesWorn > 0 ? widget.state.timesWorn.toString() : '',
    );
  }

  @override
  void dispose() {
    _costController.dispose();
    _timesWornController.dispose();
    super.dispose();
  }

  void _removeCategory() => setState(() => widget.state.category = null);

  void _removeOccasion(ClothingTag tag) =>
      setState(() => widget.state.occasion.remove(tag));

  void _removeMainColor(ClothingTag tag) =>
      setState(() => widget.state.mainColors.remove(tag));

  void _removeSecondaryColor(ClothingTag tag) =>
      setState(() => widget.state.secondaryColors.remove(tag));

  void _removeWeather(ClothingTag tag) =>
      setState(() => widget.state.weather.remove(tag));

  void _openSelector({
    required String title,
    required Future<List<ClothingTag>> availableFuture,
    required List<ClothingTag> selected,
    required void Function(ClothingTag) onAdd,
    required void Function(ClothingTag) onRemove,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FutureBuilder<List<ClothingTag>>(
        future: availableFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const _LoadingSheet();
          }
          return _TagSelectorSheet(
            title: title,
            availableTags: snapshot.data!,
            selectedTags: selected,
            onToggle: (tag) {
              final isSelected = selected.any((t) => t.id == tag.id);
              setState(() => isSelected ? onRemove(tag) : onAdd(tag));
            },
          );
        },
      ),
    );
  }

  void _openCategorySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FutureBuilder<List<ClothingTag>>(
        future: _categoryOptionsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const _LoadingSheet();
          return _TagSelectorSheet(
            title: 'Category',
            availableTags: snapshot.data!,
            selectedTags: widget.state.category != null
                ? [widget.state.category!]
                : [],
            singleSelect: true,
            onToggle: (tag) {
              setState(() {
                widget.state.category = widget.state.category?.id == tag.id
                    ? null
                    : tag;
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.state.image;
    final isLoading = widget.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Review Details',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.appEspresso,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.appWarmCream,
                    image: image != null
                        ? DecorationImage(
                            image: FileImage(image),
                            fit: BoxFit.fitHeight,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      label: 'Cost',
                      hint: '0.00',
                      controller: _costController,
                      prefix: 'S\$',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (val) {
                        widget.state.cost = double.tryParse(val) ?? 0.0;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField(
                      label: 'Times Worn',
                      hint: '0',
                      controller: _timesWornController,
                      prefix: null,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        widget.state.timesWorn = int.tryParse(val) ?? 0;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              TagGroupSection(
                title: 'Category',
                tags: widget.state.category != null
                    ? [widget.state.category!]
                    : [],
                onRemove: (_) => _removeCategory(),
                onAddTap: _openCategorySelector,
              ),
              _buildDivider(),

              TagGroupSection(
                title: 'Occasion',
                tags: widget.state.occasion,
                onRemove: _removeOccasion,
                onAddTap: () => _openSelector(
                  title: 'Occasion',
                  availableFuture: _occasionOptionsFuture,
                  selected: widget.state.occasion,
                  onAdd: (tag) => widget.state.occasion.add(tag),
                  onRemove: (tag) => widget.state.occasion.remove(tag),
                ),
              ),
              _buildDivider(),

              TagGroupSection(
                title: 'Weather',
                tags: widget.state.weather,
                onRemove: _removeWeather,
                onAddTap: () => _openSelector(
                  title: 'Weather',
                  availableFuture: _weatherOptionsFuture,
                  selected: widget.state.weather,
                  onAdd: (tag) => widget.state.weather.add(tag),
                  onRemove: (tag) => widget.state.weather.remove(tag),
                ),
              ),
              _buildDivider(),

              TagGroupSection(
                title: 'Main Colors',
                tags: widget.state.mainColors,
                onRemove: _removeMainColor,
                onAddTap: () => _openSelector(
                  title: 'Main Colors',
                  availableFuture: _colorOptionsFuture,
                  selected: widget.state.mainColors,
                  onAdd: (tag) => widget.state.mainColors.add(tag),
                  onRemove: (tag) => widget.state.mainColors.remove(tag),
                ),
              ),
              _buildDivider(),

              TagGroupSection(
                title: 'Secondary Colors',
                tags: widget.state.secondaryColors,
                onRemove: _removeSecondaryColor,
                onAddTap: () => _openSelector(
                  title: 'Secondary Colors',
                  availableFuture: _colorOptionsFuture,
                  selected: widget.state.secondaryColors,
                  onAdd: (tag) => widget.state.secondaryColors.add(tag),
                  onRemove: (tag) => widget.state.secondaryColors.remove(tag),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (image != null && !isLoading)
                      ? widget.onConfirm
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appEspresso,
                    disabledBackgroundColor: AppColors.appEspresso.withAlpha(
                      80,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Save to Wardrobe',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 16.0),
    child: Divider(color: Color(0xFFE8E0D5), thickness: 1),
  );
}

class _LoadingSheet extends StatelessWidget {
  const _LoadingSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.appEspresso),
      ),
    );
  }
}

class _TagSelectorSheet extends StatefulWidget {
  final String title;
  final List<ClothingTag> availableTags;
  final List<ClothingTag> selectedTags;
  final void Function(ClothingTag tag) onToggle;
  final bool singleSelect;

  const _TagSelectorSheet({
    required this.title,
    required this.availableTags,
    required this.selectedTags,
    required this.onToggle,
    this.singleSelect = false,
  });

  @override
  State<_TagSelectorSheet> createState() => _TagSelectorSheetState();
}

class _TagSelectorSheetState extends State<_TagSelectorSheet> {
  late final Set<int> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.selectedTags.map((t) => t.id).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.appTan,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: AppColors.appTerracotta,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE8E0D5)),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: widget.availableTags.length,
                itemBuilder: (_, index) {
                  final tag = widget.availableTags[index];
                  final isSelected = _selectedIds.contains(tag.id);
                  return ListTile(
                    title: Text(
                      tag.tagDisplayName,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textMain,
                      ),
                    ),
                    trailing: isSelected
                        ? Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.appEspresso,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 15,
                              color: Colors.white,
                            ),
                          )
                        : Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.appTan),
                            ),
                          ),
                    onTap: () {
                      setState(() {
                        if (widget.singleSelect) {
                          _selectedIds
                            ..clear()
                            ..add(tag.id);
                        } else {
                          isSelected
                              ? _selectedIds.remove(tag.id)
                              : _selectedIds.add(tag.id);
                        }
                      });
                      widget.onToggle(tag);
                    },
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

Widget _buildNumberField({
  required String label,
  required String hint,
  required TextEditingController controller,
  required String? prefix,
  required TextInputType keyboardType,
  required void Function(String) onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: AppColors.appOlive,
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.appEspresso,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefix,
          prefixStyle: const TextStyle(
            fontSize: 15,
            color: AppColors.appOlive,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(color: AppColors.appTan, fontSize: 15),
          filled: true,
          fillColor: AppColors.appCard,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8E0D5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.appEspresso,
              width: 1.5,
            ),
          ),
        ),
      ),
    ],
  );
}
