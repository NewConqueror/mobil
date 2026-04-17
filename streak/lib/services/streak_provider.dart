import 'package:flutter/foundation.dart';
import '../models/streak.dart';
import 'storage_service.dart';

class StreakProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<Streak> _streaks = [];
  bool _isLoading = false;

  StreakProvider(this._storageService) {
    _loadStreaks();
  }

  List<Streak> get streaks => _streaks;
  bool get isLoading => _isLoading;
  
  List<Streak> get activeStreaks => _streaks.where((s) => s.isActive).toList();

  Future<void> _loadStreaks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _streaks = await _storageService.getStreaks();
    } catch (e) {
      print('Error loading streaks: $e');
      _streaks = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addStreak({
    required String title,
    required String description,
  }) async {
    final newStreak = Streak(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      startDate: DateTime.now(),
      currentStreak: 0,
      bestStreak: 0,
      entries: [],
    );

    final success = await _storageService.addStreak(newStreak);
    if (success) {
      _streaks.add(newStreak);
      notifyListeners();
    }
    return success;
  }

  Future<bool> markDay({
    required String streakId,
    required DateTime date,
    required bool completed,
    String? failureReason,
  }) async {
    final streakIndex = _streaks.indexWhere((s) => s.id == streakId);
    if (streakIndex == -1) return false;

    final streak = _streaks[streakIndex];
    final entries = List<StreakEntry>.from(streak.entries);
    
    // Remove existing entry for this date if any
    entries.removeWhere((e) => 
      e.date.year == date.year && 
      e.date.month == date.month && 
      e.date.day == date.day
    );
    
    // Add new entry
    final newEntry = StreakEntry(
      date: date,
      completed: completed,
      failureReason: failureReason,
    );
    entries.add(newEntry);
    
    // Sort entries by date
    entries.sort((a, b) => a.date.compareTo(b.date));
    
    // Calculate new streak
    final newStreak = _calculateStreak(entries);
    final newBestStreak = newStreak > streak.bestStreak ? newStreak : streak.bestStreak;
    
    final updatedStreak = streak.copyWith(
      entries: entries,
      currentStreak: newStreak,
      bestStreak: newBestStreak,
    );

    final success = await _storageService.updateStreak(updatedStreak);
    if (success) {
      _streaks[streakIndex] = updatedStreak;
      notifyListeners();
    }
    return success;
  }

  int _calculateStreak(List<StreakEntry> entries) {
    if (entries.isEmpty) return 0;
    
    // Sort by date descending (newest first)
    final sortedEntries = entries.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    
    int currentStreak = 0;
    DateTime? lastDate;
    final today = DateTime.now();
    
    for (final entry in sortedEntries) {
      // Skip if not completed
      if (!entry.completed) {
        // If this is the first entry we're checking and it's today or yesterday, streak is broken
        if (lastDate == null) {
          final daysDiff = today.difference(entry.date).inDays;
          if (daysDiff <= 1) {
            break; // Streak broken by recent failure
          }
          continue; // Skip older failures
        }
        break; // Any failure in the chain breaks the streak
      }
      
      if (lastDate == null) {
        // First completed entry
        final daysDiff = today.difference(entry.date).inDays;
        if (daysDiff <= 1) { // Today or yesterday
          currentStreak = 1;
          lastDate = entry.date;
        } else {
          break; // Too old to start streak
        }
      } else {
        // Check if this entry is exactly 1 day before the last one
        final expectedDate = lastDate!.subtract(const Duration(days: 1));
        if (entry.date.year == expectedDate.year && 
            entry.date.month == expectedDate.month && 
            entry.date.day == expectedDate.day) {
          currentStreak++;
          lastDate = entry.date;
        } else {
          break; // Gap in streak
        }
      }
    }
    
    return currentStreak;
  }

  bool hasEntryForDate(String streakId, DateTime date) {
    final streak = _streaks.firstWhere(
      (s) => s.id == streakId,
      orElse: () => Streak(
        id: '',
        title: '',
        description: '',
        startDate: DateTime.now(),
        currentStreak: 0,
        bestStreak: 0,
        entries: [],
      ),
    );
    
    return streak.entries.any((e) => 
      e.date.year == date.year && 
      e.date.month == date.month && 
      e.date.day == date.day
    );
  }

  StreakEntry? getEntryForDate(String streakId, DateTime date) {
    final streak = _streaks.firstWhere(
      (s) => s.id == streakId,
      orElse: () => Streak(
        id: '',
        title: '',
        description: '',
        startDate: DateTime.now(),
        currentStreak: 0,
        bestStreak: 0,
        entries: [],
      ),
    );
    
    try {
      return streak.entries.firstWhere((e) => 
        e.date.year == date.year && 
        e.date.month == date.month && 
        e.date.day == date.day
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteStreak(String streakId) async {
    final success = await _storageService.deleteStreak(streakId);
    if (success) {
      _streaks.removeWhere((s) => s.id == streakId);
      notifyListeners();
    }
    return success;
  }

  Future<bool> updateStreak(Streak updatedStreak) async {
    final success = await _storageService.updateStreak(updatedStreak);
    if (success) {
      final index = _streaks.indexWhere((s) => s.id == updatedStreak.id);
      if (index != -1) {
        _streaks[index] = updatedStreak;
        notifyListeners();
      }
    }
    return success;
  }

  Future<void> refreshStreaks() async {
    await _loadStreaks();
  }

  List<StreakEntry> getRecentEntries(String streakId, {int days = 7}) {
    final streak = _streaks.firstWhere(
      (s) => s.id == streakId,
      orElse: () => Streak(
        id: '',
        title: '',
        description: '',
        startDate: DateTime.now(),
        currentStreak: 0,
        bestStreak: 0,
        entries: [],
      ),
    );
    
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: days));
    
    return streak.entries
        .where((e) => e.date.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double getStreakCompletionRate(String streakId, {int days = 30}) {
    final entries = getRecentEntries(streakId, days: days);
    if (entries.isEmpty) return 0.0;
    
    final completedCount = entries.where((e) => e.completed).length;
    return completedCount / entries.length;
  }
}
