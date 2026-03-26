import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the Clinical AI Dashboard
/// Medical blue/teal on AMOLED black theme
class DesignTokens {
  // Private constructor to prevent instantiation
  DesignTokens._();

  // ==================== COLORS ====================

  // Background layers (AMOLED)
  static const voidBlack = Color(0xFF000000);
  static const surfaceBlack = Color(0xFF0A0A0C);
  static const cardBlack = Color(0xFF121216);
  static const borderGray = Color(0xFF1C1E21);

  // Primary palette (Medical Blue/Teal)
  static const medicalBlue = Color(0xFF1E88E5);
  static const clinicalTeal = Color(0xFF00ACC1);
  static const deepBlue = Color(0xFF1565C0);

  // Confidence levels (Sober, professional tones)
  static const confidenceHigh = Color(0xFF4ADE80); // Softer green
  static const confidenceMed = Color(0xFFFBBF24); // Softer amber/gold
  static const confidenceLow = Color(0xFFF87171); // Softer coral red

  // Semantic colors (muted)
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const error = Color(0xFFF87171);

  // Selected/Active state (teal-based instead of red)
  static const selectedAccent = Color(0xFF2DD4BF); // Soft teal for selected cards

  // Text hierarchy
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB4B4B4);
  static const textTertiary = Color(0xFF6B7280);

  // ==================== TYPOGRAPHY ====================
  // Poppins for titles/headings (elegant, professional)
  // Inter for body text (clean, readable)

  // Display styles - Poppins for impact
  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: textPrimary,
  );

  static TextStyle get displayMedium => GoogleFonts.poppins(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: textPrimary,
  );

  static TextStyle get displaySmall => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: textPrimary,
  );

  // Heading styles - Poppins for visual hierarchy
  static TextStyle get headingLarge => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.5,
    color: textPrimary,
  );

  static TextStyle get headingMedium => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
    color: textPrimary,
  );

  static TextStyle get headingSmall => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: textPrimary,
  );

  // Body styles - INCREASED for clinical readability
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: textSecondary,
  );

  // Label styles - INCREASED
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: textPrimary,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: textSecondary,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: textTertiary,
  );

  // ==================== SPACING ====================
  // Generous spacing for clinical clarity

  static const double spaceXs = 6.0;
  static const double spaceSm = 12.0;
  static const double spaceMd = 20.0;
  static const double spaceLg = 26.0;
  static const double spaceXl = 48.0;
  static const double spaceXxl = 64.0;
  static const double spaceXxxl = 96.0;

  // ==================== SHADOWS & GLOWS ====================

  // Depth shadows (glassmorphism)
  static List<BoxShadow> get depth1 => [
    BoxShadow(
      offset: const Offset(0, 2),
      blurRadius: 8,
      color: Colors.black.withOpacity(0.1),
    ),
  ];

  static List<BoxShadow> get depth2 => [
    BoxShadow(
      offset: const Offset(0, 4),
      blurRadius: 16,
      color: Colors.black.withOpacity(0.15),
    ),
  ];

  static List<BoxShadow> get depth3 => [
    BoxShadow(
      offset: const Offset(0, 8),
      blurRadius: 32,
      color: Colors.black.withOpacity(0.2),
    ),
  ];

  // Neon glows (medical blue/teal)
  static List<BoxShadow> get glowBlue => [
    BoxShadow(
      offset: const Offset(0, 0),
      blurRadius: 16,
      color: medicalBlue.withOpacity(0.4),
    ),
  ];

  static List<BoxShadow> get glowTeal => [
    BoxShadow(
      offset: const Offset(0, 0),
      blurRadius: 16,
      color: clinicalTeal.withOpacity(0.4),
    ),
  ];

  static List<BoxShadow> get glowGreen => [
    BoxShadow(
      offset: const Offset(0, 0),
      blurRadius: 12,
      color: confidenceHigh.withOpacity(0.25),
    ),
  ];

  static List<BoxShadow> get glowAmber => [
    BoxShadow(
      offset: const Offset(0, 0),
      blurRadius: 12,
      color: confidenceMed.withOpacity(0.25),
    ),
  ];

  static List<BoxShadow> get glowRed => [
    BoxShadow(
      offset: const Offset(0, 0),
      blurRadius: 12,
      color: confidenceLow.withOpacity(0.25),
    ),
  ];

  // Selected/Active glow (teal-based)
  static List<BoxShadow> get glowSelected => [
    BoxShadow(
      offset: const Offset(0, 0),
      blurRadius: 16,
      color: selectedAccent.withOpacity(0.35),
    ),
  ];

  // ==================== ANIMATION DURATIONS ====================

  static const Duration quick = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // ==================== BORDER RADIUS ====================

  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(24));

  // ==================== HELPER METHODS ====================

  /// Get confidence color based on level
  static Color getConfidenceColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return confidenceHigh;
      case 'medium':
      case 'med':
        return confidenceMed;
      case 'low':
        return confidenceLow;
      default:
        return textSecondary;
    }
  }

  /// Get confidence glow based on level
  static List<BoxShadow> getConfidenceGlow(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return glowGreen;
      case 'medium':
      case 'med':
        return glowAmber;
      case 'low':
        return glowRed;
      default:
        return [];
    }
  }

  /// Create gradient for medical blue/teal
  static LinearGradient get medicalGradient => const LinearGradient(
    colors: [medicalBlue, clinicalTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Create gradient for text
  static LinearGradient get textGradient => const LinearGradient(
    colors: [medicalBlue, clinicalTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
