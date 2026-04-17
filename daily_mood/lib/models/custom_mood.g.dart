// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_mood.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomMood _$CustomMoodFromJson(Map<String, dynamic> json) => CustomMood(
      id: json['id'] as String,
      emoji: json['emoji'] as String,
      displayName: json['displayName'] as String,
      colorValue: (json['colorValue'] as num).toInt(),
    );

Map<String, dynamic> _$CustomMoodToJson(CustomMood instance) =>
    <String, dynamic>{
      'id': instance.id,
      'emoji': instance.emoji,
      'displayName': instance.displayName,
      'colorValue': instance.colorValue,
    };
