import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'services/storage_service.dart';
import 'services/mood_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'utils/mood_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  StorageService? storageService;

  try {
    // Initialize locale data for intl
    await initializeDateFormatting('tr_TR', null);

    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize AlarmManager for exact alarms
    await AndroidAlarmManager.initialize();

    // Initialize services
    storageService = await StorageService.getInstance();

    // Initialize notification service with full background support
    final notificationService = NotificationService();
    await notificationService.initialize();
    await notificationService.requestPermissions();
    await notificationService.requestBatteryOptimizationExemption();
    await notificationService.rescheduleIfNeeded();

    print(
      '✅ Daily mood app initialized with advanced background notification system',
    );
  } catch (e) {
    print('❌ Initialization error: $e');
    // Fallback storage service
    storageService ??= await StorageService.getInstance();
  }

  runApp(MoodApp(storageService: storageService));
}

class MoodApp extends StatelessWidget {
  final StorageService storageService;

  const MoodApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: MoodColors.primaryBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return ChangeNotifierProvider<MoodProvider>(
      create: (context) => MoodProvider(storageService),
      child: MaterialApp(
        title: 'Ruh Hali Takibi',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MoodColors.accent,
        brightness: Brightness.light,
        surface: MoodColors.primaryBackground,
        onSurface: MoodColors.textPrimary,
      ),
      scaffoldBackgroundColor: MoodColors.primaryBackground,

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: MoodColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: MoodColors.textPrimary),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: MoodColors.cardBackground,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MoodColors.accent,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: MoodColors.accent.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MoodColors.accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MoodColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: MoodColors.textSecondary.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: MoodColors.textSecondary.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MoodColors.accent, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: TextStyle(color: MoodColors.textSecondary.withOpacity(0.7)),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: MoodColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(
          color: MoodColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: MoodColors.textSecondary,
          fontSize: 16,
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: MoodColors.accent,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: MoodColors.accent,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: MoodColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: TextStyle(
          color: MoodColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: TextStyle(
          color: MoodColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          color: MoodColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: MoodColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: MoodColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: MoodColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: MoodColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: MoodColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: MoodColors.textPrimary),
        bodyMedium: TextStyle(color: MoodColors.textPrimary),
        bodySmall: TextStyle(color: MoodColors.textSecondary),
        labelLarge: TextStyle(
          color: MoodColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: MoodColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: MoodColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Font family (Optional - you can set a custom font here)
      fontFamily: 'System',
    );
  }
}
