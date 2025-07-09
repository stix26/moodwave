import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/app/app.dialogs.dart';
import 'package:my_app/app/app.locator.dart';
import 'package:my_app/app/app.router.dart';
import 'package:my_app/features/mood_journal/mood_journal_view.dart';
import 'package:my_app/features/mood_timeline/mood_timeline_view.dart';
import 'package:my_app/models/mood_entry.dart';
import 'package:my_app/models/user_profile.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/mood_service.dart';
import 'package:my_app/services/openai_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  final _moodService = locator<MoodService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _openAiService = locator<OpenAIService>();
  final _authService = locator<AuthService>();

  // Tab bar state
  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  // Mood entries data
  List<MoodEntry> _moodEntries = [];
  List<MoodEntry> get moodEntries => _moodEntries;
  List<MoodEntry> get recentEntries => _moodEntries.take(3).toList();

  // User data
  UserProfile? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;

  // Quick mood selection options
  final List<Map<String, dynamic>> quickMoodOptions = [
    {'emoji': '\ud83d\ude0a', 'text': 'Happy', 'hue': 120.0},
    {'emoji': '\ud83d\ude14', 'text': 'Sad', 'hue': 240.0},
    {'emoji': '\ud83d\ude21', 'text': 'Angry', 'hue': 0.0},
    {'emoji': '\ud83d\ude0c', 'text': 'Calm', 'hue': 180.0},
    {'emoji': '\ud83d\ude34', 'text': 'Tired', 'hue': 270.0},
  ];

  // AI Coach insights
  String _coachInsight = '';
  String? _coachSuggestion;
  bool _hasCoachInsight = false;

  String get coachInsight => _coachInsight;
  String? get coachSuggestion => _coachSuggestion;
  bool get hasCoachInsight => _hasCoachInsight;

  // Greeting message based on time of day
  String get greetingMessage {
    final hour = DateTime.now().hour;
    final name = currentUser?.name?.split(' ').first ?? '';
    final greeting = hour < 12
        ? 'Good morning'
        : (hour < 18 ? 'Good afternoon' : 'Good evening');

    return name.isNotEmpty ? '$greeting, $name' : greeting;
  }

  // Embedded views for tab navigation
  final Widget moodTimelineView = const MoodTimelineView();
  final Widget moodJournalView = const MoodJournalView();

  Future<void> initialize() async {
    clearErrors();
    setBusy(true);

    try {
      // Check authentication status
      if (!isAuthenticated) {
        await _navigationService.clearStackAndShow(Routes.loginView);
        return;
      }

      await loadMoodEntries();
      if (_moodEntries.isNotEmpty) {
        await _generateCoachInsight();
      }
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  Future<void> loadMoodEntries() async {
    try {
      _moodEntries = await _moodService.getMoodEntries();
      notifyListeners();
    } catch (e) {
      setError('Failed to load mood entries: ${e.toString()}');
    }
  }

  Future<void> _generateCoachInsight() async {
    try {
      if (_moodEntries.isEmpty) return;

      final latestEntry = _moodEntries.first;
      final suggestion =
          await _openAiService.generateCoachSuggestion(latestEntry);

      // Parse the suggestion - typically the first sentence is the insight,
      // and the rest is the actionable suggestion
      final sentences = suggestion.split('. ');

      if (sentences.length > 1) {
        _coachInsight = '${sentences[0]}.';
        _coachSuggestion = sentences.sublist(1).join('. ').trim();
      } else {
        _coachInsight = suggestion;
        _coachSuggestion = null;
      }

      _hasCoachInsight = true;
      notifyListeners();
    } catch (e) {
      // Don't show an error to the user, just log it and continue
      // This is a non-critical feature
      _hasCoachInsight = false;
      notifyListeners();
    }
  }

  // Format mood entry timestamp
  String formatEntryTime(MoodEntry entry) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (_isSameDay(entry.timestamp, now)) {
      return DateFormat('h:mm a').format(entry.timestamp);
    } else if (_isSameDay(entry.timestamp, yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(entry.timestamp);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Navigation methods
  void navigateToMoodEntry() {
    _navigationService.navigateTo(Routes.moodEntryView);
  }

  void navigateToTimeline() {
    setSelectedTabIndex(1);
  }

  void navigateToInsights() {
    _navigationService.navigateTo(Routes.moodInsightsView);
  }

  void navigateToProfile() {
    _navigationService.navigateTo(Routes.profileView);
  }

  void viewMoodEntryDetails(MoodEntry entry) {
    _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      title: entry.mood,
      description: entry.note ?? 'No note added',
    );
  }

  // Tab navigation
  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  // Quick mood selection
  Future<void> quickSelectMood(String emoji, String text, double hue) async {
    setBusy(true);

    try {
      final moodEntry = MoodEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        emoji: emoji,
        mood: text,
        colorHue: hue,
        colorSaturation: 0.7,
        colorLightness: 0.5,
      );

      await _moodService.addMoodEntry(moodEntry);
      await loadMoodEntries();

      _dialogService.showDialog(
        title: 'Mood Recorded',
        description: 'Your $text mood has been added to your journal.',
        buttonTitle: 'OK',
      );
    } catch (e) {
      setError('Failed to save mood: ${e.toString()}');
    } finally {
      setBusy(false);
    }
  }

  // Mood chart visualization
  Widget buildMoodChart(BuildContext context) {
    if (_moodEntries.isEmpty) {
      return const Center(
        child: Text('No mood data to display'),
      );
    }

    // Group entries by day for the last 7 days
    final now = DateTime.now();
    final Map<String, List<MoodEntry>> entriesByDay = {};

    // Initialize all 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('MM-dd').format(date);
      entriesByDay[dateKey] = [];
    }

    // Fill with actual entries
    for (final entry in _moodEntries) {
      if (now.difference(entry.timestamp).inDays <= 6) {
        final dateKey = DateFormat('MM-dd').format(entry.timestamp);
        if (entriesByDay.containsKey(dateKey)) {
          entriesByDay[dateKey]!.add(entry);
        }
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: entriesByDay.entries.map((dayEntry) {
        final date = DateFormat('MM-dd').parse(dayEntry.key);
        final dayName = DateFormat('E').format(date);
        final entries = dayEntry.value;

        // Calculate average mood color
        Color moodColor = Colors.grey.shade300;
        if (entries.isNotEmpty) {
          double totalHue = 0;
          for (final entry in entries) {
            totalHue += entry.colorHue;
          }
          final averageHue = totalHue / entries.length;
          moodColor = HSLColor.fromAHSL(1.0, averageHue, 0.7, 0.5).toColor();
        }

        // Calculate bar height based on number of entries (min 30, max 120)
        final height = entries.isEmpty
            ? 30.0
            : 30.0 + (entries.length * 30.0).clamp(0.0, 90.0);

        return Column(
          children: [
            Container(
              width: 32,
              height: height,
              decoration: BoxDecoration(
                color: entries.isEmpty ? Colors.grey.shade200 : moodColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: entries.isEmpty
                    ? null
                    : [
                        BoxShadow(
                          color: moodColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: entries.isEmpty
                  ? null
                  : Center(
                      child: Text(
                        entries.length.toString(),
                        style: TextStyle(
                          color:
                              ThemeData.estimateBrightnessForColor(moodColor) ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              dayName,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}
