import 'package:flutter/material.dart';

enum StyleExperienceLevel { beginner, emerging, confident, advanced }

class StyleQuizState {
  StyleExperienceLevel? experience;
  Set<String> vibeTags;
  String? colorGroup;
  String? fitPreference;
  Set<String> systems;
  Set<String> goals;

  StyleQuizState({
    this.experience,
    Set<String>? vibeTags,
    this.colorGroup,
    this.fitPreference,
    Set<String>? systems,
    Set<String>? goals,
  }) : vibeTags = vibeTags ?? <String>{},
       systems = systems ?? <String>{},
       goals = goals ?? <String>{};

  int get totalSteps => 7; // hidden intro + experience + 5 qns
}
