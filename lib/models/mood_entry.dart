import 'package:flutter/material.dart';

class MoodEntry {
  final String id;
  final DateTime timestamp;
  final String emoji;
  final String mood;
  final String? note;
  final double colorHue;
  final double colorSaturation;
  final double colorLightness;

  MoodEntry({
    required this.id,
    required this.timestamp,
    required this.emoji,
    required this.mood,
    this.note,
    required this.colorHue,
    this.colorSaturation = 0.7,
    this.colorLightness = 0.5,
  });

  // Get the color from HSL values
  Color get color => HSLColor.fromAHSL(
        1.0,
        colorHue,
        colorSaturation,
        colorLightness,
      ).toColor();

  // Create a copy with optional updated fields
  MoodEntry copyWith({
    String? id,
    DateTime? timestamp,
    String? emoji,
    String? mood,
    String? note,
    double? colorHue,
    double? colorSaturation,
    double? colorLightness,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      emoji: emoji ?? this.emoji,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      colorHue: colorHue ?? this.colorHue,
      colorSaturation: colorSaturation ?? this.colorSaturation,
      colorLightness: colorLightness ?? this.colorLightness,
    );
  }

  // Convert to and from JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'emoji': emoji,
      'mood': mood,
      'note': note,
      'colorHue': colorHue,
      'colorSaturation': colorSaturation,
      'colorLightness': colorLightness,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      emoji: json['emoji'],
      mood: json['mood'],
      note: json['note'],
      colorHue: json['colorHue'],
      colorSaturation: json['colorSaturation'],
      colorLightness: json['colorLightness'],
    );
  }

  @override
  String toString() {
    return 'MoodEntry(id: $id, timestamp: $timestamp, emoji: $emoji, mood: $mood)';
  }
}
