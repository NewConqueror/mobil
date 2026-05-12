import 'package:flutter/foundation.dart';
import '../models/mood_entry.dart';
import '../models/mood.dart';
import '../models/custom_mood.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class MoodProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<MoodEntry> _entries = [];
  List<CustomMood> _customMoods = [];
  bool _isLoading = false;
  MoodEntry? _todayEntry;

  MoodProvider(this._storageService);

  // Getters
  List<MoodEntry> get entries => List.unmodifiable(_entries);
  List<CustomMood> get customMoods => List.unmodifiable(_customMoods);
  bool get isLoading => _isLoading;
  MoodEntry? get todayEntry => _todayEntry;

  bool get hasTodayEntry => _todayEntry != null;

  /// Initialize provider - load data from storage
  Future<void> initialize() async {
    await loadEntries();
    await loadCustomMoods();
  }

  /// Load all entries from storage
  Future<void> loadEntries() async {
    _setLoading(true);
    try {
      _entries = await _storageService.loadMoodEntries();
      _updateTodayEntry();
    } catch (e) {
      debugPrint('Error loading entries: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load custom moods from storage
  Future<void> loadCustomMoods() async {
    try {
      _customMoods = await _storageService.loadCustomMoods();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading custom moods: $e');
    }
  }

  /// Add a new custom mood
  Future<void> addCustomMood(CustomMood mood) async {
    try {
      await _storageService.addCustomMood(mood);
      await loadCustomMoods();
    } catch (e) {
      debugPrint('Error adding custom mood: $e');
      rethrow;
    }
  }

  /// Update a custom mood
  Future<void> updateCustomMood(CustomMood mood) async {
    try {
      await _storageService.updateCustomMood(mood);
      await loadCustomMoods();
    } catch (e) {
      debugPrint('Error updating custom mood: $e');
      rethrow;
    }
  }

  /// Delete a custom mood
  Future<void> deleteCustomMood(String moodId) async {
    try {
      await _storageService.deleteCustomMood(moodId);
      await loadCustomMoods();
    } catch (e) {
      debugPrint('Error deleting custom mood: $e');
      rethrow;
    }
  }

  /// Add a new mood entry or update existing one
  Future<void> addMoodEntry({
    required Mood mood,
    required String note,
    DateTime? date,
  }) async {
    await _addEntry(mood: mood, customMood: null, note: note, date: date);
  }

  /// Add a new custom mood entry or update existing one
  Future<void> addCustomMoodEntry({
    required CustomMood customMood,
    required String note,
    DateTime? date,
  }) async {
    await _addEntry(
      mood: Mood.neutral,
      customMood: customMood,
      note: note,
      date: date,
    );
  }

  Future<void> _addEntry({
    required Mood mood,
    CustomMood? customMood,
    required String note,
    DateTime? date,
  }) async {
    _setLoading(true);
    try {
      final entryDate = date ?? DateTime.now();
      final existingEntry = getEntryForDate(entryDate);

      if (existingEntry != null) {
        // Update existing entry
        final updatedEntry = MoodEntry(
          id: existingEntry.id,
          date: entryDate,
          mood: mood,
          customMood: customMood,
          note: note,
          moodSetAt: DateTime.now(), // Mood değiştirildiği zamanı kaydet
        );
        await _storageService.addMoodEntry(updatedEntry);
      } else {
        // Create new entry
        final entry = MoodEntry(
          id: '${entryDate.millisecondsSinceEpoch}',
          date: entryDate,
          mood: mood,
          customMood: customMood,
          note: note,
          moodSetAt: DateTime.now(),
        );
        await _storageService.addMoodEntry(entry);
      }

      await loadEntries(); // Reload to get updated list

      // Bildirimler yeniden planla - mood kaydedildiğinde bildirimleri güncelle
      try {
        final notificationService = NotificationService();
        await notificationService.rescheduleIfNeeded();
      } catch (e) {
        debugPrint('Error rescheduling notifications: $e');
      }
    } catch (e) {
      debugPrint('Error adding mood entry: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update only the note of an existing entry
  Future<void> updateNote({required String note, DateTime? date}) async {
    _setLoading(true);
    try {
      final entryDate = date ?? DateTime.now();
      final existingEntry = getEntryForDate(entryDate);

      if (existingEntry != null) {
        // Only update the note, keep mood and moodSetAt unchanged
        final updatedEntry = existingEntry.copyWith(note: note);
        await _storageService.addMoodEntry(updatedEntry);
        await loadEntries();
      } else {
        throw Exception('No entry found for the specified date');
      }
    } catch (e) {
      debugPrint('Error updating note: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if mood can be changed for a specific date
  bool canChangeMood(DateTime date) {
    final entry = getEntryForDate(date);
    return entry?.canChangeMoodToday ?? true;
  }

  /// Update an existing mood entry
  Future<void> updateMoodEntry(MoodEntry updatedEntry) async {
    _setLoading(true);
    try {
      await _storageService.addMoodEntry(
        updatedEntry,
      ); // Will replace existing entry
      await loadEntries();
    } catch (e) {
      debugPrint('Error updating mood entry: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a mood entry
  Future<void> deleteMoodEntry(String entryId) async {
    _setLoading(true);
    try {
      await _storageService.deleteMoodEntry(entryId);
      await loadEntries();
    } catch (e) {
      debugPrint('Error deleting mood entry: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Get entries for current week
  List<MoodEntry> getThisWeekEntries() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return _entries.where((entry) {
      final entryDate = entry.date;
      return entryDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          entryDate.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get mood statistics for current week
  Map<Mood, int> getWeeklyMoodStats() {
    final weekEntries = getThisWeekEntries();
    final moodCounts = <Mood, int>{};

    for (final mood in Mood.values) {
      moodCounts[mood] = 0;
    }

    for (final entry in weekEntries) {
      if (entry.customMood != null) continue;
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    return moodCounts;
  }

  /// Get entries grouped by date
  Map<DateTime, List<MoodEntry>> getEntriesGroupedByDate() {
    final groupedEntries = <DateTime, List<MoodEntry>>{};

    for (final entry in _entries) {
      final dateKey = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      if (!groupedEntries.containsKey(dateKey)) {
        groupedEntries[dateKey] = [];
      }
      groupedEntries[dateKey]!.add(entry);
    }

    return groupedEntries;
  }

  /// Get entry for specific date
  MoodEntry? getEntryForDate(DateTime date) {
    try {
      return _entries.firstWhere(
        (entry) =>
            entry.date.year == date.year &&
            entry.date.month == date.month &&
            entry.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get most frequent mood
  Mood? getMostFrequentMood() {
    if (_entries.isEmpty) return null;

    final moodCounts = <Mood, int>{};
    for (final entry in _entries) {
      if (entry.customMood != null) continue;
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    if (moodCounts.isEmpty) return null;

    return moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Get average mood for a period (simplified as most common)
  Mood? getAverageMoodForPeriod(DateTime startDate, DateTime endDate) {
    final periodEntries = _entries.where((entry) {
      return entry.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          entry.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    if (periodEntries.isEmpty) return null;

    final moodCounts = <Mood, int>{};
    for (final entry in periodEntries) {
      if (entry.customMood != null) continue;
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }

    if (moodCounts.isEmpty) return null;

    return moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Clear all data
  Future<void> clearAllData() async {
    _setLoading(true);
    try {
      await _storageService.clearAllData();
      _entries.clear();
      _todayEntry = null;
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update today's entry reference
  void _updateTodayEntry() {
    final today = DateTime.now();
    _todayEntry = getEntryForDate(today);
  }

  /// Set loading state
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }
}
