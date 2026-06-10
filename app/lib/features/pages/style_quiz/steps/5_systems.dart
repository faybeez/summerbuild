import 'package:flutter/material.dart';
import '../../../../app_colors.dart';
import '../style_quiz_state.dart';

class SystemsStep extends StatelessWidget {
  final StyleQuizState state;
  final VoidCallback onChanged;

  const SystemsStep({super.key, required this.state, required this.onChanged});

  bool get _isAdvanced {
    final exp = state.experience;
    return exp == StyleExperienceLevel.confident ||
        exp == StyleExperienceLevel.advanced;
  }

  @override
  Widget build(BuildContext context) {
    final title = _isAdvanced
        ? 'Are you familiar with any of these style frameworks?'
        : 'Have you ever followed any style “systems” or rules?';

    final subtitle = _isAdvanced
        ? 'Select all that apply. This helps us personalize your recommendations.'
        : 'Select all that apply. This helps us understand how you think about style.';

    final options = _isAdvanced
        ? const <_SystemOption>[
            _SystemOption(
              value: 'seasonal_color',
              label: 'Seasonal color analysis (e.g. Soft Autumn, Cool Summer)',
              icon: Icons.palette_outlined,
            ),
            _SystemOption(
              value: 'capsule',
              label: 'Capsule wardrobe planning',
              icon: Icons.checkroom_outlined,
            ),
            _SystemOption(
              value: 'kibbe',
              label: 'Kibbe or body type systems',
              icon: Icons.self_improvement_outlined,
            ),
            _SystemOption(
              value: 'archetypes',
              label: 'Style archetypes (classic, romantic, dramatic, etc.)',
              icon: Icons.category_outlined,
            ),
            _SystemOption(
              value: 'none',
              label: 'None of these',
              icon: Icons.do_not_disturb_alt_outlined,
            ),
          ]
        : const <_SystemOption>[
            _SystemOption(
              value: 'social_media_tips',
              label: 'I’ve watched general style tips on social media',
              icon: Icons.play_circle_outline,
            ),
            _SystemOption(
              value: 'capsule',
              label: 'I’ve tried a capsule wardrobe or “basics” checklist',
              icon: Icons.checkroom_outlined,
            ),
            _SystemOption(
              value: 'color_charts',
              label: 'I’ve looked at color charts (what colors suit me)',
              icon: Icons.palette_outlined,
            ),
            _SystemOption(
              value: 'none',
              label: 'None of these',
              icon: Icons.do_not_disturb_alt_outlined,
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
        const SizedBox(height: 24),
        Column(
          children: options.map((option) {
            final selected = state.systems.contains(option.value);
            return _SystemCard(
              option: option,
              selected: selected,
              onTap: () {
                // Handle "none" special case
                if (option.value == 'none') {
                  if (selected) {
                    // unselect "none"
                    state.systems.remove('none');
                  } else {
                    state.systems
                      ..clear()
                      ..add('none');
                  }
                } else {
                  // selecting a specific system clears "none"
                  state.systems.remove('none');
                  if (selected) {
                    state.systems.remove(option.value);
                  } else {
                    state.systems.add(option.value);
                  }
                }
                onChanged();
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SystemOption {
  final String value; // what you save in state.systems
  final String label;
  final IconData icon;

  const _SystemOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}

class _SystemCard extends StatelessWidget {
  final _SystemOption option;
  final bool selected;
  final VoidCallback onTap;

  const _SystemCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = selected
        ? const Color.fromARGB(255, 255, 238, 219)
        : AppColors.cardBackground;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Icon in soft circle
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.appWarmCream,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    option.icon,
                    color: AppColors.appTerracotta,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option.label,
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Circular selection indicator
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColors.appTerracotta
                          : AppColors.border,
                      width: 2,
                    ),
                    color: selected
                        ? AppColors.appTerracotta
                        : Colors.transparent,
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
