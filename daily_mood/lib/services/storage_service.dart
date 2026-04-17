import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_entry.dart';
import '../models/custom_mood.dart';

class StorageService {
  static const String _moodEntriesKey = 'mood_entries';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _backgroundServiceEnabledKey =
      'background_service_enabled';
  static const String _customMoodsKey = 'custom_moods';
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// Save all mood entries to local storage
  Future<void> saveMoodEntries(List<MoodEntry> entries) async {
    final entriesJson = entries.map((entry) => entry.toJson()).toList();
    final entriesString = jsonEncode(entriesJson);
    await _prefs!.setString(_moodEntriesKey, entriesString);
  }

  /// Load all mood entries from local storage
  Future<List<MoodEntry>> loadMoodEntries() async {
    try {
      final entriesString = _prefs!.getString(_moodEntriesKey);
      if (entriesString == null) return [];

      final entriesJson = jsonDecode(entriesString) as List;
      return entriesJson
          .map((json) => MoodEntry.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading mood entries: $e');
      return [];
    }
  }

  /// Add a new mood entry
  Future<void> addMoodEntry(MoodEntry entry) async {
    final entries = await loadMoodEntries();

    // Remove existing entry for the same date if exists
    entries.removeWhere(
      (e) =>
          e.date.year == entry.date.year &&
          e.date.month == entry.date.month &&
          e.date.day == entry.date.day,
    );

    entries.add(entry);
    entries.sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending

    await saveMoodEntries(entries);
  }

  /// Get mood entry for a specific date
  Future<MoodEntry?> getMoodEntryForDate(DateTime date) async {
    final entries = await loadMoodEntries();
    try {
      return entries.firstWhere(
        (entry) =>
            entry.date.year == date.year &&
            entry.date.month == date.month &&
            entry.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  /// Delete a mood entry
  Future<void> deleteMoodEntry(String entryId) async {
    final entries = await loadMoodEntries();
    entries.removeWhere((entry) => entry.id == entryId);
    await saveMoodEntries(entries);
  }

  /// Get mood entries for a date range
  Future<List<MoodEntry>> getMoodEntriesInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final entries = await loadMoodEntries();
    return entries.where((entry) {
      final entryDate = entry.date;
      return entryDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          entryDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get entries for the current week
  Future<List<MoodEntry>> getThisWeekEntries() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return await getMoodEntriesInRange(
      DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
    );
  }

  /// Clear all data
  Future<void> clearAllData() async {
    await _prefs!.remove(_moodEntriesKey);
  }

  /// Get notifications enabled setting
  Future<bool> getNotificationsEnabled() async {
    return _prefs!.getBool(_notificationsEnabledKey) ?? false;
  }

  /// Set notifications enabled setting
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs!.setBool(_notificationsEnabledKey, enabled);
  }

  /// Get background service enabled setting
  Future<bool> getBackgroundServiceEnabled() async {
    return _prefs!.getBool(_backgroundServiceEnabledKey) ?? false;
  }

  /// Set background service enabled setting
  Future<void> setBackgroundServiceEnabled(bool enabled) async {
    await _prefs!.setBool(_backgroundServiceEnabledKey, enabled);
  }

  /// Save custom moods to local storage
  Future<void> saveCustomMoods(List<CustomMood> moods) async {
    final moodsJson = moods.map((mood) => mood.toJson()).toList();
    final moodsString = jsonEncode(moodsJson);
    await _prefs!.setString(_customMoodsKey, moodsString);
  }

  /// Load custom moods from local storage
  Future<List<CustomMood>> loadCustomMoods() async {
    try {
      final moodsString = _prefs!.getString(_customMoodsKey);
      if (moodsString == null) return [];

      final moodsJson = jsonDecode(moodsString) as List;
      return moodsJson
          .map((json) => CustomMood.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading custom moods: $e');
      return [];
    }
  }

  /// Add a new custom mood
  Future<void> addCustomMood(CustomMood mood) async {
    final moods = await loadCustomMoods();
    // Remove existing mood with same id if exists
    moods.removeWhere((m) => m.id == mood.id);
    moods.add(mood);
    await saveCustomMoods(moods);
  }

  /// Update a custom mood
  Future<void> updateCustomMood(CustomMood mood) async {
    final moods = await loadCustomMoods();
    final index = moods.indexWhere((m) => m.id == mood.id);
    if (index != -1) {
      moods[index] = mood;
      await saveCustomMoods(moods);
    }
  }

  /// Delete a custom mood
  Future<void> deleteCustomMood(String moodId) async {
    final moods = await loadCustomMoods();
    moods.removeWhere((m) => m.id == moodId);
    await saveCustomMoods(moods);
  }
}
