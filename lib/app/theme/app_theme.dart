import 'package:flutter/material.dart';

class AppPalette {
  static const ink = Color(0xFF183028);
  static const moss = Color(0xFF4C8B6B);
  static const mint = Color(0xFFBFE5CF);
  static const cream = Color(0xFFF7F2E8);
  static const sand = Color(0xFFE8DCC6);
  static const sky = Color(0xFFCFE6F5);
  static const sunrise = Color(0xFFFFC787);
  static const coral = Color(0xFFE97C5E);
  static const danger = Color(0xFFD94C3D);
  static const warning = Color(0xFFF0A63A);
  static const info = Color(0xFF5A96C9);
  static const line = Color(0xFFDACFBC);
  static const textPrimary = Color(0xFF21342B);
  static const textSecondary = Color(0xFF5A6F66);
  static const white = Color(0xFFFFFFFF);
}

class AppGradients {
  static const page = LinearGradient(
    colors: [Color(0xFFF8F3EA), Color(0xFFF0F7F2), Color(0xFFEFF6FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const hero = LinearGradient(
    colors: [Color(0xFF5D9274), Color(0xFF83B79A), Color(0xFFF2E4C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accent = LinearGradient(
    colors: [Color(0xFF4C8B6B), Color(0xFF79A98C)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.moss,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppPalette.moss,
      onPrimary: AppPalette.white,
      secondary: AppPalette.info,
      onSecondary: AppPalette.white,
      error: AppPalette.danger,
      onError: AppPalette.white,
      surface: AppPalette.white,
      onSurface: AppPalette.textPrimary,
      outline: AppPalette.line,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppPalette.cream,
      fontFamily: 'PingFang SC',
      cardColor: AppPalette.white,
      dividerColor: AppPalette.line,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          color: AppPalette.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppPalette.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppPalette.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: AppPalette.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: AppPalette.textSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppPalette.textPrimary,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.moss,
          foregroundColor: AppPalette.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          foregroundColor: AppPalette.textPrimary,
          side: const BorderSide(color: AppPalette.line),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppPalette.sand,
        selectedColor: AppPalette.mint,
        disabledColor: AppPalette.cream,
        labelStyle: const TextStyle(color: AppPalette.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        side: const BorderSide(color: AppPalette.line),
      ),
    );
  }
}