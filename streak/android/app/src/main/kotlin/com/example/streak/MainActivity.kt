package com.example.streak

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            // Streak reminder channel
            val reminderChannel = NotificationChannel(
                "streak_reminder",
                "Streak Hatırlatıcısı",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Günlük streak takibi için hatırlatıcı bildirimler"
                enableVibration(true)
                setSound(null, null)
            }

            // Immediate notifications channel
            val immediateChannel = NotificationChannel(
                "streak_immediate",
                "Anlık Bildirimler",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Anlık streak bildirimleri"
                enableVibration(true)
            }

            // High priority channel
            val highPriorityChannel = NotificationChannel(
                "streak_high_priority",
                "Streak Yüksek Öncelik",
                NotificationManager.IMPORTANCE_MAX
            ).apply {
                description = "Önemli streak hatırlatmaları"
                enableVibration(true)
                enableLights(true)
            }

            // Background service channel
            val backgroundChannel = NotificationChannel(
                "streak_background_service",
                "Streak Arka Plan Servisi",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Streak takibi arka plan servisi"
                enableVibration(false)
                setSound(null, null)
            }

            notificationManager.createNotificationChannel(reminderChannel)
            notificationManager.createNotificationChannel(immediateChannel)
            notificationManager.createNotificationChannel(highPriorityChannel)
            notificationManager.createNotificationChannel(backgroundChannel)
        }
    }
}
