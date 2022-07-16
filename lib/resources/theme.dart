import 'package:flutter/material.dart';

class WonderfulCitiesTheme {
  static final light = ThemeData(
    colorScheme: ColorScheme.light(
      primary: const Color(0xFFF8BBD0),
      onPrimary: Colors.black.withOpacity(0.75),
      secondary: const Color(0xFFB3E5FC),
    ),
    scaffoldBackgroundColor: const Color(0xFFDCDCDD),
  );

  static final dark = ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFC48B9F),
      secondary: Color(0xFF82B3C9),
    ),
  );
}
