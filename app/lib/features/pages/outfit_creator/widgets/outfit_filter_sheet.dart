// lib/features/outfit_creator/widgets/outfit_filter_sheet.dart
//
// A bottom sheet that collects the user's outfit generation preferences.
// Values are applied back into OutfitCreatorController via callbacks.

import 'package:flutter/material.dart';

import '../../../../app_colors.dart';
import '../../../data/wardrobe_repository.dart';

const _occasions = [
  'CASUAL',
  'WORK',
  'FORMAL',
  'PARTY',
  'DATE',
  'OUTDOOR',
  'BEACH',
  'TRAVEL',
];

const _weathers = ['HOT', 'WARM', 'MILD', 'COLD', 'RAINY', 'WINDY'];

const _vibes = ['CASUAL', 'CHIC', 'SPORTY', 'ELEGANT', 'BOHO', 'MINIMALIST'];

const _colors = [
  'BLACK',
  'WHITE',
  'NAVY',
  'BEIGE',
  'BROWN',
  'GREY',
  'RED',
  'BLUE',
  'GREEN',
  'YELLOW',
  'ORANGE',
  'PINK',
  'PURPLE',
];

class OutfitFilterSheet extends StatefulWidget {
  const OutfitFilterSheet({
    super.key,
    required this.initialOccasion,
    required this.initialWeather,
    required this.initialColorPreference,
    required this.initialVibe,
    required this.initialMustInclude,
    required this.allWardrobeItems,
    required this.onApply,
  });

  final String initialOccasion;
  final String initialWeather;
  final String? initialColorPreference;
  final String? initialVibe;
  final WardrobeClothingItem? initialMustInclude;
  final List<WardrobeClothingItem> allWardrobeItems;
  final void Function({
    required String occasion,
    required String weather,
    String? colorPreference,
    String? vibe,
    WardrobeClothingItem? mustInclude,
  })
  onApply;

  @override
  State<OutfitFilterSheet> createState() => _OutfitFilterSheetState();
}

class _OutfitFilterSheetState extends State<OutfitFilterSheet> {
  late String _occasion;
  late String _weather;
  String? _colorPreference;
  String? _vibe;
  WardrobeClothingItem? _mustInclude;

  @override
  void initState() {
    super.initState();
    _occasion = widget.initialOccasion;
    _weather = widget.initialWeather;
    _colorPreference = widget.initialColorPreference;
    _vibe = widget.initialVibe;
    _mustInclude = widget.initialMustInclude;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.appHandleBar,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const Text(
              'Outfit Preferences',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.appEspresso,
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel(label: 'Occasion *'),
            _ChipSelector(
              options: _occasions,
              selected: _occasion,
              onSelect: (v) => setState(() => _occasion = v),
            ),
            const SizedBox(height: 16),

            _SectionLabel(label: 'Weather *'),
            _ChipSelector(
              options: _weathers,
              selected: _weather,
              onSelect: (v) => setState(() => _weather = v),
            ),
            const SizedBox(height: 16),

            _SectionLabel(label: 'Color preference (optional)'),
            _ChipSelector(
              options: _colors,
              selected: _colorPreference,
              onSelect: (v) => setState(
                () => _colorPreference = _colorPreference == v ? null : v,
              ),
              allowDeselect: true,
            ),
            const SizedBox(height: 16),

            _SectionLabel(label: 'Vibe (optional)'),
            _ChipSelector(
              options: _vibes,
              selected: _vibe,
              onSelect: (v) => setState(() => _vibe = _vibe == v ? null : v),
              allowDeselect: true,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  widget.onApply(
                    occasion: _occasion,
                    weather: _weather,
                    colorPreference: _colorPreference,
                    vibe: _vibe,
                    mustInclude: _mustInclude,
                  );
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.appEspresso,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Generate Outfits',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.appCream,
                    ),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textMain,
        ),
      ),
    );
  }
}

class _ChipSelector extends StatelessWidget {
  const _ChipSelector({
    required this.options,
    required this.selected,
    required this.onSelect,
    this.allowDeselect = false,
  });

  final List<String> options;
  final String? selected;
  final void Function(String) onSelect;
  final bool allowDeselect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected == opt;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.appEspresso : AppColors.appChipBg,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: isSelected
                    ? AppColors.appEspresso
                    : AppColors.appTan.withOpacity(0.5),
              ),
            ),
            child: Text(
              _display(opt),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.appCream : AppColors.textMain,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _display(String val) {
    if (val.isEmpty) return val;
    return val[0] + val.substring(1).toLowerCase().replaceAll('_', ' ');
  }
}
