import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color Palette ─────────────────────────────────────────────────────────────

abstract final class AppColors {
  // Primary – Red
  static const primary = Color(0xFFE43636);
  static const onPrimary = Colors.white;
  static const primaryContainer = Color(0xFFFFDAD6);
  static const onPrimaryContainer = Color(0xFF410002);
  static const primaryFixed = Color(0xFFFFDAD6);

  // Secondary – warm tan
  static const secondary = Color(0xFFC8C09A);
  static const onSecondary = Color(0xFF1A1800);
  static const secondaryContainer = Color(0xFFF0EBD8);
  static const onSecondaryContainer = Color(0xFF1D1D00);

  // Tertiary
  static const tertiary = Color(0xFFF6EFD2);
  static const onTertiary = Color(0xFF1A1800);
  static const tertiaryContainer = Color(0xFFFFFFFF);
  static const onTertiaryContainer = Color(0xFF1F1C05);
  static const tertiaryFixed = Color(0xFFF6EFD2);

  // Error
  static const error = Color(0xFFBA1A1A);
  static const onError = Colors.white;
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF410002);

  // Surfaces – clean warm whites
  static const surface = Color(0xFFFFFDF7);
  static const onSurface = Color(0xFF1A1814);
  static const surfaceVariant = Color(0xFFF0EBD8);
  static const onSurfaceVariant = Color(0xFF5C5640);

  static const surfaceContainer = Color(0xFFF5F0E8);
  static const surfaceContainerLow = Color(0xFFFAF7F0);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerHigh = Color(0xFFEDE7D8);
  static const surfaceContainerHighest = Color(0xFFE5DFD0);

  // Outline
  static const outline = Color(0xFF8A8470);
  static const outlineVariant = Color(0xFFD8D2C0);

  // Gradients
  static const gradientCta = LinearGradient(
    colors: [Color(0xFF1A1814), Color(0xFF3D3830)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const gradientCtaVertical = LinearGradient(
    colors: [Color(0xFF1A1814), Color(0xFF3D3830)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ── Light ColorScheme ─────────────────────────────────────────────────────────

final _lightColorScheme = ColorScheme(
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
  errorContainer: AppColors.errorContainer,
  onErrorContainer: AppColors.onErrorContainer,
  surface: AppColors.surface,
  onSurface: AppColors.onSurface,
  surfaceContainerHighest: AppColors.surfaceContainerHighest,
  surfaceContainerHigh: AppColors.surfaceContainerHigh,
  surfaceContainer: AppColors.surfaceContainer,
  surfaceContainerLow: AppColors.surfaceContainerLow,
  surfaceContainerLowest: AppColors.surfaceContainerLowest,
  onSurfaceVariant: AppColors.onSurfaceVariant,
  outline: AppColors.outline,
  outlineVariant: AppColors.outlineVariant,
);

// ── Dark ColorScheme ──────────────────────────────────────────────────────────

final _darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: const Color(0xFFFF6B6B),
  onPrimary: const Color(0xFF5A0000),
  primaryContainer: const Color(0xFF7A0000),
  onPrimaryContainer: const Color(0xFFFFDAD6),
  secondary: const Color(0xFFCFC5A0),
  onSecondary: const Color(0xFF332D10),
  secondaryContainer: const Color(0xFF4A4428),
  onSecondaryContainer: const Color(0xFFEDE3BC),
  tertiary: const Color(0xFFD4C98A),
  onTertiary: const Color(0xFF363100),
  tertiaryContainer: const Color(0xFF4F4800),
  onTertiaryContainer: const Color(0xFFF1E5A1),
  error: const Color(0xFFFF8A80),
  onError: const Color(0xFF5A0000),
  errorContainer: const Color(0xFF7A0000),
  onErrorContainer: const Color(0xFFFFDAD6),
  surface: const Color(0xFF141210),
  onSurface: const Color(0xFFF8F5F0),
  surfaceContainerHighest: const Color(0xFF48443C),
  surfaceContainerHigh: const Color(0xFF343028),
  surfaceContainer: const Color(0xFF201E18),
  surfaceContainerLow: const Color(0xFF1A1814),
  surfaceContainerLowest: const Color(0xFF0F0E0C),
  onSurfaceVariant: const Color(0xFFD4CFC2),
  outline: const Color(0xFF8A8070),
  outlineVariant: const Color(0xFF5A5650),
);

// ── TextTheme helper ──────────────────────────────────────────────────────────

TextTheme _buildTextTheme(ColorScheme cs) => GoogleFonts.interTextTheme(
  TextTheme(
    displayLarge: GoogleFonts.notoSerif(
      fontSize: 57,
      fontWeight: FontWeight.w900,
      color: cs.onSurface,
      height: 1.1,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.notoSerif(
      fontSize: 45,
      fontWeight: FontWeight.w900,
      color: cs.onSurface,
      height: 1.1,
    ),
    displaySmall: GoogleFonts.notoSerif(
      fontSize: 36,
      fontWeight: FontWeight.w900,
      color: cs.onSurface,
      height: 1.15,
    ),
    headlineLarge: GoogleFonts.notoSerif(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: cs.onSurface,
    ),
    headlineMedium: GoogleFonts.notoSerif(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: cs.onSurface,
    ),
    headlineSmall: GoogleFonts.notoSerif(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: cs.onSurface,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: cs.onSurface,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: cs.onSurface,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: cs.onSurface,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: cs.onSurface,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: cs.onSurface,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: cs.onSurfaceVariant,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    ),
  ),
);

// ── ThemeData factory ─────────────────────────────────────────────────────────

ThemeData _buildTheme(ColorScheme cs) {
  final text = _buildTextTheme(cs);
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    textTheme: text,
    scaffoldBackgroundColor: cs.surface,

    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: GoogleFonts.notoSerif(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: cs.onSurface,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: cs.onSurface),
      surfaceTintColor: Colors.transparent,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainer,
      hintStyle: GoogleFonts.inter(color: cs.onSurfaceVariant, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error, width: 1.5),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          fontSize: 13,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.primary,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: cs.outlineVariant),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: cs.primary,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    ),

    cardTheme: CardThemeData(
      color: cs.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),

    dividerTheme: DividerThemeData(
      color: cs.outlineVariant.withValues(alpha: 0.5),
      thickness: 1,
      space: 1,
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cs.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: cs.surfaceContainer,
      labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide.none,
    ),

    listTileTheme: ListTileThemeData(
      titleTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: cs.onSurface,
      ),
      subtitleTextStyle: GoogleFonts.inter(
        fontSize: 12,
        color: cs.onSurfaceVariant,
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: cs.onSurface,
      contentTextStyle: GoogleFonts.inter(color: cs.surface, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      elevation: 4,
      shape: const CircleBorder(),
    ),

    iconTheme: IconThemeData(color: cs.onSurface, size: 24),

    progressIndicatorTheme: ProgressIndicatorThemeData(color: cs.primary),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? cs.primary : cs.outline,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? cs.primaryContainer
            : cs.surfaceContainerHigh,
      ),
    ),
  );
}

// ── Public accessors ──────────────────────────────────────────────────────────

final appLightTheme = _buildTheme(_lightColorScheme);
final appDarkTheme = _buildTheme(_darkColorScheme);
