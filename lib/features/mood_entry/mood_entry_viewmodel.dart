import 'package:flutter/material.dart';
import 'package:my_app/app/app.locator.dart';
import 'package:my_app/app/app.router.dart';
import 'package:my_app/models/mood_entry.dart';
import 'package:my_app/services/mood_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class MoodEntryViewModel extends BaseViewModel {
  final _moodService = locator<MoodService>();
  final _navigationService = locator<NavigationService>();

  // Mood selection state
  String _selectedEmoji = '😊';
  String get selectedEmoji => _selectedEmoji;

  String _moodText = 'Happy';
  String get moodText => _moodText;

  String _note = '';
  String get note => _note;

  // Color selection
  HSLColor _selectedColor =
      HSLColor.fromAHSL(1.0, 120, 0.7, 0.5); // Default green
  Color get selectedColor => _selectedColor.toColor();
  double get hue => _selectedColor.hue;

  // Common moods with emojis and colors
  final List<Map<String, dynamic>> moodOptions = [
    {
      'emoji': '😊',
      'text': 'Happy',
      'hue': 120.0, // Green
    },
    {
      'emoji': '😔',
      'text': 'Sad',
      'hue': 240.0, // Blue
    },
    {
      'emoji': '😡',
      'text': 'Angry',
      'hue': 0.0, // Red
    },
    {
      'emoji': '😌',
      'text': 'Calm',
      'hue': 180.0, // Teal
    },
    {
      'emoji': '😴',
      'text': 'Tired',
      'hue': 270.0, // Purple
    },
    {
      'emoji': '🙂',
      'text': 'Content',
      'hue': 90.0, // Yellow-Green
    },
    {
      'emoji': '😬',
      'text': 'Stressed',
      'hue': 30.0, // Orange
    },
    {
      'emoji': '🤔',
      'text': 'Thoughtful',
      'hue': 210.0, // Light blue
    },
  ];

  void selectMood(String emoji, String text, double hue) {
    _selectedEmoji = emoji;
    _moodText = text;
    _selectedColor = HSLColor.fromAHSL(1.0, hue, 0.7, 0.5);
    notifyListeners();
  }

  void updateHue(double hue) {
    _selectedColor = HSLColor.fromAHSL(
      1.0,
      hue,
      _selectedColor.saturation,
      _selectedColor.lightness,
    );
    notifyListeners();
  }

  void updateMoodText(String text) {
    _moodText = text;
    notifyListeners();
  }

  void updateNote(String value) {
    _note = value;
  }

  Future<void> saveMoodEntry() async {
    setBusy(true);

    try {
      final moodEntry = MoodEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        emoji: _selectedEmoji,
        mood: _moodText,
        note: _note.isNotEmpty ? _note : null,
        colorHue: _selectedColor.hue,
        colorSaturation: _selectedColor.saturation,
        colorLightness: _selectedColor.lightness,
      );

      await _moodService.addMoodEntry(moodEntry);
      await _navigationService.clearStackAndShow(Routes.homeView);
    } catch (e) {
      setError('Failed to save mood entry: ${e.toString()}');
    } finally {
      setBusy(false);
    }
  }
}
