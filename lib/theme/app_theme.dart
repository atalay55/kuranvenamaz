import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color primaryEmerald = Color(0xFF0F4C3A);
  static const Color primaryDark = Color(0xFF072A20);
  static const Color primaryLight = Color(0xFF1B6B53);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF5E6AD);
  static const Color bgDark = Color(0xFF0B131F);
  static const Color surfaceDark = Color(0xFF162232);
  static const Color cardDark = Color(0xFF1E2D42);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Card Decoration Helper
  static BoxDecoration cardDecoration({
    Color? color,
    BorderRadius? borderRadius,
    bool showBorder = true,
    bool showShadow = true,
  }) {
    return BoxDecoration(
      color: color ?? cardDark,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: showBorder
          ? Border.all(color: goldAccent.withOpacity(0.25), width: 1)
          : null,
      boxShadow: showShadow
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  // Gradient Header Helper
  static BoxDecoration headerGradientDecoration({BorderRadius? borderRadius}) {
    return BoxDecoration(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [primaryEmerald, primaryDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: goldAccent.withOpacity(0.4), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: primaryEmerald.withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // Dark Theme Definition
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bgDark,
      primaryColor: primaryEmerald,
      colorScheme: const ColorScheme.dark(
        primary: primaryEmerald,
        secondary: goldAccent,
        surface: surfaceDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: goldAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: goldAccent),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: goldAccent.withOpacity(0.2)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryEmerald,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: goldAccent, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}
