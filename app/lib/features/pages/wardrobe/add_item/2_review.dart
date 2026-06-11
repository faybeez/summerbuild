import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../app_colors.dart';
import '../../../../functions.dart';
import '../../../../classes.dart';
import 'wardrobe_add_state.dart';

class WardrobeReviewPage extends StatefulWidget {
  final WardrobeAddState state;
  final VoidCallback onConfirm;

  const WardrobeReviewPage({
    super.key,
    required this.state,
    required this.onConfirm,
  });

  @override
  State<WardrobeReviewPage> createState() => _WardrobeReviewPageState();
}

class _WardrobeReviewPageState extends State<WardrobeReviewPage> {
  void _removeCategory() => setState(
    () => widget.state.category != null ? widget.state.category = '' : null,
  );

  void _removeOccasion(String item) => setState(
    () => {
      if (widget.state.occasion.contains(item))
        widget.state.occasion.remove(item),
    },
  );

  void _removeMainColor(String item) =>
      setState(() => widget.state.mainColors.remove(item));

  void _removeSecondaryColor(String item) =>
      setState(() => widget.state.secondaryColors.remove(item));

  // void _openSelector(String type) {
  //   TagSelector.show(
  //     context: context,
  //     title: 'Add Type',
  //     availableTags: _typeTagOptions,
  //     selectedTags: widget.state.types,
  //     onAddTag: (label) => setState(() => widget.state.types.add(label)),
  //     onRemoveTag: (label) => setState(() => widget.state.types.remove(label)),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final image = widget.state.image;

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
                    color: const Color(0xFFFAF6F0),
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
              _buildSectionTitle('Category'),
              const SizedBox(height: 12),
              _buildChipWrap(
                items:
                    widget.state.category != null &&
                        widget.state.category!.isNotEmpty
                    ? [widget.state.category!]
                    : [],
                onRemove: (string) {},
                onAddPressed: () {},
              ),
              _buildDivider(),

              _buildSectionTitle('Occasion'),
              const SizedBox(height: 12),
              _buildChipWrap(
                items: widget.state.occasion,
                onRemove: _removeOccasion,
                onAddPressed: () {
                  // TODO: show add occasion dialog
                },
              ),
              _buildDivider(),

              // Colors
              _buildSectionTitle('Main Colors'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ...widget.state.mainColors.map(
                    (c) => _buildColorChip(c, _colorFromName(c)),
                  ),
                  _buildDashedAddButton(
                    onPressed: () {
                      // TODO: show add color dialog
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: widget.onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appEspresso,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm & Save',
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

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.appEspresso,
    ),
  );

  Widget _buildDivider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 16.0),
    child: Divider(color: Color(0xFFE8E0D5), thickness: 1),
  );

  Widget _buildChipWrap({
    required List<String> items,
    required ValueChanged<String> onRemove,
    required VoidCallback onAddPressed,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ...items.map((item) => _buildStandardChip(item, () => onRemove(item))),
        _buildDashedAddButton(onPressed: onAddPressed),
      ],
    );
  }

  Widget _buildStandardChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2E6D8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.appEspresso,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.appEspresso,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2E6D8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.appEspresso,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _removeMainColor(label),
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.appEspresso,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedAddButton({required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: CustomPaint(
        painter: const DashedBorderPainter(color: Color(0xFFC4B8A9)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: const Text(
            '+ Add',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.appOlive,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Fallback: maps a color name string to a Color.
  /// Replace/extend with a real map from your design system.
  Color _colorFromName(String name) {
    const map = {
      'Beige': Color(0xFFC4B8A9),
      'Cream': Color(0xFFFDFBF7),
      'White': Color(0xFFFFFFFF),
      'Tan': Color(0xFFD9B88F),
      'Olive': Color(0xFF8C7E5B),
      'Navy': Color(0xFF1A2F4C),
      'Gray': Color(0xFF9E9E9E),
      'Burgundy': Color(0xFF6B1C32),
      'Denim': Color(0xFF597A9E),
    };
    return map[name] ?? const Color(0xFFC4B8A9);
  }
}
