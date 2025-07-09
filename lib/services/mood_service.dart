import 'dart:convert';

import 'package:my_app/app/app.locator.dart';
import 'package:my_app/models/mood_entry.dart';
import 'package:my_app/models/mood_insight.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/supabase_service.dart';
import 'package:stacked_services/stacked_services.dart';

class MoodService {
  final _navigationService = locator<NavigationService>();
  final _authService = locator<AuthService>();
  final _supabaseService = locator<SupabaseService>();

  // In-memory storage for mood entries (would be replaced with database in production)
  final List<MoodEntry> _moodEntries = [];
  List<MoodInsight> _insights = [];
  DateTime? _lastInsightsGeneration;

  // CRUD operations for mood entries
  Future<List<MoodEntry>> getMoodEntries() async {
    try {
      // Check if user is authenticated
      if (!_authService.isAuthenticated) {
        return [];
      }

      // In a real implementation, we would fetch from the database
      // const entries = await _supabaseService.getMoodEntries();

      // Sort entries by timestamp in descending order (newest first)
      _moodEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return _moodEntries;
    } catch (e) {
      // Re-throw with user-friendly message
      throw Exception('Could not load your mood entries: ${e.toString()}');
    }
  }

  Future<MoodEntry?> getMoodEntryById(String id) async {
    try {
      return _moodEntries.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addMoodEntry(MoodEntry entry) async {
    try {
      // Check if user is authenticated
      if (!_authService.isAuthenticated) {
        throw Exception('You must be logged in to save a mood entry');
      }

      // Add entry to in-memory store
      _moodEntries.add(entry);

      // In a real implementation, we would also save to Supabase
      // await _supabaseService.createMoodEntry(entry.toJson());
    } catch (e) {
      throw Exception('Could not save your mood entry: ${e.toString()}');
    }
  }

  Future<void> updateMoodEntry(MoodEntry updatedEntry) async {
    try {
      // Check if user is authenticated
      if (!_authService.isAuthenticated) {
        throw Exception('You must be logged in to update a mood entry');
      }

      final index =
          _moodEntries.indexWhere((entry) => entry.id == updatedEntry.id);
      if (index != -1) {
        _moodEntries[index] = updatedEntry;

        // In a real implementation, we would also update in Supabase
        // await _supabaseService.updateMoodEntry(updatedEntry.id, updatedEntry.toJson());
      } else {
        throw Exception('Mood entry not found');
      }
    } catch (e) {
      throw Exception('Could not update your mood entry: ${e.toString()}');
    }
  }

  Future<void> deleteMoodEntry(String id) async {
    try {
      // Check if user is authenticated
      if (!_authService.isAuthenticated) {
        throw Exception('You must be logged in to delete a mood entry');
      }

      _moodEntries.removeWhere((entry) => entry.id == id);

      // In a real implementation, we would also delete from Supabase
      // await _supabaseService.deleteMoodEntry(id);
    } catch (e) {
      throw Exception('Could not delete your mood entry: ${e.toString()}');
    }
  }

  // Mood entries by date range
  Future<List<MoodEntry>> getMoodEntriesByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final List<MoodEntry> entries = await getMoodEntries();
      return entries.where((entry) {
        return entry.timestamp.isAfter(startDate) &&
            entry.timestamp.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      throw Exception(
          'Could not load mood entries for the selected date range: ${e.toString()}');
    }
  }

  // Mood insights management
  Future<List<MoodInsight>> getInsights() async {
    return _insights;
  }

  Future<void> saveInsights(List<MoodInsight> insights) async {
    _insights = insights;
    _lastInsightsGeneration = DateTime.now();
  }

  bool shouldGenerateNewInsights() {
    if (_lastInsightsGeneration == null) return true;

    // Generate new insights if it's been more than 7 days or there are new entries
    final now = DateTime.now();
    final daysSinceLastGeneration =
        now.difference(_lastInsightsGeneration!).inDays;

    return daysSinceLastGeneration >= 7;
  }

  // Mood patterns and statistics
  Future<Map<String, dynamic>> getMoodStatistics() async {
    final entries = await getMoodEntries();

    if (entries.isEmpty) {
      return {
        'totalEntries': 0,
        'averageMoodScore': 0,
        'topEmojis': <String>[],
        'moodDistribution': <String, int>{},
      };
    }

    // Calculate mood distribution
    final Map<String, int> moodDistribution = {};
    final Map<String, int> emojiCounts = {};

    for (final entry in entries) {
      // Count moods
      if (moodDistribution.containsKey(entry.mood)) {
        moodDistribution[entry.mood] = moodDistribution[entry.mood]! + 1;
      } else {
        moodDistribution[entry.mood] = 1;
      }

      // Count emojis
      if (emojiCounts.containsKey(entry.emoji)) {
        emojiCounts[entry.emoji] = emojiCounts[entry.emoji]! + 1;
      } else {
        emojiCounts[entry.emoji] = 1;
      }
    }

    // Get top 3 emojis
    final topEmojis = emojiCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top3Emojis = topEmojis.take(3).map((e) => e.key).toList();

    return {
      'totalEntries': entries.length,
      'topEmojis': top3Emojis,
      'moodDistribution': moodDistribution,
    };
  }
}
