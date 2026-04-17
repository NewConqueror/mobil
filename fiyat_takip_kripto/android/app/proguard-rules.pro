# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Flutter Local News
-keep class com.dexterous.** { *; }

# Foreground Service
-keep class com.pravera.flutter_foreground_task.** { *; }

# HTTP
-keepattributes *Annotation*
-keepclassmembers class * {
    @retrofit2.http.* <methods>;
}

# Redmi 10 optimizasyonu için
-dontwarn okio.**
-dontwarn retrofit2.**
-dontwarn rx.**

# Kotlin
-keep class kotlin.** { *; }
-keep class org.jetbrains.** { *; }

# AndroidX
-keep class androidx.** { *; }
-keep interface androidx.** { *; }

# Notification
-keep class * extends android.app.Service
-keep class * extends android.content.BroadcastReceiver
