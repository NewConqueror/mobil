import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'storage_service.dart';

const String _notificationsEnabledKey = 'notifications_enabled';
const String _backgroundServiceEnabledKey = 'background_service_enabled';

Future<bool> _isBackgroundSchedulingEnabled() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? false;
    final backgroundEnabled = prefs.getBool(_backgroundServiceEnabledKey) ?? false;
    return notificationsEnabled && backgroundEnabled;
  } catch (e) {
    print('⚠️ Background state read failed in alarm isolate: $e');
    return true;
  }
}

Future<void> _rescheduleAlarmForNextDay(int alarmId) async {
  final hour = alarmId - 100;
  if (hour < 8 || hour > 23) {
    return;
  }

  final now = DateTime.now();
  var nextAlarmTime = DateTime(now.year, now.month, now.day, hour, 0, 0);
  if (!nextAlarmTime.isAfter(now)) {
    nextAlarmTime = nextAlarmTime.add(const Duration(days: 1));
  }

  await AndroidAlarmManager.oneShotAt(
    nextAlarmTime,
    alarmId,
    alarmCallback,
    exact: true,
    wakeup: true,
    rescheduleOnReboot: true,
    allowWhileIdle: true,
  );
}

// Top-level function for AlarmManager callback
@pragma('vm:entry-point')
Future<void> alarmCallback(int alarmId) async {
  print('AlarmManager callback executed at ${DateTime.now()} for id=$alarmId');

  try {
    final shouldRun = await _isBackgroundSchedulingEnabled();
    if (!shouldRun) {
      await AndroidAlarmManager.cancel(alarmId);
      print('ℹ️ Alarm $alarmId cancelled because background scheduling is disabled');
      return;
    }

    // Initialize timezone
    tzdata.initializeTimeZones();

    final now = DateTime.now();
    if (now.hour >= 8 && now.hour <= 23) {
      // Random streak reminder messages
      final List<String> streakMessages = [
        'Streaklerini unutma! 🔥',
        'Bugünün hedeflerini tamamladın mı? ⚡',
        'Streak zincirini kırma! 💪',
        'Hedeflerine odaklan! 🎯',
        'Her gün biraz daha ilerle! 🚀',
        'Alışkanlıklarını güçlendir! ⭐',
        'Kendine verdiğin sözü tut! 🤝',
        'Disiplin özgürlüktür! 🗽',
      ];

      final randomMessage = streakMessages[now.millisecond % streakMessages.length];

      await _showBackgroundNotification(
        title: '⏰ Saatlik Hatırlatma',
        body: randomMessage,
      );
      print('✅ AlarmManager notification sent at $now');
    }

    await _rescheduleAlarmForNextDay(alarmId);
  } catch (e) {
    print('❌ AlarmManager callback error: $e');
  }
}

// Top-level function to show notification from background
Future<void> _showBackgroundNotification({
  required String title,
  required String body,
}) async {
  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );

  await plugin.initialize(initSettings);

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'streak_reminder_channel',
    'Streak Hatırlatmaları',
    channelDescription: 'Günlük streak takibi için bildirimleri',
    importance: Importance.max,
    priority: Priority.max,
    showWhen: true,
    enableVibration: true,
    playSound: true,
    enableLights: true,
    autoCancel: true,
    category: AndroidNotificationCategory.reminder,
    visibility: NotificationVisibility.public,
    icon: '@mipmap/ic_launcher',
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await plugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    notificationDetails,
  );
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;
  bool _isBackgroundServiceRunning = false;
  StorageService? _storageService;

  bool get isBackgroundServiceRunning => _isBackgroundServiceRunning;

  Future<bool> getBackgroundServiceEnabled() async {
    _storageService ??= await StorageService.getInstance();
    return await _storageService!.getBackgroundServiceEnabled();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize storage service
      _storageService = await StorageService.getInstance();

      // Initialize timezone
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channels
      await _createNotificationChannel();

      // Initialize AlarmManager
      await AndroidAlarmManager.initialize();

      _isInitialized = true;
      print('✅ Streak notification service initialized with AlarmManager');

      final notificationsEnabled =
          await _storageService!.getNotificationsEnabled();
      if (!notificationsEnabled) {
        await cancelAllScheduledNotifications();
        if (_isBackgroundServiceRunning) {
          await stopBackgroundService();
        }
        print('ℹ️ Notifications are disabled, skipping startup scheduling');
        return;
      }

      // Check if background service should be running
      final backgroundEnabled = await _storageService!
          .getBackgroundServiceEnabled();
      if (backgroundEnabled) {
        await startBackgroundService();
      }

      // Always schedule exact notifications as fallback when notifications are enabled
      await scheduleExactDailyNotifications();
    } catch (e) {
      print('❌ Error initializing notification service: $e');
      _isInitialized = true;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel mainChannel = AndroidNotificationChannel(
      'streak_reminder_channel',
      'Streak Hatırlatmaları',
      description: 'Günlük streak takibi için bildirimleri',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );

    const AndroidNotificationChannel highPriorityChannel =
        AndroidNotificationChannel(
          'streak_high_priority',
          'Streak Yüksek Öncelik',
          description: 'Önemli streak hatırlatmaları',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          showBadge: true,
        );

    const AndroidNotificationChannel backgroundChannel =
        AndroidNotificationChannel(
          'streak_background_service',
          'Streak Arka Plan Servisi',
          description: 'Streak takibi arka plan servisi bildirimleri',
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
          enableLights: false,
          showBadge: false,
        );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(mainChannel);
    await androidPlugin?.createNotificationChannel(highPriorityChannel);
    await androidPlugin?.createNotificationChannel(backgroundChannel);

    print('✅ Notification channels created');
  }

  Future<bool> requestPermissions() async {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final bool? granted = await androidPlugin?.requestNotificationsPermission();
    print('Notification permissions granted: $granted');
    return granted ?? false;
  }

  /// Schedule exact notifications using zonedSchedule with matchDateTimeComponents
  /// These will fire even if the app is closed
  Future<void> scheduleExactDailyNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!await areNotificationsEnabled()) {
      print('ℹ️ Skipping schedule because notifications are disabled');
      return;
    }

    // Cancel existing scheduled notifications first
    await cancelAllScheduledNotifications();

    print('📅 Scheduling exact daily notifications for 8:00-23:00...');

    final now = tz.TZDateTime.now(tz.local);

    // Schedule for each hour from 8 AM to 11 PM
    for (int hour = 8; hour <= 23; hour++) {
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        0,
      );

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'streak_high_priority',
            'Streak Yüksek Öncelik',
            channelDescription: 'Önemli streak hatırlatmaları',
            importance: Importance.max,
            priority: Priority.max,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            enableLights: true,
            autoCancel: true,
            category: AndroidNotificationCategory.reminder,
            visibility: NotificationVisibility.public,
            icon: '@mipmap/ic_launcher',
            fullScreenIntent: true,
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        hour, // Unique ID for each hour
        '🔥 Streak Kontrolü',
        'Streaklerini kontrol etmeyi unutma! Bugünün hedeflerini tamamla! 💪',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents:
            DateTimeComponents.time, // Repeat daily at same time
      );

      print('  ✅ Scheduled for ${hour.toString().padLeft(2, '0')}:00');
    }

    print('📅 Successfully scheduled ${23 - 8 + 1} daily notifications');
  }

  /// Start background service using AlarmManager for periodic tasks
  Future<void> startBackgroundService() async {
    if (_isBackgroundServiceRunning) {
      print('⚠️ Background service already running');
      return;
    }

    if (!await areNotificationsEnabled()) {
      print('ℹ️ Background service start skipped because notifications are disabled');
      return;
    }

    _storageService ??= await StorageService.getInstance();

    try {
      // Set up AlarmManager for exact hourly alarms
      final now = DateTime.now();
      for (int hour = 8; hour <= 23; hour++) {
        var alarmTime = DateTime(now.year, now.month, now.day, hour, 0, 0);
        if (alarmTime.isBefore(now)) {
          alarmTime = alarmTime.add(const Duration(days: 1));
        }

        await AndroidAlarmManager.oneShotAt(
          alarmTime,
          hour + 100, // Unique ID (100-123 for hours 8-23)
          alarmCallback,
          exact: true,
          wakeup: true,
          rescheduleOnReboot: true,
          allowWhileIdle: true,
        );
        print('  ✅ AlarmManager set for ${hour.toString().padLeft(2, '0')}:00');
      }

      // Also schedule using zonedSchedule as fallback
      await scheduleExactDailyNotifications();

      await _storageService!.setBackgroundServiceEnabled(true);
      _isBackgroundServiceRunning = true;

      // Show persistent notification
      await _showPersistentNotification();

      print(
        '✅ Background notification service started with dual-layer protection',
      );
    } catch (e) {
      print('❌ Error starting background service: $e');
      rethrow;
    }
  }

  /// Stop background service
  Future<void> stopBackgroundService() async {
    if (!_isBackgroundServiceRunning) return;

    _storageService ??= await StorageService.getInstance();

    try {
      // Cancel AlarmManager alarms
      for (int hour = 8; hour <= 23; hour++) {
        await AndroidAlarmManager.cancel(hour + 100);
      }
      print('✅ AlarmManager alarms cancelled');

      // Cancel scheduled notifications
      await cancelAllScheduledNotifications();

      await _storageService!.setBackgroundServiceEnabled(false);
      _isBackgroundServiceRunning = false;

      // Hide persistent notification
      await _hidePersistentNotification();

      print('✅ Background notification service stopped');
    } catch (e) {
      print('❌ Error stopping background service: $e');
    }
  }

  /// Toggle background service
  Future<void> toggleBackgroundService() async {
    _storageService ??= await StorageService.getInstance();
    final isEnabled = await _storageService!.getBackgroundServiceEnabled();
    if (_isBackgroundServiceRunning || isEnabled) {
      await stopBackgroundService();
    } else {
      await startBackgroundService();
    }
  }

  /// Show persistent notification for background service
  Future<void> _showPersistentNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'streak_background_service',
          'Streak Arka Plan Servisi',
          channelDescription: 'Streak takibi arka planda çalışıyor',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      9999,
      '🔥 Streak Takibi Aktif',
      'Arka planda çalışıyor - Saatlik bildirimler (08:00-23:00)',
      notificationDetails,
    );
  }

  /// Hide persistent notification
  Future<void> _hidePersistentNotification() async {
    await flutterLocalNotificationsPlugin.cancel(9999);
  }

  /// Show immediate notification
  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'streak_reminder_channel',
          'Streak Hatırlatmaları',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllScheduledNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print('✅ All scheduled notifications cancelled');
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print('✅ Notification $id cancelled');
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    final pending = await flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    print('📋 Pending notifications: ${pending.length}');
    return pending;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    _storageService ??= await StorageService.getInstance();
    return await _storageService!.getNotificationsEnabled();
  }

  /// Set notifications enabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    _storageService ??= await StorageService.getInstance();
    await _storageService!.setNotificationsEnabled(enabled);

    if (enabled) {
      await scheduleExactDailyNotifications();

      final backgroundEnabled =
          await _storageService!.getBackgroundServiceEnabled();
      if (backgroundEnabled && !_isBackgroundServiceRunning) {
        await startBackgroundService();
      }
    } else {
      await cancelAllScheduledNotifications();
      if (_isBackgroundServiceRunning) {
        await stopBackgroundService();
      } else {
        await _storageService!.setBackgroundServiceEnabled(false);
      }
    }
  }

  /// Reschedule notifications if needed (called on app startup)
  Future<void> rescheduleIfNeeded() async {
    final notificationsEnabled = await areNotificationsEnabled();
    if (!notificationsEnabled) {
      await cancelAllScheduledNotifications();
      if (_isBackgroundServiceRunning) {
        await stopBackgroundService();
      }
      print('ℹ️ Notifications disabled, skipped reschedule');
      return;
    }

    final pending = await getPendingNotifications();

    if (pending.length < 8) {
      print(
        '⚠️ Low pending notifications (${pending.length}), rescheduling...',
      );
      await scheduleExactDailyNotifications();

      // Also restart background service if it was enabled
      final backgroundEnabled =
          await _storageService?.getBackgroundServiceEnabled() ?? false;
      if (backgroundEnabled && !_isBackgroundServiceRunning) {
        await startBackgroundService();
      }
    } else {
      print('✅ Notifications properly scheduled: ${pending.length} pending');
    }
  }

  /// Test notification
  Future<void> testNotification() async {
    await showImmediateNotification(
      title: '🔥 Test Bildirimi',
      body: 'Gelişmiş bildirim sistemi düzgün çalışıyor! 🎉',
    );
  }

  /// Request battery optimization exemption
  Future<void> requestBatteryOptimizationExemption() async {
    try {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      // Request exact alarm permission (Android 12+)
      await androidPlugin?.requestExactAlarmsPermission();

      print('✅ Battery optimization exemption requested');
    } catch (e) {
      print('❌ Error requesting battery optimization: $e');
    }
  }
}
