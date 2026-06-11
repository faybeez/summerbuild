import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app_colors.dart';
import 'style_quiz_state.dart';
import 'steps/0_style_quiz_intro.dart';
import 'steps/1_experience.dart';
import 'steps/2_color_group.dart';
import 'steps/3_fit_preference.dart';
import 'steps/4_vibe_tags.dart';
import 'steps/5_systems.dart';
import 'steps/6_goals.dart';

class StyleQuizPage extends StatefulWidget {
  const StyleQuizPage({super.key});

  @override
  State<StyleQuizPage> createState() => _StyleQuizPageState();
}

class _StyleQuizPageState extends State<StyleQuizPage> {
  final StyleQuizState _quizState = StyleQuizState();
  int _stepIndex = 0;

  bool get _isCurrentStepValid {
    switch (_stepIndex) {
      case 0:
        return true;
      case 1:
        return _quizState.experience != null;
      case 2:
        return _quizState.colorGroup != null &&
            _quizState.colorGroup!.isNotEmpty;
      case 3:
        return _quizState.fitPreference != null &&
            _quizState.fitPreference!.isNotEmpty;
      case 4:
        return _quizState.vibeTags.isNotEmpty;
      case 5:
        return _quizState.systems.isNotEmpty;
      case 6:
        return _quizState.goals.isNotEmpty;
      default:
        return false;
    }
  }

  void _next() {
    if (_stepIndex < _quizState.totalSteps - 1) {
      setState(() => _stepIndex++);
    } else {
      _finishQuiz();
    }
  }

  void _back() {
    if (_stepIndex > 0) {
      setState(() => _stepIndex--);
    }
  }

  void _finishQuiz() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      context.go('/login');
      return;
    }

    final rawQuiz = {
      'experience': _quizState.experience?.name,
      'color_group': _quizState.colorGroup,
      'fit_preference': _quizState.fitPreference,
      'vibe_tags': _quizState.vibeTags.toList(),
      'systems': _quizState.systems.toList(),
      'goals': _quizState.goals.toList(),
    };

    final payload = {'user_id': user.id, ...rawQuiz, 'raw_quiz': rawQuiz};

    try {
      await client.from('style_profiles').upsert(payload);

      if (!mounted) return;
      context.go('/home');
    } catch (error, stack) {
      debugPrint('Error saving style profile: $error\n$stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong saving your style profile.'),
        ),
      );
    }
  }

  double get _progress => (_stepIndex) / (_quizState.totalSteps).toDouble();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(children: _buildIntroOrStep()),
        ),
      ),
    );
  }

  List<Widget> _buildIntroOrStep() {
    switch (_stepIndex) {
      case 0:
        return [
          Expanded(
            child: StyleQuizIntro(
              state: _quizState,
              onChanged: () => setState(() {}),
              increaseStep: _next,
            ),
          ),
        ];
      default:
        return [
          Text(
            'Step ${_stepIndex} of ${_quizState.totalSteps - 1}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 6,
              backgroundColor: AppColors.appOlive.withAlpha(60),
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 36),
          Expanded(child: _buildStep()),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_stepIndex > 0)
                TextButton(
                  onPressed: _back,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                  ),
                  child: const Text('Back'),
                )
              else
                const SizedBox(width: 72),
              const Spacer(),
              IntrinsicWidth(
                child: ElevatedButton(
                  onPressed: _isCurrentStepValid ? _next : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCurrentStepValid
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _stepIndex == _quizState.totalSteps - 1 ? 'Finish' : 'Next',
                  ),
                ),
              ),
            ],
          ),
        ];
    }
  }

  Widget _buildStep() {
    switch (_stepIndex) {
      case 0:
        return StyleQuizIntro(
          state: _quizState,
          onChanged: () => setState(() {}),
          increaseStep: _next,
        );
      case 1:
        return ExperienceStep(
          state: _quizState,
          onChanged: () => setState(() {}),
        );
      case 2:
        return ColorGroupStep(
          state: _quizState,
          onChanged: () => setState(() {}),
        );
      case 3:
        return FitPreferenceStep(
          state: _quizState,
          onChanged: () => setState(() {}),
        );
      case 4:
        return VibeTagsStep(
          state: _quizState,
          onChanged: () => setState(() {}),
        );
      case 5:
        return SystemsStep(state: _quizState, onChanged: () => setState(() {}));
      case 6:
        return GoalsStep(state: _quizState, onChanged: () => setState(() {}));
      default:
        return const SizedBox.shrink();
    }
  }
}
