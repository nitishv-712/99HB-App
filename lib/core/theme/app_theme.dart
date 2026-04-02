import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const primary = Color(0xFFA63B00);
  static const onPrimary = Colors.white;
  static const primaryContainer = Color(0xFFF26522);
  static const onPrimaryContainer = Color(0xFF4F1800);
  static const primaryFixed = Color(0xFFFFDBCE);

  static const secondary = Color(0xFF5F5E5E);
  static const onSecondary = Colors.white;
  static const secondaryContainer = Color(0xFFE4E2E1);
  static const onSecondaryContainer = Color(0xFF656464);

  static const tertiary = Color(0xFFA13B0E);
  static const onTertiary = Colors.white;
  static const tertiaryContainer = Color(0xFFC15226);
  static const onTertiaryContainer = Colors.white;
  static const tertiaryFixed = Color(0xFFFFDBCF);

  static const error = Color(0xFFBA1A1A);
  static const onError = Colors.white;
  static const errorContainer = Color(0xFFFFDAD6);

  static const surface = Color(0xFFFFF8F5);
  static const onSurface = Color(0xFF231A11);
  static const onSurfaceVariant = Color(0xFF594138);
  static const surfaceContainer = Color(0xFFFDEBDC);
  static const surfaceContainerLow = Color(0xFFFFF1E7);
  static const surfaceContainerHigh = Color(0xFFF8E5D6);
  static const surfaceContainerLowest = Colors.white;
  static const surfaceContainerHighest = Color(0xFFF2DFD1);

  static const outline = Color(0xFF8D7166);
  static const outlineVariant = Color(0xFFE1BFB3);

  static const inverseSurface = Color(0xFF392E25);
  static const inverseOnSurface = Color(0xFFFFEEE0);
  static const inversePrimary = Color(0xFFFFB599);

  // Gradient used for CTA buttons
  static const gradientCta = LinearGradient(colors: [primary, primaryContainer]);
}

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondaryContainer: AppColors.onSecondaryContainer,
          tertiary: AppColors.tertiary,
          onTertiary: AppColors.onTertiary,
          tertiaryContainer: AppColors.tertiaryContainer,
          onTertiaryContainer: AppColors.onTertiaryContainer,
          error: AppColors.error,
          onError: AppColors.onError,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          onSurfaceVariant: AppColors.onSurfaceVariant,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
          inverseSurface: AppColors.inverseSurface,
          onInverseSurface: AppColors.inverseOnSurface,
          inversePrimary: AppColors.inversePrimary,
        ),
        scaffoldBackgroundColor: AppColors.surface,
        textTheme: GoogleFonts.interTextTheme().copyWith(
          displayLarge: GoogleFonts.notoSerif(fontWeight: FontWeight.w900),
          displayMedium: GoogleFonts.notoSerif(fontWeight: FontWeight.w900),
          displaySmall: GoogleFonts.notoSerif(fontWeight: FontWeight.w900),
          headlineLarge: GoogleFonts.notoSerif(fontWeight: FontWeight.w900),
          headlineMedium: GoogleFonts.notoSerif(fontWeight: FontWeight.bold),
          headlineSmall: GoogleFonts.notoSerif(fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.notoSerif(fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Color(0x66231A11),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      );
}
