import 'package:flutter/material.dart';

class AppTheme {
  static const navy = Color(0xFF003580);
  static const blue = Color(0xFF0071C2);
  static const yellow = Color(0xFFFEBB02);
  static const canvas = Color(0xFFF5F7FA);
  static const ink = Color(0xFF1A2B49);
  static const muted = Color(0xFF5B6B82);
  static const line = Color(0xFFE6EEF7);
  static const wash = Color(0xFFDCEBFA);
  static const priceWash = Color(0xFFFFF4CC);

  static const radius = 16.0;
  static const space = 16.0;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(color: navy.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 8)),
      ];

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: navy,
      onPrimary: Colors.white,
      secondary: yellow,
      onSecondary: Color(0xFF1A1A1A),
      error: Color(0xFFB00020),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: ink,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: canvas,
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 18),
        iconTheme: IconThemeData(color: navy),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: yellow,
          foregroundColor: const Color(0xFF1A1A1A),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navy,
          side: const BorderSide(color: Color(0xFFB9D4F0)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: line)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: blue, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: wash,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: navy, fontWeight: FontWeight.w700, fontSize: 12);
          }
          return const TextStyle(fontSize: 12);
        }),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: line),
        ),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: ink, height: 1.15),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ink),
        bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: ink, height: 1.4),
        bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: muted),
        labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: muted),
      ),
    );
  }
}
