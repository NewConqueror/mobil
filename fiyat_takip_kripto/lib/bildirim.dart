import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    
    // Bildirim kanalı oluştur
    await _createNotificationChannel();
  }

  static Future<void> _createNotificationChannel() async {
    // Ana kanal
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'crypto_price_channel',
      'Kripto Para Fiyat Bildirimleri',
      description: 'Kripto para fiyat uyarıları için bildirimler',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );

    // Xiaomi/Redmi için yüksek öncelikli kanal
    const AndroidNotificationChannel highPriorityChannel = AndroidNotificationChannel(
      'crypto_high_priority',
      'Kripto Yüksek Öncelik',
      description: 'Kritik kripto para uyarıları',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      showBadge: true,
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    await androidPlugin?.createNotificationChannel(channel);
    await androidPlugin?.createNotificationChannel(highPriorityChannel);
  }

  static Future<void> showPriceAlert({
    required String coinSymbol,
    required String coinName,
    required double currentPrice,
    required double threshold,
  }) async {
    // Xiaomi/Redmi için optimize edilmiş bildirim ayarları
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'crypto_high_priority',
      'Kripto Yüksek Öncelik',
      channelDescription: 'Kritik kripto para uyarıları',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      autoCancel: false,
      ongoing: false,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Bildirim metni formatla - kısa ve öz
    final String title = '� $coinSymbol Uyarı';
    final String body = 'Fiyat: \$${currentPrice.toStringAsFixed(2)}\nHedef: \$${threshold.toStringAsFixed(2)}';

    await flutterLocalNotificationsPlugin.show(
      coinSymbol.hashCode, // Her coin için unique ID
      title,
      body,
      platformChannelSpecifics,
    );
  }

  static Future<void> showServiceNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'crypto_price_channel',
      'Kripto Para Fiyat Bildirimleri',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      999, // Service notification ID
      title,
      body,
      platformChannelSpecifics,
    );
  }
}

// Geriye uyumluluk için
Future<void> initNotifications() async {
  await NotificationService.initNotifications();
}

Future<void> showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'crypto_price_channel',
    'Kripto Para Fiyat Bildirimleri',
    importance: Importance.high,
    priority: Priority.high,
  );
  
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
      
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
  );
}
