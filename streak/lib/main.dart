import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'services/storage_service.dart';
import 'services/streak_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'utils/streak_theme.dart';

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
    
    print('✅ Streak app initialized with advanced background notification system');
    
  } catch (e) {
    print('❌ Initialization error: $e');
    // Fallback storage service
    storageService ??= await StorageService.getInstance();
  }
  
  runApp(StreakApp(storageService: storageService));
}

class StreakApp extends StatelessWidget {
  final StorageService storageService;

  const StreakApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: StreakColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return ChangeNotifierProvider<StreakProvider>(
      create: (context) => StreakProvider(storageService),
      child: MaterialApp(
        title: 'Streak Takip',
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
        seedColor: StreakColors.primary,
        brightness: Brightness.light,
        primary: StreakColors.primary,
        secondary: StreakColors.accent,
        surface: StreakColors.surface,
      ),
      scaffoldBackgroundColor: StreakColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: StreakColors.primary,
        foregroundColor: StreakColors.textOnPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: StreakColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StreakSizes.radiusLg),
        ),
        shadowColor: StreakColors.shadow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: StreakColors.primary,
          foregroundColor: StreakColors.textOnPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StreakSizes.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: StreakSizes.paddingLg,
            vertical: StreakSizes.paddingMd,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: StreakColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StreakSizes.radiusMd),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StreakColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StreakSizes.radiusMd),
          borderSide: BorderSide(color: StreakColors.textLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StreakSizes.radiusMd),
          borderSide: BorderSide(color: StreakColors.textLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StreakSizes.radiusMd),
          borderSide: const BorderSide(color: StreakColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StreakSizes.radiusMd),
          borderSide: const BorderSide(color: StreakColors.streakDanger),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: StreakSizes.paddingMd,
          vertical: StreakSizes.paddingMd,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: StreakColors.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StreakSizes.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: StreakColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StreakSizes.radiusLg),
        ),
        elevation: 8,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: StreakColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(StreakSizes.radiusLg),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return StreakColors.accent;
          }
          return StreakColors.textLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return StreakColors.accent.withValues(alpha: 0.3);
          }
          return StreakColors.textLight.withValues(alpha: 0.3);
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: StreakColors.primary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: StreakColors.accent,
        foregroundColor: StreakColors.textOnPrimary,
        elevation: 4,
      ),
    );
  }
}
