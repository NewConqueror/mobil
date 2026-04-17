import 'package:json_annotation/json_annotation.dart';
import 'mood.dart';

part 'mood_entry.g.dart';

@JsonSerializable()
class MoodEntry {
  final String id;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime date;
  @JsonKey(fromJson: _moodFromJson, toJson: _moodToJson)
  final Mood mood;
  final String note;
  @JsonKey(fromJson: _dateTimeFromJsonNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? moodSetAt; // Ruh hali ne zaman seçildi

  MoodEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.note,
    this.moodSetAt,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) => _$MoodEntryFromJson(json);
  Map<String, dynamic> toJson() => _$MoodEntryToJson(this);

  MoodEntry copyWith({
    String? id,
    DateTime? date,
    Mood? mood,
    String? note,
    DateTime? moodSetAt,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      moodSetAt: moodSetAt ?? this.moodSetAt,
    );
  }

  // Helper method to check if mood can be changed today
  bool get canChangeMoodToday {
    if (moodSetAt == null) return true;
    final now = DateTime.now();
    final moodSetDate = DateTime(moodSetAt!.year, moodSetAt!.month, moodSetAt!.day);
    final today = DateTime(now.year, now.month, now.day);
    return !moodSetDate.isAtSameMomentAs(today);
  }

  // Helper method to get date without time
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // JSON conversion helpers
  static DateTime _dateTimeFromJson(String dateString) {
    return DateTime.parse(dateString);
  }

  static String _dateTimeToJson(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  static DateTime? _dateTimeFromJsonNullable(String? dateString) {
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  static String? _dateTimeToJsonNullable(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }

  static Mood _moodFromJson(String moodString) {
    return Mood.fromString(moodString);
  }

  static String _moodToJson(Mood mood) {
    return mood.value;
  }
}
