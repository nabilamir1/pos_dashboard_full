import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';

/// Centralized design tokens for the Cyborg POS Cashier System.
/// All colors, gradients, text styles, and decoration helpers live here.
class AppColors {
  AppColors._();

  // ── CYBORG Design System Tokens ──────────────────────────────
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonCyanDark = Color(0xFF00B4D8);
  static const Color electricPurple = Color(0xFF7928CA);
  static const Color electricPurpleLight = Color(0xFF8B5CF6);
  static const Color darkBg = Color(0xFF0B0F19);
  static const Color darkBgSecondary = Color(0xFF0D1117);
  static const Color darkBgTertiary = Color(0xFF0F172A);

  // ── Core palette ──────────────────────────────────────────────
  static const Color background = Color(0xFF0B0F19);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceLight = Color(0xFF1A2234);
  static const Color card = Color(0xFF131B2E);
  static const Color cardHover = Color(0xFF1F293D);
  static const Color border = Color(0xFF1F293D);
  static const Color borderLight = Color(0xFF2E3D5B);
  static const Color borderCyan = Color(0x4D00F0FF);
  static const Color borderPurple = Color(0x4D7928CA);

  // ── Accent ────────────────────────────────────────────────────
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color cyan = Color(0xFF00F0FF);
  static const Color cyanDark = Color(0xFF00B4D8);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFF43F5E);
  static const Color violet = Color(0xFF7928CA);
  static const Color sky = Color(0xFF38BDF8);

  // ── Semantic ──────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFF43F5E);
  static const Color info = Color(0xFF00F0FF);

  // ── Text ──────────────────────────────────────────────────────
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textOnAccent = Color(0xFF042F2E);
  static const Color textOnCyan = Color(0xFF03101F);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient neonCyan = LinearGradient(
    colors: [Color(0xFF00F0FF), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient electricPurple = LinearGradient(
    colors: [Color(0xFF7928CA), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyborgPrimary = LinearGradient(
    colors: [Color(0xFF00F0FF), Color(0xFF7928CA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlow = LinearGradient(
    colors: [Color(0xFF162036), Color(0xFF0B0F19)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emerald = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyan = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rose = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surface = LinearGradient(
    colors: [Color(0xFF141E30), Color(0xFF0D1524)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gold = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violet = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppDecorations {
  AppDecorations._();

  static BoxDecoration glassCard({
    double radius = 14,
    Color? borderColor,
    bool? isDark,
  }) {
    final dark = isDark ?? AppController.instance.isDarkMode;
    return BoxDecoration(
      color: dark ? AppColors.card.withOpacity(0.85) : Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? (dark ? AppColors.border : const Color(0xFFCBD5E1)), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(dark ? 0.25 : 0.05),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration gradientCard({
    required Gradient gradient,
    double radius = 14,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static InputDecoration searchField({
    required String hint,
    IconData? prefixIcon,
    Widget? suffix,
    bool? isDark,
  }) {
    final dark = isDark ?? AppController.instance.isDarkMode;
    final bgColor = dark ? AppColors.surface : const Color(0xFFF8FAFC);
    final borderCol = dark ? AppColors.border : const Color(0xFFCBD5E1);
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.emerald, size: 20)
          : null,
      suffixIcon: suffix,
      filled: true,
      fillColor: bgColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderCol),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderCol),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
      ),
    );
  }

  static BoxDecoration cyborgCard({
    double radius = 14,
    Color? borderColor,
    bool glow = false,
    bool? isDark,
  }) {
    final dark = isDark ?? AppController.instance.isDarkMode;
    final bgColor = dark ? AppColors.card : Colors.white;
    final defaultBorder = dark ? AppColors.border : const Color(0xFFCBD5E1);
    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? defaultBorder,
        width: glow ? 1.5 : 1.0,
      ),
      boxShadow: [
        if (glow)
          BoxShadow(
            color: (borderColor ?? AppColors.neonCyan).withOpacity(dark ? 0.25 : 0.15),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          )
        else
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.35 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
      ],
    );
  }

  static BoxDecoration badge({
    required Color color,
    double radius = 8,
  }) {
    return BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withOpacity(0.4), width: 1),
    );
  }
}

/// Application-wide [ThemeData] builder supporting Dark & Light Modes.
ThemeData buildAppTheme({bool isDark = true}) {
  if (!isDark) {
    // ── CYBORG Light Mode ─────────────────────────────────────────
    const lightTextPrimary = Color(0xFF0F172A);
    const lightTextSecondary = Color(0xFF334155);
    const lightTextMuted = Color(0xFF64748B);
    const lightBorder = Color(0xFFCBD5E1);
    const lightSurface = Color(0xFFF8FAFC);
    const lightBackground = Color(0xFFF1F5F9);
    const primaryCyan = Color(0xFF0098A6);

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryCyan,
      scaffoldBackgroundColor: lightBackground,
      cardColor: Colors.white,
      fontFamily: 'Segoe UI',
      colorScheme: const ColorScheme.light(
        primary: primaryCyan,
        secondary: AppColors.electricPurple,
        surface: Colors.white,
        error: AppColors.error,
      ),
      dividerColor: lightBorder,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: lightBorder),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w900),
        headlineMedium: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w800),
        headlineSmall: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w800),
        titleLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w700),
        titleSmall: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: lightTextPrimary, fontSize: 14),
        bodyMedium: TextStyle(color: lightTextSecondary, fontSize: 13),
        bodySmall: TextStyle(color: lightTextMuted, fontSize: 11),
        labelLarge: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w800),
        labelMedium: TextStyle(color: lightTextSecondary, fontWeight: FontWeight.w700),
        labelSmall: TextStyle(color: lightTextMuted, fontWeight: FontWeight.w600),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(lightSurface),
        dataRowColor: WidgetStateProperty.all(Colors.white),
        headingTextStyle: const TextStyle(fontWeight: FontWeight.w900, color: lightTextPrimary, fontSize: 11),
        dataTextStyle: const TextStyle(color: lightTextPrimary, fontSize: 12),
        dividerThickness: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryCyan),
        titleTextStyle: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCyan,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryCyan,
          side: const BorderSide(color: primaryCyan, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryCyan, width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightTextPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── CYBORG Dark Mode ──────────────────────────────────────────
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.neonCyan,
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.card,
    fontFamily: 'Segoe UI',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.neonCyan,
      secondary: AppColors.electricPurple,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    dividerColor: AppColors.border,
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w900),
      headlineMedium: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w800),
      headlineSmall: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w800),
      titleLarge: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w800),
      titleMedium: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w700),
      titleSmall: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(color: AppColors.textWhite, fontSize: 14),
      bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      bodySmall: TextStyle(color: AppColors.textMuted, fontSize: 11),
      labelLarge: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w800),
      labelMedium: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
      labelSmall: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStateProperty.all(AppColors.surface),
      dataRowColor: WidgetStateProperty.all(AppColors.card),
      headingTextStyle: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textWhite, fontSize: 11),
      dataTextStyle: const TextStyle(color: AppColors.textWhite, fontSize: 12),
      dividerThickness: 1,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.neonCyan),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neonCyan,
        foregroundColor: AppColors.textOnCyan,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.5),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.neonCyan,
        side: const BorderSide(color: AppColors.neonCyan, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surface,
      contentTextStyle: const TextStyle(color: AppColors.textWhite),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Helpful [BuildContext] extension for clean theme-aware access across widgets
extension ThemeContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  bool get isDark => theme.brightness == Brightness.dark;
  Color get scaffoldBg => theme.scaffoldBackgroundColor;
  Color get cardBg => theme.cardColor;
  Color get surfaceBg => isDark ? AppColors.surface : const Color(0xFFF8FAFC);
  Color get borderColor => isDark ? AppColors.border : const Color(0xFFCBD5E1);
  Color get textPrimary => isDark ? AppColors.textWhite : const Color(0xFF0F172A);
  Color get textSecondary => isDark ? AppColors.textSecondary : const Color(0xFF334155);
  Color get textMuted => isDark ? AppColors.textMuted : const Color(0xFF64748B);
}
