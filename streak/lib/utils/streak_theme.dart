import 'package:flutter/material.dart';

class StreakColors {
  // Ana renkler
  static const Color primary = Color(0xFF1565C0); // Mavi
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color accent = Color(0xFFFF6B35); // Turuncu
  static const Color accentLight = Color(0xFFFF8A50);
  
  // Arka plan renkleri
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F4);
  
  // Streak renkleri
  static const Color streakSuccess = Color(0xFF4CAF50); // Yeşil
  static const Color streakWarning = Color(0xFFFF9800); // Amber
  static const Color streakDanger = Color(0xFFF44336); // Kırmızı
  static const Color streakFire = Color(0xFFFF5722); // Ateş kırmızısı
  
  // Metin renkleri
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Colors.white;
  
  // İkon renkleri
  static const Color iconPrimary = Color(0xFF424242);
  static const Color iconSecondary = Color(0xFF9E9E9E);
  static const Color iconSuccess = Color(0xFF4CAF50);
  static const Color iconWarning = Color(0xFFFF9800);
  static const Color iconDanger = Color(0xFFF44336);
  
  // Gölge renkleri
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  
  // Durum renkleri
  static const Color completed = Color(0xFF4CAF50);
  static const Color failed = Color(0xFFF44336);
  static const Color pending = Color(0xFF9E9E9E);
  
  // Gradient'lar
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [streakSuccess, Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient fireGradient = LinearGradient(
    colors: [streakFire, Color(0xFFFF7043)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class StreakTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: StreakColors.textPrimary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: StreakColors.textPrimary,
    letterSpacing: -0.25,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: StreakColors.textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: StreakColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: StreakColors.textSecondary,
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: StreakColors.textLight,
    height: 1.3,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: StreakColors.textSecondary,
  );
  
  static const TextStyle streakNumber = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: StreakColors.streakFire,
    letterSpacing: -1,
  );
}

class StreakSizes {
  // Padding
  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;
  static const double paddingXl = 32.0;
  
  // Margin
  static const double marginXs = 4.0;
  static const double marginSm = 8.0;
  static const double marginMd = 16.0;
  static const double marginLg = 24.0;
  static const double marginXl = 32.0;
  
  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 50.0;
  
  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
}

extension StreakThemeExtension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
