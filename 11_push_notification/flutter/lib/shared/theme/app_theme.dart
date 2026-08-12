import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1565C0),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1565C0),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}
