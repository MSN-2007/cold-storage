import os

theme_content = """/// ColdSmart Design System
/// All visual tokens: colors, typography, spacing, shadows, radius
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color Tokens ─────────────────────────────────────────────────────────────

class CSColors {
  CSColors._();

  // Primary brand palette
  static const Color primary = Color(0xFF1E3A5F);       // Deep navy
  static const Color primaryLight = Color(0xFF2D5491);
  static const Color primaryDark = Color(0xFF0F1E30);

  // Accent
  static const Color accent = Color(0xFF0EA5E9);        // Sky blue
  static const Color accentLight = Color(0xFF38BDF8);
  static const Color accentDark = Color(0xFF0284C7);

  // Semantic: Status
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color successDark = Color(0xFF16A34A);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  static const Color critical = Color(0xFFEF4444);
  static const Color criticalLight = Color(0xFFFEE2E2);
  static const Color criticalDark = Color(0xFFDC2626);

  static const Color emergency = Color(0xFF7C3AED);
  static const Color emergencyLight = Color(0xFFEDE9FE);

  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFE0F2FE);

  static const Color offline = Color(0xFF9CA3AF);
  static const Color offlineLight = Color(0xFFF3F4F6);

  // Sensor parameter colors
  static const Color temperature = Color(0xFFEF4444);
  static const Color humidity = Color(0xFF0EA5E9);
  static const Color co2 = Color(0xFF8B5CF6);
  static const Color o2 = Color(0xFF22C55E);
  static const Color ethylene = Color(0xFFF97316);
  static const Color carbonMonoxide = Color(0xFFDC2626);
  static const Color methane = Color(0xFFF59E0B);

  // Backgrounds - Dark
  static const Color backgroundDark = Color(0xFF0B1120);
  static const Color backgroundDark2 = Color(0xFF111827);
  static const Color backgroundDark3 = Color(0xFF1F2937);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color surfaceDark2 = Color(0xFF374151);
  static const Color cardDark = Color(0xFF1A2535);

  // Backgrounds - Light
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundLight2 = Color(0xFFF1F5F9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLight2 = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color sidebarDark = Color(0xFF0F172A);

  // Text - Dark
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF4B5563);

  // Text - Light
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);
  static const Color textDisabledLight = Color(0xFFCBD5E1);

  // Borders
  static const Color border = Color(0xFF374151);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A5F), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A2535), Color(0xFF1F2937)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Severity color mapping
  static Color forSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'emergency': return emergency;
      case 'critical': return critical;
      case 'warning': return warning;
      case 'info': return info;
      default: return textSecondary;
    }
  }

  static Color forDeviceStatus(String status) {
    switch (status.toLowerCase()) {
      case 'online': return success;
      case 'warning': return warning;
      case 'critical': return critical;
      case 'offline': return offline;
      case 'maintenance': return info;
      default: return offline;
    }
  }
}


// ─── Typography ───────────────────────────────────────────────────────────────

class CSTextStyles {
  CSTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.outfit(
    fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5,
  );
  static TextStyle get displayMedium => GoogleFonts.outfit(
    fontSize: 26, fontWeight: FontWeight.w700,
  );
  static TextStyle get displaySmall => GoogleFonts.outfit(
    fontSize: 22, fontWeight: FontWeight.w600,
  );
  static TextStyle get headlineLarge => GoogleFonts.outfit(
    fontSize: 20, fontWeight: FontWeight.w700,
  );
  static TextStyle get headlineMedium => GoogleFonts.outfit(
    fontSize: 18, fontWeight: FontWeight.w600,
  );
  static TextStyle get headlineSmall => GoogleFonts.outfit(
    fontSize: 16, fontWeight: FontWeight.w600,
  );
  static TextStyle get titleLarge => GoogleFonts.outfit(
    fontSize: 16, fontWeight: FontWeight.w600,
  );
  static TextStyle get titleMedium => GoogleFonts.outfit(
    fontSize: 14, fontWeight: FontWeight.w600,
  );
  static TextStyle get bodyLarge => GoogleFonts.outfit(
    fontSize: 16, fontWeight: FontWeight.w400,
  );
  static TextStyle get bodyMedium => GoogleFonts.outfit(
    fontSize: 14, fontWeight: FontWeight.w400,
  );
  static TextStyle get bodySmall => GoogleFonts.outfit(
    fontSize: 12, fontWeight: FontWeight.w400,
  );
  static TextStyle get labelLarge => GoogleFonts.outfit(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1,
  );
  static TextStyle get labelMedium => GoogleFonts.outfit(
    fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.2,
  );
  static TextStyle get labelSmall => GoogleFonts.outfit(
    fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.4,
  );
  static TextStyle get numericHero => GoogleFonts.outfit(
    fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -1,
  );
  static TextStyle get numericLarge => GoogleFonts.outfit(
    fontSize: 24, fontWeight: FontWeight.w600,
  );
}


// ─── Spacing & Radius Tokens ─────────────────────────────────────────────────

class CSSpacing {
  CSSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;
}

class CSRadius {
  CSRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double pill = 100.0;
  static const double card = 16.0;

  static const BorderRadius cardBorder = BorderRadius.all(Radius.circular(card));
  static const BorderRadius pillBorder = BorderRadius.all(Radius.circular(pill));
  static BorderRadius all(double r) => BorderRadius.all(Radius.circular(r));
}


// ─── Shadows ──────────────────────────────────────────────────────────────────

class CSShadows {
  CSShadows._();

  static List<BoxShadow> get card => [
    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4)),
    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 1)),
  ];

  static List<BoxShadow> get cardLight => [
    BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
    BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(color: color.withOpacity(0.3), blurRadius: 20, spreadRadius: 0),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8)),
  ];
}


// ─── ColdSmart Theme ─────────────────────────────────────────────────────────

class CSTheme {
  CSTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: CSColors.accent,
      onPrimary: Colors.white,
      secondary: CSColors.primary,
      surface: CSColors.surfaceLight,
      background: CSColors.backgroundLight,
      error: CSColors.critical,
      onSurface: CSColors.textPrimaryLight,
      onBackground: CSColors.textPrimaryLight,
    ),
    scaffoldBackgroundColor: CSColors.backgroundLight,
    cardColor: CSColors.cardLight,
    textTheme: TextTheme(
      displayLarge: CSTextStyles.displayLarge.copyWith(color: CSColors.textPrimaryLight),
      displayMedium: CSTextStyles.displayMedium.copyWith(color: CSColors.textPrimaryLight),
      displaySmall: CSTextStyles.displaySmall.copyWith(color: CSColors.textPrimaryLight),
      headlineLarge: CSTextStyles.headlineLarge.copyWith(color: CSColors.textPrimaryLight),
      headlineMedium: CSTextStyles.headlineMedium.copyWith(color: CSColors.textPrimaryLight),
      headlineSmall: CSTextStyles.headlineSmall.copyWith(color: CSColors.textPrimaryLight),
      titleLarge: CSTextStyles.titleLarge.copyWith(color: CSColors.textPrimaryLight),
      titleMedium: CSTextStyles.titleMedium.copyWith(color: CSColors.textPrimaryLight),
      bodyLarge: CSTextStyles.bodyLarge.copyWith(color: CSColors.textPrimaryLight),
      bodyMedium: CSTextStyles.bodyMedium.copyWith(color: CSColors.textSecondaryLight),
      bodySmall: CSTextStyles.bodySmall.copyWith(color: CSColors.textSecondaryLight),
      labelLarge: CSTextStyles.labelLarge.copyWith(color: CSColors.textPrimaryLight),
      labelMedium: CSTextStyles.labelMedium.copyWith(color: CSColors.textSecondaryLight),
      labelSmall: CSTextStyles.labelSmall.copyWith(color: CSColors.textTertiaryLight),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: CSColors.surfaceLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: CSTextStyles.headlineMedium.copyWith(color: CSColors.textPrimaryLight),
      iconTheme: const IconThemeData(color: CSColors.textPrimaryLight),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CSColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const RoundedRectangleBorder(borderRadius: CSRadius.cardBorder),
        textStyle: CSTextStyles.labelLarge.copyWith(color: Colors.white),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CSColors.accent,
        side: const BorderSide(color: CSColors.accent),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const RoundedRectangleBorder(borderRadius: CSRadius.cardBorder),
        textStyle: CSTextStyles.labelLarge.copyWith(color: CSColors.accent),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CSColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: CSRadius.cardBorder,
        borderSide: const BorderSide(color: CSColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: CSRadius.cardBorder,
        borderSide: const BorderSide(color: CSColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: CSRadius.cardBorder,
        borderSide: const BorderSide(color: CSColors.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: CSRadius.cardBorder,
        borderSide: const BorderSide(color: CSColors.critical),
      ),
      labelStyle: CSTextStyles.bodyMedium.copyWith(color: CSColors.textPrimaryLight),
      hintStyle: CSTextStyles.bodyMedium.copyWith(color: CSColors.textDisabledLight),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: CSColors.surfaceLight,
      selectedItemColor: CSColors.accent,
      unselectedItemColor: CSColors.textTertiaryLight,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(
      color: CSColors.borderLight,
      thickness: 1,
      space: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: CSColors.surfaceLight,
      selectedColor: CSColors.accent.withOpacity(0.1),
      labelStyle: CSTextStyles.labelMedium.copyWith(color: CSColors.textPrimaryLight),
      shape: const StadiumBorder(side: BorderSide(color: CSColors.borderLight)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: CSColors.surfaceDark,
      contentTextStyle: CSTextStyles.bodyMedium.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: CSRadius.cardBorder),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: CSColors.accent,
      onPrimary: Colors.white,
      secondary: CSColors.primary,
      surface: CSColors.surfaceDark,
      background: CSColors.backgroundDark,
      error: CSColors.critical,
      onSurface: CSColors.textPrimary,
      onBackground: CSColors.textPrimary,
    ),
    scaffoldBackgroundColor: CSColors.backgroundDark,
    cardColor: CSColors.cardDark,
    textTheme: TextTheme(
      displayLarge: CSTextStyles.displayLarge.copyWith(color: CSColors.textPrimary),
      displayMedium: CSTextStyles.displayMedium.copyWith(color: CSColors.textPrimary),
      displaySmall: CSTextStyles.displaySmall.copyWith(color: CSColors.textPrimary),
      headlineLarge: CSTextStyles.headlineLarge.copyWith(color: CSColors.textPrimary),
      headlineMedium: CSTextStyles.headlineMedium.copyWith(color: CSColors.textPrimary),
      headlineSmall: CSTextStyles.headlineSmall.copyWith(color: CSColors.textPrimary),
      titleLarge: CSTextStyles.titleLarge.copyWith(color: CSColors.textPrimary),
      titleMedium: CSTextStyles.titleMedium.copyWith(color: CSColors.textPrimary),
      bodyLarge: CSTextStyles.bodyLarge.copyWith(color: CSColors.textPrimary),
      bodyMedium: CSTextStyles.bodyMedium.copyWith(color: CSColors.textSecondary),
      bodySmall: CSTextStyles.bodySmall.copyWith(color: CSColors.textSecondary),
      labelLarge: CSTextStyles.labelLarge.copyWith(color: CSColors.textPrimary),
      labelMedium: CSTextStyles.labelMedium.copyWith(color: CSColors.textSecondary),
      labelSmall: CSTextStyles.labelSmall.copyWith(color: CSColors.textTertiary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: CSColors.backgroundDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: CSTextStyles.headlineMedium.copyWith(color: CSColors.textPrimary),
      iconTheme: const IconThemeData(color: CSColors.textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CSColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const RoundedRectangleBorder(borderRadius: CSRadius.cardBorder),
        textStyle: CSTextStyles.labelLarge.copyWith(color: Colors.white),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CSColors.accent,
        side: const BorderSide(color: CSColors.accent),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const RoundedRectangleBorder(borderRadius: CSRadius.cardBorder),
        textStyle: CSTextStyles.labelLarge.copyWith(color: CSColors.accent),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CSColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: CSRadius.cardBorder,
        borderSide: const BorderSide(color: CSColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: CSRadius.cardBorder,
        borderSide: const BorderSide(color: CSColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: CSRadius.cardBorder,
        borderSide: const BorderSide(color: CSColors.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: CSRadius.cardBorder,
        borderSide: const BorderSide(color: CSColors.critical),
      ),
      labelStyle: CSTextStyles.bodyMedium.copyWith(color: CSColors.textPrimary),
      hintStyle: CSTextStyles.bodyMedium.copyWith(color: CSColors.textDisabled),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: CSColors.backgroundDark2,
      selectedItemColor: CSColors.accent,
      unselectedItemColor: CSColors.textTertiary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(
      color: CSColors.border,
      thickness: 1,
      space: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: CSColors.surfaceDark,
      selectedColor: CSColors.accent.withOpacity(0.2),
      labelStyle: CSTextStyles.labelMedium.copyWith(color: CSColors.textPrimary),
      shape: const StadiumBorder(side: BorderSide(color: CSColors.border)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: CSColors.surfaceDark2,
      contentTextStyle: CSTextStyles.bodyMedium.copyWith(color: CSColors.textPrimary),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: CSRadius.cardBorder),
    ),
  );
}
"""

with open(r"c:\work\cold_v1.0.1\mobile\lib\core\theme\app_theme.dart", "w", encoding="utf-8") as f:
    f.write(theme_content)
print("Updated app_theme.dart")
