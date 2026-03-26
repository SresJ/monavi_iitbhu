import 'package:flutter/material.dart';
import '../../config/design_tokens.dart';

/// ZONE 2: Confidence Visual
/// Shows AI diagnostic confidence as a visual metaphor
class ConfidenceVisual extends StatelessWidget {
  final String label;
  final double confidenceScore; // 0.0 to 1.0
  final String? insight; // Optional clinical insight

  const ConfidenceVisual({
    Key? key,
    required this.label,
    required this.confidenceScore,
    this.insight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label - larger, declarative
        Text(
          label,
          style: DesignTokens.headingSmall.copyWith(
            color: DesignTokens.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceMd),

        // Confidence level text - LARGE and prominent
        Text(
          _getConfidenceLevel(),
          style: DesignTokens.headingLarge.copyWith(
            color: _getConfidenceColor(),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceLg),

        // Visual bar - larger, more prominent
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 24,
            child: LinearProgressIndicator(
              value: confidenceScore,
              backgroundColor: DesignTokens.surfaceBlack,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getConfidenceColor(),
              ),
            ),
          ),
        ),

        // Optional insight
        if (insight != null) ...[
          const SizedBox(height: DesignTokens.spaceMd),
          Text(
            insight!,
            style: DesignTokens.bodyLarge.copyWith(
              color: DesignTokens.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  String _getConfidenceLevel() {
    if (confidenceScore >= 0.8) return 'High Confidence';
    if (confidenceScore >= 0.5) return 'Moderate';
    return 'Low Confidence';
  }

  Color _getConfidenceColor() {
    if (confidenceScore >= 0.8) return DesignTokens.confidenceHigh;
    if (confidenceScore >= 0.5) return DesignTokens.confidenceMed;
    return DesignTokens.confidenceLow;
  }
}
