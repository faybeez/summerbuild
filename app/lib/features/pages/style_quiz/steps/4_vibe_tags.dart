import 'package:flutter/material.dart';
import '../../../../app_colors.dart';
import '../style_quiz_state.dart';

class VibeTagsStep extends StatelessWidget {
  final StyleQuizState state;
  final VoidCallback onChanged;

  const VibeTagsStep({super.key, required this.state, required this.onChanged});

  bool get _isAdvanced {
    final exp = state.experience;
    return exp == StyleExperienceLevel.confident ||
        exp == StyleExperienceLevel.advanced;
  }

  @override
  Widget build(BuildContext context) {
    final title = _isAdvanced
        ? 'Which words best describe your everyday aesthetic?'
        : 'Which of these vibes feels most like your everyday outfits?';

    final subtitle = _isAdvanced
        ? 'Pick up to 3. This helps us tailor your style recommendations.'
        : 'Select all that apply. This helps us tailor your style recommendations.';

    final options = _isAdvanced
        ? const <_VibeOption>[
            _VibeOption(
              value: 'Minimal',
              label: 'Minimal',
              icon: Icons.album_outlined,
            ),
            _VibeOption(
              value: 'Preppy',
              label: 'Preppy',
              icon: Icons.checkroom_outlined,
            ),
            _VibeOption(
              value: 'Romantic',
              label: 'Romantic',
              icon: Icons.favorite_border,
            ),
            _VibeOption(
              value: 'Streetwear',
              label: 'Streetwear',
              icon: Icons.bolt_outlined,
            ),
            _VibeOption(
              value: 'Vintage',
              label: 'Vintage',
              icon: Icons.camera_roll_outlined,
            ),
            _VibeOption(
              value: 'Trendy',
              label: 'Trendy',
              icon: Icons.auto_awesome_outlined,
            ),
          ]
        : const <_VibeOption>[
            _VibeOption(
              value: 'Comfortable',
              label: 'Comfortable',
              icon: Icons.weekend_outlined,
            ),
            _VibeOption(
              value: 'Classic',
              label: 'Classic',
              icon: Icons.checkroom_outlined,
            ),
            _VibeOption(
              value: 'Sporty',
              label: 'Sporty',
              icon: Icons.directions_run_outlined,
            ),
            _VibeOption(
              value: 'Soft',
              label: 'Soft',
              icon: Icons.favorite_border,
            ),
            _VibeOption(
              value: 'Playful',
              label: 'Playful',
              icon: Icons.celebration_outlined,
            ),
            _VibeOption(
              value: 'Polished',
              label: 'Polished',
              icon: Icons.workspace_premium_outlined,
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
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: TextStyle(color: AppColors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3 / 4,
          ),
          itemBuilder: (context, index) {
            final option = options[index];
            final selected = state.vibeTags.contains(option.value);

            return _VibeCard(
              option: option,
              selected: selected,
              onTap: () {
                if (selected) {
                  state.vibeTags.remove(option.value);
                } else {
                  state.vibeTags.add(option.value);
                }
                onChanged();
              },
            );
          },
        ),
      ],
    );
  }
}

class _VibeOption {
  final String value; // saved in state.vibeTags
  final String label;
  final IconData icon;

  const _VibeOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}

class _VibeCard extends StatelessWidget {
  final _VibeOption option;
  final bool selected;
  final VoidCallback onTap;

  const _VibeCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.appTerracotta : AppColors.border;
    final bgColor = selected
        ? const Color.fromARGB(255, 255, 238, 219)
        : AppColors.cardBackground;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(option.icon, color: AppColors.textMain, size: 60),
                  const SizedBox(height: 12),
                  Text(
                    option.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
