import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/models/mood_entry.dart';
import 'package:my_app/models/mood_insight.dart';

class OpenAIService {
  static const String _apiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String _baseUrl = 'https://api.openai.com/v1';

  // Rate limiting variables
  DateTime? _lastRequestTime;
  static const _minRequestInterval = Duration(milliseconds: 200);

  // Send a chat completion request to OpenAI
  Future<String> generateResponse(String prompt) async {
    // Rate limiting
    await _respectRateLimit();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful and empathetic mood coach assistant.'
            },
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      _lastRequestTime = DateTime.now();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['choices'][0]['message']['content'];
      } else {
        throw Exception(
            'Failed to generate response: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('OpenAI API error: $e');
    }
  }

  // Generate insights based on mood entries
  Future<List<MoodInsight>> generateMoodInsights(
      List<MoodEntry> moodEntries) async {
    if (moodEntries.isEmpty) {
      return [];
    }

    // Format mood entries for the prompt
    final entriesText = moodEntries.map((entry) {
      return 'Date: ${entry.timestamp.toString()}, Mood: ${entry.mood}, Emoji: ${entry.emoji}, Note: ${entry.note ?? "No note"}';
    }).join('\n');

    final prompt = '''
    Analyze these mood entries and provide 3 insights about patterns or trends you observe. For each insight, include:
    1. A clear title
    2. A description of the pattern or observation
    3. A helpful, actionable suggestion based on cognitive behavioral therapy principles

    Here are the mood entries:
    $entriesText
    
    Format your response as a JSON array of objects with 'title', 'description', and 'suggestion' fields.
    ''';

    try {
      // Rate limiting
      await _respectRateLimit();

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a skilled therapist and mood analyst. Respond only with valid JSON.'
            },
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      _lastRequestTime = DateTime.now();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['choices'][0]['message']['content'];

        // Extract JSON from the response (in case there's any extra text)
        final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(content);
        if (jsonMatch == null) {
          throw Exception('Could not parse insights from response');
        }

        final jsonContent = jsonMatch.group(0);
        final List<dynamic> insightsJson = jsonDecode(jsonContent!);

        // Convert to MoodInsight objects
        return insightsJson
            .map((json) => MoodInsight(
                  title: json['title'],
                  description: json['description'],
                  suggestion: json['suggestion'],
                ))
            .toList();
      } else {
        throw Exception(
            'Failed to generate insights: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating mood insights: $e');
    }
  }

  // Generate a coach suggestion based on recent mood
  Future<String> generateCoachSuggestion(MoodEntry recentMood) async {
    final prompt = '''
    I'm feeling ${recentMood.mood} right now. 
    ${recentMood.note != null ? 'Context: ${recentMood.note}' : ''}
    
    Provide a brief, supportive response (2-3 sentences) with one practical suggestion to help me manage this mood using CBT principles.
    ''';

    try {
      return await generateResponse(prompt);
    } catch (e) {
      throw Exception('Error generating coach suggestion: $e');
    }
  }

  // Respect rate limits
  Future<void> _respectRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        final waitTime = _minRequestInterval - timeSinceLastRequest;
        await Future.delayed(waitTime);
      }
    }
  }
}
