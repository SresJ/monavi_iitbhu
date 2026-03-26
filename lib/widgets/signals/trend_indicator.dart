import 'package:flutter/material.dart';
import '../../config/design_tokens.dart';

/// ZONE 2: Trend Indicator
/// Visual metaphor for trends - no numbers unless necessary
class TrendIndicator extends StatelessWidget {
  final String label;
  final TrendDirection direction;
  final String? value; // Optional - only show if meaningful

  const TrendIndicator({
    Key? key,
    required this.label,
    required this.direction,
    this.value,
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

        // Visual trend - icon + text
        Row(
          children: [
            Icon(
              _getTrendIcon(),
              size: 56,
              color: _getTrendColor(),
            ),
            const SizedBox(width: DesignTokens.spaceLg),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTrendText(),
                    style: DesignTokens.headingLarge.copyWith(
                      color: _getTrendColor(),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (value != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      value!,
                      style: DesignTokens.bodyLarge.copyWith(
                        color: DesignTokens.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getTrendIcon() {
    switch (direction) {
      case TrendDirection.up:
        return Icons.trending_up_rounded;
      case TrendDirection.stable:
        return Icons.trending_flat_rounded;
      case TrendDirection.down:
        return Icons.trending_down_rounded;
    }
  }

  Color _getTrendColor() {
    switch (direction) {
      case TrendDirection.up:
        return DesignTokens.medicalBlue;
      case TrendDirection.stable:
        return DesignTokens.clinicalTeal;
      case TrendDirection.down:
        return DesignTokens.textSecondary;
    }
  }

  String _getTrendText() {
    switch (direction) {
      case TrendDirection.up:
        return 'Increasing';
      case TrendDirection.stable:
        return 'Stable';
      case TrendDirection.down:
        return 'Decreasing';
    }
  }
}

enum TrendDirection {
  up,
  stable,
  down,
}
