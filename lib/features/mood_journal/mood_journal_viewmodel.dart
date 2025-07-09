import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/app/app.locator.dart';
import 'package:my_app/app/app.router.dart';
import 'package:my_app/models/mood_entry.dart';
import 'package:my_app/services/mood_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class MoodJournalViewModel extends BaseViewModel {
  final _moodService = locator<MoodService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  // Search controller
  final TextEditingController searchController = TextEditingController();

  // Journal entries
  List<MoodEntry> _allEntries = [];
  List<MoodEntry> _filteredEntries = [];

  List<MoodEntry> get journalEntries => _filteredEntries;

  // Filter type
  String _currentFilter = 'all';
  String get currentFilter => _currentFilter;

  Future<void> loadJournal() async {
    clearErrors();
    setBusy(true);

    try {
      _allEntries = await _moodService.getMoodEntries();
      _applyCurrentFilter();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  void searchEntries(String searchTerm) {
    if (searchTerm.isEmpty) {
      _applyCurrentFilter();
      return;
    }

    final searchTermLower = searchTerm.toLowerCase();
    _filteredEntries = _allEntries.where((entry) {
      return entry.mood.toLowerCase().contains(searchTermLower) ||
          (entry.note?.toLowerCase().contains(searchTermLower) ?? false);
    }).toList();

    notifyListeners();
  }

  void filterEntries(String filterType) {
    _currentFilter = filterType;
    _applyCurrentFilter();
  }

  void _applyCurrentFilter() {
    final now = DateTime.now();

    switch (_currentFilter) {
      case 'this_week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeek =
            DateTime(weekStart.year, weekStart.month, weekStart.day);
        _filteredEntries = _allEntries
            .where((entry) => entry.timestamp.isAfter(startOfWeek))
            .toList();
        break;

      case 'this_month':
        final startOfMonth = DateTime(now.year, now.month, 1);
        _filteredEntries = _allEntries
            .where((entry) => entry.timestamp.isAfter(startOfMonth))
            .toList();
        break;

      case 'happy':
        _filteredEntries = _allEntries
            .where((entry) =>
                entry.mood.toLowerCase().contains('happy') ||
                entry.mood.toLowerCase().contains('joy') ||
                entry.emoji == '😊' ||
                entry.emoji == '😄')
            .toList();
        break;

      case 'sad':
        _filteredEntries = _allEntries
            .where((entry) =>
                entry.mood.toLowerCase().contains('sad') ||
                entry.mood.toLowerCase().contains('depress') ||
                entry.emoji == '😔' ||
                entry.emoji == '😢')
            .toList();
        break;

      case 'all':
      default:
        _filteredEntries = List.from(_allEntries);
        break;
    }

    notifyListeners();
  }

  String formatEntryTime(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp);
  }

  String formatDateHeader(DateTime timestamp) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day) {
      return 'Today';
    } else if (timestamp.year == yesterday.year &&
        timestamp.month == yesterday.month &&
        timestamp.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, y').format(timestamp);
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> showEntryOptions(MoodEntry entry) async {
    final response = await _dialogService.showDialog(
      title: 'Entry Options',
      description: 'What would you like to do with this entry?',
      buttonTitle: 'Edit',
      cancelTitle: 'Delete',
    );

    if (response?.confirmed == true) {
      // Edit entry
      editEntry(entry);
    } else if (response != null) {
      // Delete entry
      confirmDeleteEntry(entry);
    }
  }

  Future<void> editEntry(MoodEntry entry) async {
    // Navigate to edit view (in a real app, you'd pass the entry to edit)
    await _navigationService.navigateTo(Routes.moodEntryView);
    await loadJournal(); // Refresh after returning
  }

  Future<void> confirmDeleteEntry(MoodEntry entry) async {
    final response = await _dialogService.showDialog(
      title: 'Confirm Delete',
      description:
          'Are you sure you want to delete this mood entry? This cannot be undone.',
      buttonTitle: 'Delete',
      cancelTitle: 'Cancel',
      dialogPlatform: DialogPlatform.Material,
    );

    if (response?.confirmed == true) {
      await deleteEntry(entry);
    }
  }

  Future<void> deleteEntry(MoodEntry entry) async {
    setBusy(true);

    try {
      await _moodService.deleteMoodEntry(entry.id);
      await loadJournal();
    } catch (e) {
      setError('Failed to delete entry: ${e.toString()}');
    } finally {
      setBusy(false);
    }
  }

  void navigateToMoodEntry() {
    _navigationService.navigateTo(Routes.moodEntryView);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
