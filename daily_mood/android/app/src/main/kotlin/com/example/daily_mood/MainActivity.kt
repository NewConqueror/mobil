package com.example.daily_mood

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

            // Mood reminder channel
            val reminderChannel = NotificationChannel(
                "mood_reminder",
                "Ruh Hali Hatırlatıcısı",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Günlük ruh hali takibi için hatırlatıcı bildirimler"
                enableVibration(true)
                setSound(null, null)
            }

            // Immediate notifications channel
            val immediateChannel = NotificationChannel(
                "mood_immediate",
                "Anlık Bildirimler",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Anlık ruh hali bildirimleri"
                enableVibration(true)
            }

            notificationManager.createNotificationChannel(reminderChannel)
            notificationManager.createNotificationChannel(immediateChannel)
        }
    }
}
