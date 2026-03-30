import 'package:flutter/material.dart';
import '../../config/design_tokens.dart';

/// ZONE 3: Action Item
/// Minimal info - doctor should immediately know what to click
class ActionItem extends StatelessWidget {
  final String patientName;
  final String primaryInfo; // What needs attention
  final String? secondaryInfo; // Optional context
  final ActionPriority priority;
  final VoidCallback onTap;

  const ActionItem({
    super.key,
    required this.patientName,
    required this.primaryInfo,
    this.secondaryInfo,
    required this.priority,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: DesignTokens.spaceLg,
          horizontal: DesignTokens.spaceMd,
        ),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: _getPriorityColor(),
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: DesignTokens.spaceMd),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient name - clear and bold
                  Text(
                    patientName,
                    style: DesignTokens.headingSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Primary info - what needs attention
                  Text(
                    primaryInfo,
                    style: DesignTokens.bodyLarge.copyWith(
                      color: _getPriorityColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Secondary info - optional context
                  if (secondaryInfo != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      secondaryInfo!,
                      style: DesignTokens.bodyMedium.copyWith(
                        color: DesignTokens.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: DesignTokens.textSecondary,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (priority) {
      case ActionPriority.high:
        return DesignTokens.error;
      case ActionPriority.medium:
        return DesignTokens.warning;
      case ActionPriority.low:
        return DesignTokens.clinicalTeal;
    }
  }

  Color _getBorderColor() {
    switch (priority) {
      case ActionPriority.high:
        return DesignTokens.error.withOpacity(0.3);
      case ActionPriority.medium:
        return DesignTokens.warning.withOpacity(0.3);
      case ActionPriority.low:
        return DesignTokens.borderGray.withOpacity(0.4);
    }
  }
}

enum ActionPriority {
  high,   // Low confidence or urgent
  medium, // Moderate confidence or needs review
  low,    // Normal follow-up
}
