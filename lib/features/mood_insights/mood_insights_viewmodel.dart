import 'package:my_app/app/app.locator.dart';
import 'package:my_app/models/mood_insight.dart';
import 'package:my_app/services/mood_service.dart';
import 'package:my_app/services/openai_service.dart';
import 'package:stacked/stacked.dart';

class MoodInsightsViewModel extends BaseViewModel {
  final _moodService = locator<MoodService>();
  final _openAiService = locator<OpenAIService>();

  List<MoodInsight> _insights = [];
  List<MoodInsight> get insights => _insights;

  Future<void> loadInsights() async {
    clearErrors();
    setBusy(true);

    try {
      // First try to get cached insights
      _insights = await _moodService.getInsights();

      // If we don't have insights or it's time to refresh them, generate new ones
      if (_insights.isEmpty || _moodService.shouldGenerateNewInsights()) {
        await _generateInsights();
      }
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }

  Future<void> _generateInsights() async {
    try {
      // Get the mood entries for analysis
      final moodEntries = await _moodService.getMoodEntries();

      if (moodEntries.isEmpty) {
        // No entries to generate insights from
        return;
      }

      // Generate insights using OpenAI
      final insightsResponse =
          await _openAiService.generateMoodInsights(moodEntries);

      // Save the generated insights
      _insights = insightsResponse;
      await _moodService.saveInsights(insightsResponse);
    } catch (e) {
      setError('Failed to generate insights: ${e.toString()}');
    }
  }

  Future<void> refreshInsights() async {
    clearErrors();
    setBusy(true);

    try {
      await _generateInsights();
    } catch (e) {
      setError(e);
    } finally {
      setBusy(false);
    }
  }
}
