import 'package:flutter/material.dart';
import '../../../../app_colors.dart';
import '../style_quiz_state.dart';
import '../../../widgets/inputs.dart'; // SelectableCard

class FitPreferenceStep extends StatelessWidget {
  final StyleQuizState state;
  final VoidCallback onChanged;

  const FitPreferenceStep({
    super.key,
    required this.state,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const options = <_FitOption>[
      _FitOption(
        value: 'Loose / relaxed',
        label: 'Loose',
        assetPath: 'assets/loose_model.png',
      ),
      _FitOption(
        value: 'Skimming, not tight',
        label: 'Skimming',
        assetPath: 'assets/fitted_model.png',
      ),
      _FitOption(
        value: 'Fitted / body-hugging',
        label: 'Fitted',
        assetPath: 'assets/tight_model.png',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How do you like clothes to sit on your body?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Imagine your favourite everyday outfit.',
          style: TextStyle(color: AppColors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            for (int i = 0; i < options.length; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: _FitCard(
                    option: options[i],
                    selected: state.fitPreference == options[i].value,
                    onTap: () {
                      state.fitPreference = options[i].value;
                      onChanged();
                    },
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FitOption {
  final String value;
  final String label;
  final String assetPath;

  const _FitOption({
    required this.value,
    required this.label,
    required this.assetPath,
  });
}

class _FitCard extends StatelessWidget {
  final _FitOption option;
  final bool selected;
  final VoidCallback onTap;

  const _FitCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.6 / 8,
      child: SelectableCard(
        horizontalPadding: 0,
        verticalPadding: 6,
        selected: selected,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: ClipRRect(
                child: Image.asset(option.assetPath, fit: BoxFit.fitHeight),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              option.label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textMain,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
