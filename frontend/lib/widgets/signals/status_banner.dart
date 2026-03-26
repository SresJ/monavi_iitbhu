import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';

/// ZONE 1: Current Status Banner
/// Shows dominant insight - calm or alarming based on data
class StatusBanner extends StatelessWidget {
  final String primaryMessage;
  final String? secondaryMessage;
  final StatusLevel level;

  const StatusBanner({
    Key? key,
    required this.primaryMessage,
    this.secondaryMessage,
    required this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PRIMARY MESSAGE - massive, declarative statement
          Text(
            primaryMessage,
            style: GoogleFonts.inter(
              fontSize: 56,
              fontWeight: FontWeight.w600,
              height: 1.1,
              letterSpacing: -1.5,
              color: _getTextColor(),
            ),
          ),
          if (secondaryMessage != null) ...[
            const SizedBox(height: DesignTokens.spaceLg),
            Text(
              secondaryMessage!,
              style: DesignTokens.headingSmall.copyWith(
                color: DesignTokens.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (level) {
      case StatusLevel.calm:
        return DesignTokens.cardBlack;
      case StatusLevel.attention:
        return DesignTokens.warning.withOpacity(0.1);
      case StatusLevel.urgent:
        return DesignTokens.error.withOpacity(0.15);
    }
  }

  Color _getBorderColor() {
    switch (level) {
      case StatusLevel.calm:
        return DesignTokens.clinicalTeal.withOpacity(0.3);
      case StatusLevel.attention:
        return DesignTokens.warning.withOpacity(0.5);
      case StatusLevel.urgent:
        return DesignTokens.error.withOpacity(0.6);
    }
  }

  Color _getTextColor() {
    switch (level) {
      case StatusLevel.calm:
        return DesignTokens.textPrimary;
      case StatusLevel.attention:
        return DesignTokens.warning;
      case StatusLevel.urgent:
        return DesignTokens.error;
    }
  }
}

enum StatusLevel {
  calm,      // Everything normal
  attention, // Something needs review
  urgent,    // Immediate action needed
}
