import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../utils/mood_colors.dart';

extension MoodEntryDisplay on MoodEntry {
  bool get isCustomMood => customMood != null;

  String get displayName => customMood?.displayName ?? mood.displayName;

  String get emoji => customMood?.emoji ?? mood.emoji;

  Color get color {
    if (customMood != null) {
      return Color(customMood!.colorValue);
    }
    return MoodColors.getColor(mood);
  }

  Color get primaryColor {
    if (customMood != null) {
      return Color(customMood!.colorValue).withOpacity(0.7);
    }
    return MoodColors.getPrimaryColor(mood);
  }

  Color get secondaryColor {
    if (customMood != null) {
      return Color(customMood!.colorValue).withOpacity(0.3);
    }
    return MoodColors.getSecondaryColor(mood);
  }
}
