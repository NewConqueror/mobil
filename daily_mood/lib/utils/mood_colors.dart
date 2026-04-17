import 'package:flutter/material.dart';
import '../models/mood.dart';

class MoodColors {
  static const Map<Mood, Color> _moodColors = {
    Mood.happy: Color(0xFFFFE082),      // Açık sarı
    Mood.sad: Color(0xFF90CAF9),        // Açık mavi
    Mood.angry: Color(0xFFEF9A9A),      // Açık kırmızı
    Mood.calm: Color(0xFFA5D6A7),       // Açık yeşil
    Mood.tired: Color(0xFFCE93D8),      // Açık mor
    Mood.excited: Color(0xFFFFAB91),    // Açık turuncu
    Mood.anxious: Color(0xFFF8BBD9),    // Açık pembe
    Mood.neutral: Color(0xFFE0E0E0),    // Gri
  };

  static Color getColor(Mood mood) {
    return _moodColors[mood] ?? _moodColors[Mood.neutral]!;
  }

  static Color getPrimaryColor(Mood mood) {
    return getColor(mood).withOpacity(0.7);
  }

  static Color getSecondaryColor(Mood mood) {
    return getColor(mood).withOpacity(0.3);
  }

  // App theme colors
  static const Color primaryBackground = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color accent = Color(0xFF667EEA);
}

extension ColorExtensions on Color {
  Color get lighten => Color.lerp(this, Colors.white, 0.5) ?? this;
  Color get darken => Color.lerp(this, Colors.black, 0.2) ?? this;
}
