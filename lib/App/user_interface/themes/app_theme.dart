// lib/app/ui/themes/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Define your custom colors
  static const Color color1 = Color(0xFFEAF4F9); // #eaf4f9
  static const Color color2 = Color(0xFF30B2E4); // #30b2e4
  static const Color color3 = Color(0xFFB1D2E1); // #b1d2e1
  static const Color color4 = Color(0xFFB7C9B3); // #b7c9b3
  static const Color color5 = Color(0xFF929E47); // #929e47
  static const Color color6 = Color(0xFF274329); // #274329
  static const Color color7 = Color(0xFFDD4229); // #dd4229

  // Define the light theme
  static final ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: color2, // #30b2e4
      secondary: color5, // #eaf4f9
      surface: color3, // #b1d2e1
      onPrimary: Colors.white, // Text color on primary
      onSecondary: Colors.white,
      onSurface: Colors.black,
    ),
    scaffoldBackgroundColor: color1, // #eaf4f9
    appBarTheme: const AppBarTheme(
      backgroundColor: color2, // #30b2e4
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(color: Colors.black), // If needed
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(color2), // #30b2e4
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white), // Text color
        shadowColor: WidgetStateProperty.all<Color>(color5), // #929e47
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ),
    // Define other button themes if needed
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(color2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        side: WidgetStateProperty.all<BorderSide>(
          const BorderSide(color: color2),
        ),
        foregroundColor: WidgetStateProperty.all<Color>(color2),
      ),
    ),
  );
}
