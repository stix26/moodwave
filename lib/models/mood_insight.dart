class MoodInsight {
  final String title;
  final String description;
  final String? suggestion;
  final DateTime? generatedAt;

  MoodInsight({
    required this.title,
    required this.description,
    this.suggestion,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  // Convert to and from JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'suggestion': suggestion,
      'generatedAt': generatedAt?.toIso8601String(),
    };
  }

  factory MoodInsight.fromJson(Map<String, dynamic> json) {
    return MoodInsight(
      title: json['title'],
      description: json['description'],
      suggestion: json['suggestion'],
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'])
          : null,
    );
  }

  // Create a copy with updated fields
  MoodInsight copyWith({
    String? title,
    String? description,
    String? suggestion,
    DateTime? generatedAt,
  }) {
    return MoodInsight(
      title: title ?? this.title,
      description: description ?? this.description,
      suggestion: suggestion ?? this.suggestion,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  String toString() {
    return 'MoodInsight(title: $title, suggestion: ${suggestion != null ? 'Yes' : 'No'})';
  }
}
