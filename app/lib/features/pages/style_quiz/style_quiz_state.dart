import 'package:flutter/material.dart';

enum StyleExperienceLevel { beginner, emerging, confident, advanced }

class StyleQuizState {
  StyleExperienceLevel? experience;
  String? experienceDetail;
  String? vibeBeginner;
  Set<String> vibeAdvanced;
  String? colorGroup;
  String? fitPreference;
  Set<String> systems;
  Set<String> goals;

  StyleQuizState({
    this.experience,
    this.experienceDetail,
    this.vibeBeginner,
    Set<String>? vibeAdvanced,
    this.colorGroup,
    this.fitPreference,
    Set<String>? systems,
    Set<String>? goals,
  }) : vibeAdvanced = vibeAdvanced ?? <String>{},
       systems = systems ?? <String>{},
       goals = goals ?? <String>{};

  int get totalSteps => 7;
}
