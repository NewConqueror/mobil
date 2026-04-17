import 'package:json_annotation/json_annotation.dart';

part 'custom_mood.g.dart';

@JsonSerializable()
class CustomMood {
  final String id;
  final String emoji;
  final String displayName;
  final int colorValue; // Color as int for storage

  CustomMood({
    required this.id,
    required this.emoji,
    required this.displayName,
    required this.colorValue,
  });

  factory CustomMood.fromJson(Map<String, dynamic> json) =>
      _$CustomMoodFromJson(json);
  Map<String, dynamic> toJson() => _$CustomMoodToJson(this);

  CustomMood copyWith({
    String? id,
    String? emoji,
    String? displayName,
    int? colorValue,
  }) {
    return CustomMood(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      displayName: displayName ?? this.displayName,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomMood && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
