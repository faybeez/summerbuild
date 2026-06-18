import 'package:elytsx/classes/clothing_tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../app_colors.dart';
import '../../classes/classes.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.onSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      onSubmitted: onSubmitted,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
    );
  }
}

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }
}

class SelectableCard extends StatelessWidget {
  final String? label;
  final Widget? child;
  final bool selected;
  final VoidCallback onTap;
  final double? horizontalPadding;
  final double? verticalPadding;

  const SelectableCard({
    this.label,
    this.child,
    required this.selected,
    required this.onTap,
    this.horizontalPadding,
    this.verticalPadding,
  }) : assert(
         label != null || child != null,
         'Either label or child must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final Widget content =
        child ??
        Row(
          children: [
            Expanded(
              child: Text(
                label!,
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textMain,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (selected) Icon(Icons.check, color: AppColors.primary, size: 18),
          ],
        );

    // use instance values, with defaults
    final double hPadding = horizontalPadding ?? 16.0;
    final double vPadding = verticalPadding ?? 14.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: hPadding,
            vertical: vPadding,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color.fromARGB(255, 255, 238, 219)
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.appTerracotta : AppColors.border,
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}

class TagSelector extends StatefulWidget {
  final String title;
  final List<ClothingTag> availableTags;
  final List<String> selectedTags;
  final ValueChanged<String> onAddTag;
  final ValueChanged<String> onRemoveTag;

  const TagSelector({
    super.key,
    required this.title,
    required this.availableTags,
    required this.selectedTags,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  static void show({
    required BuildContext context,
    required String title,
    required List<ClothingTag> availableTags,
    required List<String> selectedTags,
    required ValueChanged<String> onAddTag,
    required ValueChanged<String> onRemoveTag,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TagSelector(
        title: title,
        availableTags: availableTags,
        selectedTags: selectedTags,
        onAddTag: onAddTag,
        onRemoveTag: onRemoveTag,
      ),
    );
  }

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  // Local copy so the checkboxes respond instantly without waiting
  // for the parent setState to propagate back
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.selectedTags);
  }

  void _toggle(String label) {
    final isCurrentlySelected = _selected.contains(label);
    setState(() {
      if (isCurrentlySelected) {
        _selected.remove(label);
      } else {
        _selected.add(label);
      }
    });
    // Notify parent immediately
    if (isCurrentlySelected) {
      widget.onRemoveTag(label);
    } else {
      widget.onAddTag(label);
    }
  }

  void _clearAll() {
    for (final label in _selected.toList()) {
      widget.onRemoveTag(label);
    }
    setState(() => _selected.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAF6F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9CEBE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Header row: X | Title | Clear
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.appEspresso,
                      size: 22,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.appEspresso,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  GestureDetector(
                    onTap: _clearAll,
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.appOlive,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tag list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.availableTags.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Color(0xFFEDE8E2), height: 1),
                itemBuilder: (context, index) {
                  final tag = widget.availableTags[index];
                  final isSelected = _selected.contains(tag.tagValue);

                  return GestureDetector(
                    onTap: () => _toggle(tag.tagValue),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          // Optional icon
                          // SizedBox(
                          //   width: 40,
                          //   child: tag.icon ?? const SizedBox.shrink(),
                          // ),

                          // Label
                          Expanded(
                            child: Text(
                              tag.tagDisplayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.appEspresso,
                              ),
                            ),
                          ),

                          // Animated checkbox
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFF2E6D8)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.appEspresso
                                    : const Color(0xFFD4C9BD),
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppColors.appEspresso,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Done button — just closes, changes already applied live
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appTan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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
