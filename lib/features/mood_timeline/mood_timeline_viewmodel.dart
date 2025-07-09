import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/app/app.locator.dart';
import 'package:my_app/models/mood_entry.dart';
import 'package:my_app/services/mood_service.dart';
import 'package:stacked/stacked.dart';

class MoodTimelineViewModel extends BaseViewModel {
  final _moodService = locator<MoodService>();

  // Current date range for timeline
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  // Mood entries within date range
  List<MoodEntry> _moodEntries = [];
  List<MoodEntry> get moodEntries => _moodEntries;

  // Date formatters
  final _dateFormatter = DateFormat('MMM d');
  final _timeFormatter = DateFormat('h:mm a');
  final _monthYearFormatter = DateFormat('MMMM yyyy');

  String get timeRangeText {
    return '${_dateFormatter.format(_startDate)} - ${_dateFormatter.format(_endDate)}';
  }

  Future<void> loadMoodEntries() async {
    clearErrors();
    setBusy(true);

    try {
      _moodEntries = await _moodService.getMoodEntriesByDateRange(
        _startDate,
        _endDate,
      );
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  void previousWeek() {
    _startDate = _startDate.subtract(const Duration(days: 7));
    _endDate = _endDate.subtract(const Duration(days: 7));
    loadMoodEntries();
  }

  void nextWeek() {
    final now = DateTime.now();

    // Don't go beyond today
    if (_endDate.isAfter(now)) {
      return;
    }

    _startDate = _startDate.add(const Duration(days: 7));
    _endDate = _endDate.add(const Duration(days: 7));

    // If the new end date is in the future, adjust to today
    if (_endDate.isAfter(now)) {
      _endDate = DateTime(now.year, now.month, now.day);
      _startDate = _endDate.subtract(const Duration(days: 7));
    }

    loadMoodEntries();
  }

  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    loadMoodEntries();
  }

  String formatEntryTime(MoodEntry entry) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (isSameDay(entry.timestamp, now)) {
      return '${_timeFormatter.format(entry.timestamp)} · Today';
    } else if (isSameDay(entry.timestamp, yesterday)) {
      return '${_timeFormatter.format(entry.timestamp)} · Yesterday';
    } else {
      return '${_timeFormatter.format(entry.timestamp)} · ${_dateFormatter.format(entry.timestamp)}';
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Get mood entries grouped by date
  Map<DateTime, List<MoodEntry>> getMoodEntriesByDay() {
    final Map<DateTime, List<MoodEntry>> entriesByDay = {};

    for (final entry in _moodEntries) {
      final date = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      if (!entriesByDay.containsKey(date)) {
        entriesByDay[date] = [];
      }

      entriesByDay[date]!.add(entry);
    }

    return entriesByDay;
  }

  // Get the average mood color for a specific day
  Color? getAverageMoodColorForDay(DateTime day) {
    final entriesForDay = _moodEntries
        .where((entry) =>
            entry.timestamp.year == day.year &&
            entry.timestamp.month == day.month &&
            entry.timestamp.day == day.day)
        .toList();

    if (entriesForDay.isEmpty) {
      return null;
    }

    // Calculate average hue
    double totalHue = 0;
    for (final entry in entriesForDay) {
      totalHue += entry.colorHue;
    }

    final averageHue = totalHue / entriesForDay.length;
    return HSLColor.fromAHSL(1.0, averageHue, 0.7, 0.5).toColor();
  }
}
