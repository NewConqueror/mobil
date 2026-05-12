import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/streak.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Keys
  static const String _streaksKey = 'streaks';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _backgroundServiceEnabledKey = 'background_service_enabled';

  // Streaks
  Future<List<Streak>> getStreaks() async {
    try {
      final String? streaksJson = _prefs?.getString(_streaksKey);
      if (streaksJson == null) return [];

      final List<dynamic> decoded = json.decode(streaksJson);
      return decoded.map((e) => Streak.fromJson(e)).toList();
    } catch (e) {
      print('Error loading streaks: $e');
      return [];
    }
  }

  Future<bool> saveStreaks(List<Streak> streaks) async {
    try {
      final String encoded = json.encode(streaks.map((e) => e.toJson()).toList());
      return await _prefs?.setString(_streaksKey, encoded) ?? false;
    } catch (e) {
      print('Error saving streaks: $e');
      return false;
    }
  }

  Future<bool> addStreak(Streak streak) async {
    final streaks = await getStreaks();
    streaks.add(streak);
    return await saveStreaks(streaks);
  }

  Future<bool> updateStreak(Streak updatedStreak) async {
    final streaks = await getStreaks();
    final index = streaks.indexWhere((s) => s.id == updatedStreak.id);
    if (index != -1) {
      streaks[index] = updatedStreak;
      return await saveStreaks(streaks);
    }
    return false;
  }

  Future<bool> deleteStreak(String streakId) async {
    final streaks = await getStreaks();
    streaks.removeWhere((s) => s.id == streakId);
    return await saveStreaks(streaks);
  }

  // Notifications
  Future<bool> getNotificationsEnabled() async {
    final value = _prefs?.getBool(_notificationsEnabledKey);
    if (value == null) {
      await _prefs?.setBool(_notificationsEnabledKey, true);
      return true;
    }
    return value;
  }

  Future<bool> setNotificationsEnabled(bool enabled) async {
    return await _prefs?.setBool(_notificationsEnabledKey, enabled) ?? false;
  }

  // Background Service
  Future<bool> getBackgroundServiceEnabled() async {
    return _prefs?.getBool(_backgroundServiceEnabledKey) ?? false;
  }

  Future<bool> setBackgroundServiceEnabled(bool enabled) async {
    return await _prefs?.setBool(_backgroundServiceEnabledKey, enabled) ?? false;
  }

  // Clear all data
  Future<bool> clearAllData() async {
    try {
      await _prefs?.clear();
      return true;
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }
}
