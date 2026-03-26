import 'package:flutter/material.dart';
import '../../config/design_tokens.dart';

/// Feedback state for each AI response
class FeedbackState {
  final bool feedbackSubmitted;
  final String? feedbackType; // "accurate" or "needs_correction"
  final String? selectedTag;
  final String? inaccuracyDescription;
  final String? correctedInput;

  const FeedbackState({
    this.feedbackSubmitted = false,
    this.feedbackType,
    this.selectedTag,
    this.inaccuracyDescription,
    this.correctedInput,
  });

  FeedbackState copyWith({
    bool? feedbackSubmitted,
    String? feedbackType,
    String? selectedTag,
    String? inaccuracyDescription,
    String? correctedInput,
  }) {
    return FeedbackState(
      feedbackSubmitted: feedbackSubmitted ?? this.feedbackSubmitted,
      feedbackType: feedbackType ?? this.feedbackType,
      selectedTag: selectedTag ?? this.selectedTag,
      inaccuracyDescription: inaccuracyDescription ?? this.inaccuracyDescription,
      correctedInput: correctedInput ?? this.correctedInput,
    );
  }
}

/// Prominent feedback actions widget with thumbs up/down - HIGHLY VISIBLE
class ClinicianFeedbackActions extends StatelessWidget {
  final FeedbackState feedbackState;
  final VoidCallback onAccurate;
  final VoidCallback onNeedsCorrection;

  const ClinicianFeedbackActions({
    super.key,
    required this.feedbackState,
    required this.onAccurate,
    required this.onNeedsCorrection,
  });

  @override
  Widget build(BuildContext context) {
    // If feedback already submitted, show nothing (badge is shown separately)
    if (feedbackState.feedbackSubmitted) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignTokens.medicalBlue.withOpacity(0.08),
            DesignTokens.clinicalTeal.withOpacity(0.08),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DesignTokens.clinicalTeal.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header text
          Row(
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 16,
                color: DesignTokens.clinicalTeal,
              ),
              const SizedBox(width: 8),
              Text(
                'Was this response helpful?',
                style: DesignTokens.labelMedium.copyWith(
                  color: DesignTokens.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Buttons row
          Row(
            children: [
              Expanded(
                child: _FeedbackButton(
                  icon: Icons.thumb_up_rounded,
                  label: 'Accurate',
                  color: DesignTokens.success,
                  onTap: onAccurate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FeedbackButton(
                  icon: Icons.thumb_down_rounded,
                  label: 'Needs Correction',
                  color: DesignTokens.warning,
                  onTap: onNeedsCorrection,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FeedbackButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: DesignTokens.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clinician-reviewed badge shown after feedback submission - PROMINENT
class ClinicianReviewedBadge extends StatelessWidget {
  const ClinicianReviewedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignTokens.clinicalTeal.withOpacity(0.2),
            DesignTokens.medicalBlue.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: DesignTokens.clinicalTeal.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.clinicalTeal.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: DesignTokens.clinicalTeal.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_rounded,
              size: 14,
              color: DesignTokens.clinicalTeal,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Clinician-reviewed',
            style: DesignTokens.labelMedium.copyWith(
              color: DesignTokens.clinicalTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Feedback confirmation message shown after submission - PROMINENT
class FeedbackConfirmation extends StatelessWidget {
  const FeedbackConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignTokens.success.withOpacity(0.15),
            DesignTokens.success.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: DesignTokens.radiusMd,
        border: Border.all(
          color: DesignTokens.success.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.success.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: DesignTokens.success.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: DesignTokens.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Feedback recorded successfully!',
                  style: DesignTokens.labelLarge.copyWith(
                    color: DesignTokens.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(
              'This will improve future AI responses. Used for system learning after clinical validation.',
              style: DesignTokens.bodySmall.copyWith(
                color: DesignTokens.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal for "Needs correction" feedback
class FeedbackCorrectionModal extends StatefulWidget {
  final Function(String? inaccuracy, String? correction, String? tag) onSubmit;

  const FeedbackCorrectionModal({
    super.key,
    required this.onSubmit,
  });

  @override
  State<FeedbackCorrectionModal> createState() => _FeedbackCorrectionModalState();
}

class _FeedbackCorrectionModalState extends State<FeedbackCorrectionModal> {
  final _inaccuracyController = TextEditingController();
  final _correctionController = TextEditingController();
  String? _selectedTag;

  final List<String> _tags = [
    'Wrong diagnosis',
    'Missing symptom',
    'Incorrect reasoning',
    'Unknown disease',
  ];

  @override
  void dispose() {
    _inaccuracyController.dispose();
    _correctionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    widget.onSubmit(
      _inaccuracyController.text.isEmpty ? null : _inaccuracyController.text,
      _correctionController.text.isEmpty ? null : _correctionController.text,
      _selectedTag,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: DesignTokens.cardBlack,
          borderRadius: DesignTokens.radiusLg,
          border: Border.all(
            color: DesignTokens.borderGray,
            width: 1,
          ),
          boxShadow: DesignTokens.depth3,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DesignTokens.warning.withOpacity(0.15),
                    borderRadius: DesignTokens.radiusSm,
                  ),
                  child: Icon(
                    Icons.edit_note,
                    size: 20,
                    color: DesignTokens.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Provide Correction',
                    style: DesignTokens.headingSmall,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: DesignTokens.textTertiary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // What was inaccurate
            Text(
              'What was inaccurate?',
              style: DesignTokens.labelMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _inaccuracyController,
              style: DesignTokens.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Brief description...',
                hintStyle: DesignTokens.bodyMedium.copyWith(
                  color: DesignTokens.textTertiary,
                ),
                filled: true,
                fillColor: DesignTokens.surfaceBlack,
                border: OutlineInputBorder(
                  borderRadius: DesignTokens.radiusSm,
                  borderSide: BorderSide(
                    color: DesignTokens.borderGray,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: DesignTokens.radiusSm,
                  borderSide: BorderSide(
                    color: DesignTokens.borderGray,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: DesignTokens.radiusSm,
                  borderSide: BorderSide(
                    color: DesignTokens.clinicalTeal.withOpacity(0.5),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Doctor's corrected input
            Text(
              "Doctor's corrected input",
              style: DesignTokens.labelMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _correctionController,
              style: DesignTokens.bodyMedium,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter your correction...',
                hintStyle: DesignTokens.bodyMedium.copyWith(
                  color: DesignTokens.textTertiary,
                ),
                filled: true,
                fillColor: DesignTokens.surfaceBlack,
                border: OutlineInputBorder(
                  borderRadius: DesignTokens.radiusSm,
                  borderSide: BorderSide(
                    color: DesignTokens.borderGray,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: DesignTokens.radiusSm,
                  borderSide: BorderSide(
                    color: DesignTokens.borderGray,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: DesignTokens.radiusSm,
                  borderSide: BorderSide(
                    color: DesignTokens.clinicalTeal.withOpacity(0.5),
                  ),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),

            const SizedBox(height: 20),

            // Optional tags
            Text(
              'Category (optional)',
              style: DesignTokens.labelMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) {
                final isSelected = _selectedTag == tag;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTag = isSelected ? null : tag;
                    });
                  },
                  child: AnimatedContainer(
                    duration: DesignTokens.quick,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DesignTokens.clinicalTeal.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? DesignTokens.clinicalTeal.withOpacity(0.5)
                            : DesignTokens.textTertiary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: DesignTokens.labelSmall.copyWith(
                        color: isSelected
                            ? DesignTokens.clinicalTeal
                            : DesignTokens.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // Submit button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: DesignTokens.bodyMedium.copyWith(
                      color: DesignTokens.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.clinicalTeal,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: DesignTokens.radiusSm,
                    ),
                  ),
                  child: Text(
                    'Submit Feedback',
                    style: DesignTokens.bodyMedium.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to show the feedback correction modal
void showFeedbackCorrectionModal(
  BuildContext context, {
  required Function(String? inaccuracy, String? correction, String? tag) onSubmit,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (context) => FeedbackCorrectionModal(onSubmit: onSubmit),
  );
}
