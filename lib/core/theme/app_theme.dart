import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color Palette ─────────────────────────────────────────────────────────────

abstract final class AppColors {
  // Primary – deep indigo-teal
  // Primary – Red (#E43636)
  static const primary = Color(0xFFE43636);
  static const onPrimary = Colors.white;
  static const primaryContainer = Color(0xFFFFDAD6); // Lightened tint
  static const onPrimaryContainer = Color(0xFF410002);
  static const primaryFixed = Color(0xFFFFDAD6);

  // Secondary – Tan/Sage (#E2DDB4)
  static const secondary = Color(0xFFE2DDB4);
  static const onSecondary = Color(0xFF000000); // Black for contrast
  static const secondaryContainer = Color(0xFFF6EFD2); // Using the Cream color
  static const onSecondaryContainer = Color(0xFF1D1D00);

  // Tertiary – Cream (#F6EFD2)
  static const tertiary = Color(0xFFF6EFD2);
  static const onTertiary = Color(0xFF000000);
  static const tertiaryContainer = Color(0xFFFFFFFF);
  static const onTertiaryContainer = Color(0xFF1F1C05);
  static const tertiaryFixed = Color(0xFFF6EFD2);

  // Error
  static const error = Color(0xFFBA1A1A);
  static const onError = Colors.white;
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF410002);

  // Neutral surface tones – Using Black (#000000) as the foundation
  static const surface = Color(0xFFFFFFFF); // Keep white for readability
  static const onSurface = Color(0xFF000000); // True Black
  static const surfaceVariant = Color(0xFFE2DDB4); // Tan as variant
  static const onSurfaceVariant = Color(0xFF494836);

  static const surfaceContainer = Color(0xFFF6EFD2); // Cream for containers
  static const surfaceContainerLow = Color(0xFFFAF7E8);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerHigh = Color(0xFFF0E9C7);
  static const surfaceContainerHighest = Color(0xFFEBE3BD);

  // Outline
  static const outline = Color(0xFF000000); // Black outlines for a bold look
  static const outlineVariant = Color(0xFFE2DDB4);
  // static const primary = Color(0xFF2563EB);
  // static const onPrimary = Colors.white;
  // static const primaryContainer = Color(0xFFDBEAFE);
  // static const onPrimaryContainer = Color(0xFF1E3A5F);
  // static const primaryFixed = Color(0xFFEFF6FF);

  // // Secondary – slate
  // static const secondary = Color(0xFF6366F1);
  // static const onSecondary = Colors.white;
  // static const secondaryContainer = Color(0xFFE0E7FF);
  // static const onSecondaryContainer = Color(0xFF312E81);

  // // Tertiary – amber/gold
  // static const tertiary = Color(0xFFD97706);
  // static const onTertiary = Colors.white;
  // static const tertiaryContainer = Color(0xFFFEF3C7);
  // static const onTertiaryContainer = Color(0xFF78350F);
  // static const tertiaryFixed = Color(0xFFFFFBEB);

  // // Error
  // static const error = Color(0xFFDC2626);
  // static const onError = Colors.white;
  // static const errorContainer = Color(0xFFFEE2E2);
  // static const onErrorContainer = Color(0xFF7F1D1D);

  // // Neutral surface tones
  // static const surface = Color(0xFFFAFAFC);
  // static const onSurface = Color(0xFF0F172A);
  // static const surfaceVariant = Color(0xFFF1F5F9);
  // static const onSurfaceVariant = Color(0xFF475569);
  // static const surfaceContainer = Color(0xFFF1F5F9);
  // static const surfaceContainerLow = Color(0xFFF8FAFC);
  // static const surfaceContainerLowest = Color(0xFFFFFFFF);
  // static const surfaceContainerHigh = Color(0xFFE2E8F0);
  // static const surfaceContainerHighest = Color(0xFFCBD5E1);

  // // Outline
  // static const outline = Color(0xFF94A3B8);
  // static const outlineVariant = Color(0xFFCBD5E1);

  // Gradient
  static const gradientCta = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF434343)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const gradientCtaVertical = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF434343)],
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
  primary: const Color(0xFF60A5FA), // Bright blue for visibility
  onPrimary: const Color(0xFF0C2340), // Very dark blue for contrast
  primaryContainer: const Color(0xFF1E3A5F), // Medium dark blue
  onPrimaryContainer: const Color(0xFFDBEAFE), // Light blue tint
  secondary: const Color(0xFF818CF8), // Bright indigo
  onSecondary: const Color(0xFF0F0D2E), // Very dark indigo
  secondaryContainer: const Color(0xFF2E2A5E), // Medium dark indigo
  onSecondaryContainer: const Color(0xFFE0E7FF), // Light indigo tint
  tertiary: const Color(0xFFFBBF24), // Bright amber
  onTertiary: const Color(0xFF1A0F00), // Very dark amber
  tertiaryContainer: const Color(0xFF4A2400), // Medium dark amber
  onTertiaryContainer: const Color(0xFFFEF3C7), // Light amber tint
  error: const Color(0xFFF87171), // Bright red
  onError: const Color(0xFF2D0A0A), // Very dark red
  errorContainer: const Color(
    0xFF5C1515,
  ), // Medium dark red (fixed from too dark)
  onErrorContainer: const Color(0xFFFEE2E2), // Light red tint
  surface: const Color(0xFF0F172A), // Dark slate background
  onSurface: const Color(0xFFF1F5F9), // Light text on dark
  surfaceContainerHighest: const Color(0xFF334155), // Lightest surface variant
  surfaceContainerHigh: const Color(0xFF1E293B), // Lighter surface variant
  surfaceContainer: const Color(0xFF1E293B), // Default surface variant
  surfaceContainerLow: const Color(
    0xFF0C1425,
  ), // Darker surface variant (fixed)
  surfaceContainerLowest: const Color(0xFF0B1222), // Darkest surface variant
  onSurfaceVariant: const Color(0xFF94A3B8), // Muted text
  outline: const Color(0xFF475569), // Medium outline
  outlineVariant: const Color(0xFF334155), // Subtle outline
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

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface.withOpacity(0.92),
      foregroundColor: cs.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.notoSerif(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: cs.onSurface,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: cs.onSurface),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainer,
      hintStyle: GoogleFonts.inter(
        color: cs.onSurfaceVariant.withOpacity(0.5),
        fontSize: 14,
      ),
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

    // ElevatedButton
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

    // OutlinedButton
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

    // TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: cs.primary,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    ),

    // Card
    cardTheme: CardThemeData(
      color: cs.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: cs.outlineVariant.withOpacity(0.4),
      thickness: 1,
      space: 1,
    ),

    // BottomSheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cs.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: cs.surfaceContainer,
      labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide.none,
    ),

    // ListTile
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

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cs.onSurface,
      contentTextStyle: GoogleFonts.inter(color: cs.surface, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),

    // FloatingActionButton
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      elevation: 4,
      shape: const CircleBorder(),
    ),

    // Icon
    iconTheme: IconThemeData(color: cs.onSurface, size: 24),

    // Progress indicator
    progressIndicatorTheme: ProgressIndicatorThemeData(color: cs.primary),

    // Switch
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
