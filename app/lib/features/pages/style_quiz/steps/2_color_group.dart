import 'package:flutter/material.dart';
import '../../../../app_colors.dart';
import '../style_quiz_state.dart';
import '../../../widgets/inputs.dart';

class ColorGroupStep extends StatelessWidget {
  final StyleQuizState state;
  final VoidCallback onChanged;

  const ColorGroupStep({
    super.key,
    required this.state,
    required this.onChanged,
  });

  bool get _isAdvanced {
    final exp = state.experience;
    return exp == StyleExperienceLevel.confident ||
        exp == StyleExperienceLevel.advanced;
  }

  @override
  Widget build(BuildContext context) {
    final title = _isAdvanced
        ? 'Which best describes your usual color palette?'
        : 'Which group of colors do you usually reach for in your clothes?';

    final subtitle = _isAdvanced
        ? 'Think about the colors you actually wear most days.'
        : 'Pick the colors that show up most in your wardrobe.';

    final options = _isAdvanced
        ? <_ColorOption>[
            _ColorOption(
              value: 'Neutrals',
              label: 'Neutral‑heavy',
              swatch: [
                const Color(0xFFE9DFD0),
                const Color(0xFFF7F0E3),
                const Color(0xFFB9B1A5),
                const Color(0xFF4C4A47),
              ],
            ),
            _ColorOption(
              value: 'Soft / pastel',
              label: 'Soft & muted',
              swatch: [
                const Color(0xffffadad),
                const Color(0xFFFDFFB6),
                const Color(0xFFCAFFBF),
                const Color(0xFF9BF6FF),
              ],
            ),
            _ColorOption(
              value: 'Bright',
              label: 'Bright & saturated',
              swatch: [
                const Color(0xFFF26B4F),
                const Color(0xFFF2C23D),
                const Color(0xFF1FB5A5),
                const Color(0xFF297BE6),
              ],
            ),
            _ColorOption(
              value: 'Dark / rich',
              label: 'Deep & rich',
              swatch: [
                const Color(0xFF0F2944),
                const Color(0xFF154734),
                const Color(0xFF4B1E2A),
                const Color(0xFF141414),
              ],
            ),
          ]
        : <_ColorOption>[
            _ColorOption(
              value: 'Neutrals',
              label: 'Mostly neutrals',
              swatch: [
                const Color(0xFFE9DFD0),
                const Color(0xFFF7F0E3),
                const Color(0xFFB9B1A5),
                const Color(0xFF4C4A47),
              ],
            ),
            _ColorOption(
              value: 'Soft / pastel',
              label: 'Soft, light colors',
              swatch: [
                const Color(0xffffadad),
                const Color(0xFFFDFFB6),
                const Color(0xFFCAFFBF),
                const Color(0xFF9BF6FF),
              ],
            ),
            _ColorOption(
              value: 'Bright',
              label: 'Bright, bold colors',
              swatch: [
                const Color(0xFFF26B4F),
                const Color(0xFFF2C23D),
                const Color(0xFF1FB5A5),
                const Color(0xFF297BE6),
              ],
            ),
            _ColorOption(
              value: 'Dark / rich',
              label: 'Dark, rich colors',
              swatch: [
                const Color(0xFF0F2944),
                const Color(0xFF154734),
                const Color(0xFF4B1E2A),
                const Color(0xFF141414),
              ],
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(color: AppColors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 36),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final option = options[index];
            final selected = state.colorGroup == option.value;

            return SelectableCard(
              selected: selected,
              onTap: () {
                state.colorGroup = option.value;
                onChanged();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ColorSwatchRow(colors: option.swatch),
                  const SizedBox(height: 8),
                  Text(
                    option.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? AppColors.primary : AppColors.textMain,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ColorOption {
  final String value;
  final String label;
  final List<Color> swatch;

  const _ColorOption({
    required this.value,
    required this.label,
    required this.swatch,
  });
}

class _ColorSwatchRow extends StatelessWidget {
  final List<Color> colors;

  const _ColorSwatchRow({required this.colors});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 6.0;
        final count = colors.length;
        final totalGap = gap * (count - 1);
        final swatchWidth = (constraints.maxWidth - totalGap) / count;

        return Row(
          children: [
            for (int i = 0; i < count; i++)
              Container(
                margin: EdgeInsets.only(right: i == count - 1 ? 0 : gap),
                width: swatchWidth,
                height: 80,
                decoration: BoxDecoration(
                  color: colors[i],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        );
      },
    );
  }
}
