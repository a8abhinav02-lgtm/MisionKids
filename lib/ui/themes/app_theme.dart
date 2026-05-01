import 'package:flutter/material.dart';

class AppTheme {
  static const Map<String, MaterialColor> colors = {
    'azul': Colors.blue,
    'rojo': Colors.red,
    'verde': Colors.green,
    'morado': Colors.purple,
    'naranja': Colors.orange,
    'rosa': Colors.pink,
    'amarillo': Colors.amber,
    'indigo': Colors.indigo,
  };

  static const Map<String, IconData> avatares = {
    'ninja': Icons.sports_martial_arts,
    'astronauta': Icons.rocket_launch,
    'princesa': Icons.face_3,
    'deportes': Icons.sports_soccer,
    'estudiante': Icons.school,
    'hero': Icons.shield,
    'robot': Icons.smart_toy,
  };

  static const Map<String, String> avatarLabels = {
    'ninja': 'Ninja',
    'astronauta': 'Astronauta',
    'princesa': 'Princesa',
    'deportes': 'Deportes',
    'estudiante': 'Estudiante',
    'hero': 'Héroe',
    'robot': 'Robot',
  };

  static const Map<String, String> colorLabels = {
    'azul': 'Azul',
    'rojo': 'Rojo',
    'verde': 'Verde',
    'morado': 'Morado',
    'naranja': 'Naranja',
    'rosa': 'Rosa',
    'amarillo': 'Dorado',
    'indigo': 'Índigo',
  };

  static const Color accessibleGrey = Color(0xFFE0E0E0);
  static const Color highContrastGrey = Color(0xFF546E7A); // WCAG AA compliant with background

  /// Returns a gradient for headers based on the color key
  static LinearGradient getGradient(String colorKey) {
    final color = colors[colorKey] ?? Colors.indigo;
    return LinearGradient(
      colors: [color.shade700, color.shade400],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Returns a dark gradient for backgrounds
  static LinearGradient getDarkGradient(String colorKey) {
    final color = colors[colorKey] ?? Colors.indigo;
    return LinearGradient(
      colors: [color.shade900, Color.lerp(color.shade900, Colors.black, 0.4)!],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static ThemeData getThemeByColor(String colorKey) {
    final MaterialColor color = colors[colorKey] ?? Colors.indigo;

    return ThemeData(
      primarySwatch: color,
      scaffoldBackgroundColor: const Color(0xFFF0F4F8),
      useMaterial3: true,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: color.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // Accesibilidad: Títulos centrados son más fáciles de localizar
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 48), // WCAG: Objetivo de toque mín 48dp
          elevation: 4,
          shadowColor: color.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Aumentado para toque
      ),
    );
  }

  static IconData getAvatarIcon(String avatarKey) {
    return avatares[avatarKey] ?? Icons.face;
  }
}
