// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoodEntry _$MoodEntryFromJson(Map<String, dynamic> json) => MoodEntry(
  id: json['id'] as String,
  date: MoodEntry._dateTimeFromJson(json['date'] as String),
  mood: MoodEntry._moodFromJson(json['mood'] as String),
  note: json['note'] as String,
  moodSetAt: MoodEntry._dateTimeFromJsonNullable(json['moodSetAt'] as String?),
);

Map<String, dynamic> _$MoodEntryToJson(MoodEntry instance) => <String, dynamic>{
  'id': instance.id,
  'date': MoodEntry._dateTimeToJson(instance.date),
  'mood': MoodEntry._moodToJson(instance.mood),
  'note': instance.note,
  'moodSetAt': MoodEntry._dateTimeToJsonNullable(instance.moodSetAt),
};
