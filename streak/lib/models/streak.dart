class Streak {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final int currentStreak;
  final int bestStreak;
  final List<StreakEntry> entries;
  final bool isActive;

  Streak({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.currentStreak,
    required this.bestStreak,
    required this.entries,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'entries': entries.map((e) => e.toJson()).toList(),
      'isActive': isActive,
    };
  }

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      currentStreak: json['currentStreak'],
      bestStreak: json['bestStreak'],
      entries: (json['entries'] as List?)
          ?.map((e) => StreakEntry.fromJson(e))
          .toList() ?? [],
      isActive: json['isActive'] ?? true,
    );
  }

  Streak copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    int? currentStreak,
    int? bestStreak,
    List<StreakEntry>? entries,
    bool? isActive,
  }) {
    return Streak(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      entries: entries ?? this.entries,
      isActive: isActive ?? this.isActive,
    );
  }
}

class StreakEntry {
  final DateTime date;
  final bool completed;
  final String? failureReason;

  StreakEntry({
    required this.date,
    required this.completed,
    this.failureReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'completed': completed,
      'failureReason': failureReason,
    };
  }

  factory StreakEntry.fromJson(Map<String, dynamic> json) {
    return StreakEntry(
      date: DateTime.parse(json['date']),
      completed: json['completed'],
      failureReason: json['failureReason'],
    );
  }

  StreakEntry copyWith({
    DateTime? date,
    bool? completed,
    String? failureReason,
  }) {
    return StreakEntry(
      date: date ?? this.date,
      completed: completed ?? this.completed,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}
