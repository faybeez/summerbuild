import 'package:flutter/material.dart';
import '../../../app_colors.dart';
import 'style_quiz_state.dart';
import 'steps/style_quiz_intro.dart';
import 'steps/experience.dart';
// import 'steps/step_experience_detail.dart';
// import 'steps/step_vibe.dart';
// import 'steps/step_color.dart';
// import 'steps/step_fit.dart';
// import 'steps/step_systems.dart';
// import 'steps/step_goals.dart';

class StyleQuizPage extends StatefulWidget {
  const StyleQuizPage({super.key});

  @override
  State<StyleQuizPage> createState() => _StyleQuizPageState();
}

class _StyleQuizPageState extends State<StyleQuizPage> {
  final StyleQuizState _quizState = StyleQuizState();
  int _stepIndex = 0;

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

  void _finishQuiz() {
    // TODO: send _quizState to backend/local storage, then navigate
    debugPrint('Quiz done: ${_quizState.experience} | ${_quizState.goals}');
    Navigator.pop(context);
  }

  double get _progress => (_stepIndex) / (_quizState.totalSteps).toDouble();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 6,
              backgroundColor: AppColors.cardBackground,
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
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
      // case 2:
      //   return VibeStep(
      //     state: _quizState,
      //     onChanged: () => setState(() {}),
      //   );
      // case 3:
      //   return ColorStep(
      //     state: _quizState,
      //     onChanged: () => setState(() {}),
      //   );
      // case 4:
      //   return FitStep(
      //     state: _quizState,
      //     onChanged: () => setState(() {}),
      //   );
      // case 5:
      //   return SystemsStep(
      //     state: _quizState,
      //     onChanged: () => setState(() {}),
      //   );
      // case 6:
      //   return GoalsStep(
      //     state: _quizState,
      //     onChanged: () => setState(() {}),
      //   );
      default:
        return const SizedBox.shrink();
    }
  }
}
