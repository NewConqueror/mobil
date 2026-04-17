# Flutter ProGuard rules for Daily Mood App

# Keep Flutter framework classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugin.** { *; }

# Keep notification classes
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class androidx.work.** { *; }
-keep class android.app.AlarmManager { *; }

# Keep timezone data
-keep class org.threeten.bp.** { *; }
-keep class java.time.** { *; }

# Keep shared preferences
-keep class android.content.SharedPreferences** { *; }

# Keep JSON serialization classes
-keepattributes *Annotation*
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep chart library classes
-keep class com.github.mikephil.charting.** { *; }

# Standard Android optimizations
-keepclassmembers class * extends android.app.Activity {
    public void *(android.view.View);
}

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Minimize generated code
-allowaccessmodification
-optimizationpasses 5
-overloadaggressively
-repackageclasses ''
