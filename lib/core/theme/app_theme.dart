import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => _theme(Brightness.light);
  static ThemeData get darkTheme => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4E7BFF),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          brightness == Brightness.dark ? const Color(0xFF0B0D10) : null,
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: const CardThemeData(clipBehavior: Clip.antiAlias),
    );
  }
}
