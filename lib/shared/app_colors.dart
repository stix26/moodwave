import 'package:flutter/material.dart';

// Primary Colors
const Color kcPrimaryColor = Color(0xFF6366F1);
const Color kcSecondaryColor = Color(0xFF8B5CF6);

// Status Colors
const Color kcSuccessColor = Color(0xFF10B981);
const Color kcErrorColor = Color(0xFFEF4444);

// Neutral Colors
const Color kcBackgroundColor = Color(0xFFFAFAFA);
const Color kcSurfaceColor = Colors.white;
const Color kcPrimaryTextColor = Color(0xFF111827);
const Color kcSecondaryTextColor = Color(0xFF6B7280);

// Mood Colors
const List<Color> kcMoodColors = [
  Color(0xFFFF6B6B), // Red - Angry
  Color(0xFFFFD166), // Yellow - Happy
  Color(0xFF118AB2), // Blue - Sad
  Color(0xFF06D6A0), // Green - Calm
  Color(0xFF9A67EA), // Purple - Anxious
  Color(0xFFFF9E80), // Orange - Excited
];

// Mood Gradients
const List<LinearGradient> kcMoodGradients = [
  LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8C94)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFFFFD166), Color(0xFFFEE440)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFF118AB2), Color(0xFF73C2FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFF06D6A0), Color(0xFF1DE9B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  LinearGradient(
    colors: [Color(0xFF9A67EA), Color(0xFFB39DDB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
];

// Gradients
const LinearGradient kcPrimaryGradient = LinearGradient(
  colors: [kcPrimaryColor, kcSecondaryColor],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Glass Effect
final BoxDecoration kcGlassEffect = BoxDecoration(
  color: Colors.white.withOpacity(0.1),
  borderRadius: BorderRadius.circular(16),
  border: Border.all(
    color: Colors.white.withOpacity(0.2),
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ],
);
