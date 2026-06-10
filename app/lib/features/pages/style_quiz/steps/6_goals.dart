import 'package:flutter/material.dart';
import '../../../../app_colors.dart';
import '../style_quiz_state.dart';

class GoalsStep extends StatelessWidget {
  final StyleQuizState state;
  final VoidCallback onChanged;

  const GoalsStep({super.key, required this.state, required this.onChanged});

  bool get _isAdvanced {
    final exp = state.experience;
    return exp == StyleExperienceLevel.confident ||
        exp == StyleExperienceLevel.advanced;
  }

  @override
  Widget build(BuildContext context) {
    final title = _isAdvanced
        ? 'What are your main style goals?'
        : 'What do you want most from your style?';

    final subtitle = _isAdvanced
        ? 'Choose all that apply.'
        : 'Choose all that apply. This helps us prioritise what you see first.';

    final options = _isAdvanced
        ? const <_GoalOption>[
            _GoalOption(
              value: 'signature_look',
              label: 'Refine a clear “signature” look',
              icon: Icons.auto_awesome_outlined,
            ),
            _GoalOption(
              value: 'versatile_wardrobe',
              label: 'Build a tighter, more versatile wardrobe',
              icon: Icons.folder_special_outlined,
            ),
            _GoalOption(
              value: 'experiment_silhouettes',
              label: 'Experiment with new silhouettes or trends',
              icon: Icons.explore_outlined,
            ),
            _GoalOption(
              value: 'align_with_analysis',
              label: 'Align my outfits with my color/fit analysis',
              icon: Icons.palette_outlined,
            ),
            _GoalOption(
              value: 'faster_mornings',
              label: 'Make outfits faster to choose each morning',
              icon: Icons.access_time_outlined,
            ),
          ]
        : const <_GoalOption>[
            _GoalOption(
              value: 'look_put_together',
              label: 'Look more put‑together day‑to‑day',
              icon: Icons.star_border,
            ),
            _GoalOption(
              value: 'easier_dressing',
              label: 'Make getting dressed easier',
              icon: Icons.access_time_outlined,
            ),
            _GoalOption(
              value: 'have_fun',
              label: 'Try new things and have fun',
              icon: Icons.celebration_outlined,
            ),
            _GoalOption(
              value: 'use_what_i_own',
              label: 'Use what I already own more',
              icon: Icons.checkroom_outlined,
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
            final selected = state.goals.contains(option.value);
            return _GoalCard(
              option: option,
              selected: selected,
              onTap: () {
                if (selected) {
                  state.goals.remove(option.value);
                } else {
                  state.goals.add(option.value);
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

class _GoalOption {
  final String value;
  final String label;
  final IconData icon;

  const _GoalOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}

class _GoalCard extends StatelessWidget {
  final _GoalOption option;
  final bool selected;
  final VoidCallback onTap;

  const _GoalCard({
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
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
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
