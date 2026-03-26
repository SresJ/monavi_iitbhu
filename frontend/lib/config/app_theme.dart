import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// App theme configuration for Clinical AI Dashboard
class AppTheme {
  AppTheme._();

  /// Dark theme (AMOLED)
  static ThemeData get darkTheme {
    return ThemeData(
      // Use Material 3
      useMaterial3: true,

      // Brightness
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: DesignTokens.medicalBlue,
        secondary: DesignTokens.clinicalTeal,
        surface: DesignTokens.cardBlack,
        error: DesignTokens.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: DesignTokens.textPrimary,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: DesignTokens.voidBlack,

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: DesignTokens.surfaceBlack,
        elevation: 0,
        titleTextStyle: DesignTokens.headingMedium,
        iconTheme: const IconThemeData(color: DesignTokens.textPrimary),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: DesignTokens.cardBlack,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radiusMd,
          side: BorderSide(color: DesignTokens.borderGray, width: 1),
        ),
        shadowColor: Colors.black.withOpacity(0.2),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.cardBlack,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMd,
          vertical: DesignTokens.spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: DesignTokens.radiusMd,
          borderSide: const BorderSide(
            color: DesignTokens.borderGray,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DesignTokens.radiusMd,
          borderSide: const BorderSide(
            color: DesignTokens.borderGray,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DesignTokens.radiusMd,
          borderSide: const BorderSide(
            color: DesignTokens.clinicalTeal,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DesignTokens.radiusMd,
          borderSide: const BorderSide(color: DesignTokens.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: DesignTokens.radiusMd,
          borderSide: const BorderSide(color: DesignTokens.error, width: 2),
        ),
        labelStyle: DesignTokens.bodyMedium,
        hintStyle: DesignTokens.bodyMedium.copyWith(
          color: DesignTokens.textTertiary,
        ),
        errorStyle: DesignTokens.bodySmall.copyWith(color: DesignTokens.error),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.medicalBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: DesignTokens.spaceMd,
          ),
          shape: RoundedRectangleBorder(borderRadius: DesignTokens.radiusMd),
          textStyle: DesignTokens.labelLarge,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DesignTokens.clinicalTeal,
          textStyle: DesignTokens.labelLarge,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.clinicalTeal,
          side: const BorderSide(color: DesignTokens.clinicalTeal, width: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: DesignTokens.spaceMd,
          ),
          shape: RoundedRectangleBorder(borderRadius: DesignTokens.radiusMd),
          textStyle: DesignTokens.labelLarge,
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: DesignTokens.medicalBlue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: DesignTokens.borderGray,
        thickness: 1,
        space: DesignTokens.spaceMd,
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: DesignTokens.textPrimary, size: 24),

      // Text theme
      textTheme: TextTheme(
        displayLarge: DesignTokens.displayLarge,
        displayMedium: DesignTokens.displayMedium,
        displaySmall: DesignTokens.displaySmall,
        headlineLarge: DesignTokens.headingLarge,
        headlineMedium: DesignTokens.headingMedium,
        headlineSmall: DesignTokens.headingSmall,
        bodyLarge: DesignTokens.bodyLarge,
        bodyMedium: DesignTokens.bodyMedium,
        bodySmall: DesignTokens.bodySmall,
        labelLarge: DesignTokens.labelLarge,
        labelMedium: DesignTokens.labelMedium,
        labelSmall: DesignTokens.labelSmall,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: DesignTokens.cardBlack,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.radiusLg),
        titleTextStyle: DesignTokens.headingMedium,
        contentTextStyle: DesignTokens.bodyMedium,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DesignTokens.surfaceBlack,
        selectedItemColor: DesignTokens.clinicalTeal,
        unselectedItemColor: DesignTokens.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: DesignTokens.cardBlack,
        labelStyle: DesignTokens.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMd,
          vertical: DesignTokens.spaceSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radiusSm,
          side: const BorderSide(color: DesignTokens.borderGray, width: 1),
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DesignTokens.cardBlack,
        contentTextStyle: DesignTokens.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: DesignTokens.radiusMd),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: DesignTokens.clinicalTeal,
      ),

      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: DesignTokens.cardBlack,
          borderRadius: DesignTokens.radiusSm,
          border: Border.all(color: DesignTokens.borderGray, width: 1),
        ),
        textStyle: DesignTokens.bodySmall,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMd,
          vertical: DesignTokens.spaceSm,
        ),
      ),
    );
  }
}
