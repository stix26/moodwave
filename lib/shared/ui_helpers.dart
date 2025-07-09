import 'dart:math';

import 'package:flutter/material.dart';

const double _smallSize = 10;
const double _mediumSize = 25;
const double _largeSize = 50;
const double _massiveSize = 120;

const Widget kSpaceSmall = SizedBox(height: _smallSize);
const Widget kSpaceMedium = SizedBox(height: _mediumSize);
const Widget kSpaceLarge = SizedBox(height: _largeSize);
const Widget kSpaceMassive = SizedBox(height: _massiveSize);

const Widget kHorizontalSpaceSmall = SizedBox(width: _smallSize);
const Widget kHorizontalSpaceMedium = SizedBox(width: _mediumSize);
const Widget kHorizontalSpaceLarge = SizedBox(width: _largeSize);

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

double screenHeightFraction(
  BuildContext context, {
  int dividedBy = 1,
  double offsetBy = 0,
  double max = 3000,
}) =>
    min((screenHeight(context) - offsetBy) / dividedBy, max);

double screenWidthFraction(
  BuildContext context, {
  int dividedBy = 1,
  double offsetBy = 0,
  double max = 3000,
}) =>
    min((screenWidth(context) - offsetBy) / dividedBy, max);

double getResponsiveHorizontalSpaceMedium(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 10);

// Get HSL color from hue
Color getColorFromHue(double hue,
    {double saturation = 0.7, double lightness = 0.5}) {
  return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
}

// Generate a contrasting text color based on background brightness
Color getContrastingTextColor(Color backgroundColor) {
  final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
  return brightness == Brightness.dark ? Colors.white : Colors.black;
}

// Wrapper for responsive sizing
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints, bool) builder;

  const ResponsiveBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTabletOrLarger = constraints.maxWidth > 600;
        return builder(context, constraints, isTabletOrLarger);
      },
    );
  }
}

// Avatar builder with fallback
Widget buildAvatar({
  String? imageUrl,
  String? name,
  double radius = 50,
  Color? backgroundColor,
}) {
  if (imageUrl != null && imageUrl.isNotEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(imageUrl),
      onBackgroundImageError: (_, __) {},
      backgroundColor: backgroundColor ?? Colors.grey.shade200,
    );
  } else {
    // Use initials if no image is available
    final initials = name != null && name.isNotEmpty
        ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('')
        : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey.shade200,
      child: Text(
        initials.substring(0, min(2, initials.length)),
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }
}
