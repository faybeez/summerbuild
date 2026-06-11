import 'package:flutter/material.dart';
import '../../../../app_colors.dart';
import '../style_quiz_state.dart';
import '../../../widgets/inputs.dart';

import 'package:flutter_svg/flutter_svg.dart';

class StyleQuizIntro extends StatelessWidget {
  final StyleQuizState state;
  final VoidCallback onChanged;
  final VoidCallback increaseStep;

  const StyleQuizIntro({
    super.key,
    required this.state,
    required this.onChanged,
    required this.increaseStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: SvgPicture.asset(
            'assets/hanger_logo.svg',
            width: 300,
            height: 300,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Let\'s find your style!',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppColors.textMain,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Answer a few quick questions to help us understand your style preferences and goals.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textMuted,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              increaseStep();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appEspresso,
              foregroundColor: Colors.white,
              elevation: 0, // Flat design with no shadow
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            child: const Text(
              'Start style profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Secondary Underlined Button
        TextButton(
          onPressed: () {
            // Add your action here
          },
          style: TextButton.styleFrom(
            // Removes default padding to keep the underline tight to the text
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Skip for now',
            style: TextStyle(
              color: AppColors.appEspresso,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.appEspresso,
            ),
          ),
        ),
      ],
    );
  }
}
