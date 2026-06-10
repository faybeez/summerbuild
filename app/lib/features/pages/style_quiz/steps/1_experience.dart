import 'package:flutter/material.dart';
import '../../../../app_colors.dart';
import '../style_quiz_state.dart';
import '../../../widgets/inputs.dart';

extension StyleExperienceLabel on StyleExperienceLevel {
  String get label {
    switch (this) {
      case StyleExperienceLevel.beginner:
        return 'I don’t really think about it';
      case StyleExperienceLevel.emerging:
        return 'I have some ideas but feel unsure';
      case StyleExperienceLevel.confident:
        return 'I roughly know what I like';
      case StyleExperienceLevel.advanced:
        return 'I know my style terms and references';
    }
  }
}

class ExperienceStep extends StatelessWidget {
  final StyleQuizState state;
  final VoidCallback onChanged;

  const ExperienceStep({
    super.key,
    required this.state,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How comfortable are you with style?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us decide how detailed your questions should be.',
          style: TextStyle(color: AppColors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 36),
        ...StyleExperienceLevel.values.map((level) {
          final selected = state.experience == level;
          return SelectableCard(
            label: level.label,
            selected: selected,
            onTap: () {
              state.experience = level;
              onChanged();
            },
          );
        }),
      ],
    );
  }
}
