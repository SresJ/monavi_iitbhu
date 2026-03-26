import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/design_tokens.dart';
import '../../models/analysis.dart';
import '../indicators/confidence_ring.dart';
import '../feedback/clinician_feedback.dart';

class DiagnosisCard extends StatefulWidget {
  final Diagnosis diagnosis;
  final int rank; // 1, 2, 3, etc.
  final bool initiallyExpanded;
  /// Tighter header layout for narrow widths (Phase 6 — shared density).
  final bool compact;

  const DiagnosisCard({
    Key? key,
    required this.diagnosis,
    required this.rank,
    this.initiallyExpanded = false,
    this.compact = false,
  }) : super(key: key);

  @override
  State<DiagnosisCard> createState() => _DiagnosisCardState();
}

class _DiagnosisCardState extends State<DiagnosisCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _rotationController;

  // Feedback state for this diagnosis card
  FeedbackState _feedbackState = const FeedbackState();

  void _handleAccurate() {
    setState(() {
      _feedbackState = const FeedbackState(
        feedbackSubmitted: true,
        feedbackType: 'accurate',
      );
    });
  }

  void _handleNeedsCorrection() {
    showFeedbackCorrectionModal(
      context,
      onSubmit: (inaccuracy, correction, tag) {
        setState(() {
          _feedbackState = FeedbackState(
            feedbackSubmitted: true,
            feedbackType: 'needs_correction',
            inaccuracyDescription: inaccuracy,
            correctedInput: correction,
            selectedTag: tag,
          );
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _rotationController = AnimationController(
      duration: DesignTokens.standard,
      vsync: this,
    );

    if (_isExpanded) {
      _rotationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _rotationController.forward();
      } else {
        _rotationController.reverse();
      }
    });
  }

  Color _getRankColor() {
    switch (widget.rank) {
      case 1:
        return DesignTokens.confidenceHigh;
      case 2:
        return DesignTokens.confidenceMed;
      case 3:
        return DesignTokens.confidenceLow;
      default:
        return DesignTokens.textSecondary;
    }
  }

  // Filter out non-symptom items from triggeringSymptoms
  List<String> _getFilteredSymptoms() {
    final excludePatterns = [
      'patient information',
      'mrn',
      'demographics',
      'clinical notes',
      'clinical note',
      'redacted',
      '[redacted]',
      'patient id',
      'patient name',
      'date of birth',
      'dob',
      'address',
      'phone',
      'email',
      'insurance',
      'encounter',
      'visit',
      'admission',
    ];

    return widget.diagnosis.triggeringSymptoms.where((symptom) {
      final lower = symptom.toLowerCase().trim();
      // Exclude if empty, too short, or matches exclude patterns
      if (lower.isEmpty || lower.length < 3) return false;
      for (final pattern in excludePatterns) {
        if (lower.contains(pattern)) return false;
      }
      // Exclude if it looks like metadata (all caps or contains special formatting)
      if (symptom == symptom.toUpperCase() && symptom.length > 3) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor();
    final confidenceColor = DesignTokens.getConfidenceColor(
      widget.diagnosis.confidenceLevel,
    );

    return AnimatedContainer(
      duration: DesignTokens.standard,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.cardBlack.withOpacity(_isExpanded ? 0.85 : 0.7),
            DesignTokens.cardBlack.withOpacity(_isExpanded ? 0.6 : 0.4),
          ],
        ),
        borderRadius: DesignTokens.radiusMd,
        border: Border.all(
          // Use teal accent for selected state instead of confidence color
          color: _isExpanded
              ? DesignTokens.selectedAccent.withOpacity(0.6)
              : DesignTokens.borderGray.withOpacity(0.3),
          width: _isExpanded ? 1.5 : 1,
        ),
        boxShadow: _isExpanded
            ? DesignTokens
                  .glowSelected // Use teal glow instead of confidence-based
            : DesignTokens.depth1,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleExpanded,
          borderRadius: DesignTokens.radiusMd,
          child: Padding(
            padding: EdgeInsets.all(
              widget.compact ? DesignTokens.spaceMd : DesignTokens.spaceLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(rankColor, confidenceColor),
                if (_isExpanded) ...[
                  const SizedBox(height: DesignTokens.spaceLg),
                  _buildExpandedContent(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color rankColor, Color confidenceColor) {
    final ringSize = widget.compact ? 48.0 : 56.0;
    final badge = Container(
      width: widget.compact ? 32 : 36,
      height: widget.compact ? 32 : 36,
      decoration: BoxDecoration(
        color: rankColor.withOpacity(0.15),
        border: Border.all(color: rankColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '${widget.rank}',
          style: DesignTokens.labelLarge.copyWith(
            color: rankColor,
            fontWeight: FontWeight.w700,
            fontSize: widget.compact ? 13 : null,
          ),
        ),
      ),
    );

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.diagnosis.diagnosisName,
          style: DesignTokens.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: widget.compact ? 15 : null,
          ),
          maxLines: widget.compact ? 3 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: confidenceColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.diagnosis.confidenceLevelDisplay,
                  style: DesignTokens.labelSmall.copyWith(
                    color: confidenceColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSm),
            Text(
              '${(widget.diagnosis.confidence * 100).round()}%',
              style: DesignTokens.labelLarge.copyWith(
                color: confidenceColor,
                fontWeight: FontWeight.w700,
                fontSize: widget.compact ? 14 : null,
              ),
            ),
          ],
        ),
      ],
    );

    final chevron = RotationTransition(
      turns: Tween(begin: 0.0, end: 0.5).animate(_rotationController),
      child: Icon(
        Icons.keyboard_arrow_down,
        color: confidenceColor,
        size: widget.compact ? 22 : 24,
      ),
    );

    final ring = ConfidenceRing(
      confidence: widget.diagnosis.confidence,
      confidenceLevel: widget.diagnosis.confidenceLevel,
      size: ringSize,
      animate: true,
    );

    if (widget.compact) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          badge,
          const SizedBox(width: DesignTokens.spaceSm),
          Expanded(child: titleBlock),
          const SizedBox(width: 4),
          ring,
          const SizedBox(width: 2),
          chevron,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        badge,
        const SizedBox(width: DesignTokens.spaceMd),
        Expanded(child: titleBlock),
        ring,
        const SizedBox(width: DesignTokens.spaceSm),
        chevron,
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: DesignTokens.borderGray, height: 24),

        // Triggering symptoms - compact (filtered to show only actual symptoms)
        if (_getFilteredSymptoms().isNotEmpty) ...[
          Text(
            'Key Symptoms',
            style: DesignTokens.labelMedium.copyWith(
              color: DesignTokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _getFilteredSymptoms().map((symptom) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignTokens.clinicalTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: DesignTokens.clinicalTeal.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  symptom,
                  style: DesignTokens.labelSmall.copyWith(
                    color: DesignTokens.clinicalTeal,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
        ],
        // Evidence - compact
        if (widget.diagnosis.evidence.isNotEmpty) ...[
          Text(
            'Evidence (${widget.diagnosis.evidence.length})',
            style: DesignTokens.labelMedium.copyWith(
              color: DesignTokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          ...widget.diagnosis.evidence
              .take(2)
              .map((evidence) => _buildCompactEvidenceCard(evidence)),
        ],
        // Confidence rationale - more compact
        if (widget.diagnosis.confidenceRationale.isNotEmpty) ...[
          Text(
            'Rationale',
            style: DesignTokens.labelMedium.copyWith(
              color: DesignTokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          ...widget.diagnosis.confidenceRationale
              .take(3)
              .map(
                (rationale) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: DesignTokens.getConfidenceColor(
                            widget.diagnosis.confidenceLevel,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spaceSm),
                      Expanded(
                        child: Text(
                          rationale,
                          style: DesignTokens.bodySmall.copyWith(
                            color: DesignTokens.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (widget.diagnosis.confidenceRationale.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+${widget.diagnosis.confidenceRationale.length - 3} more',
                style: DesignTokens.labelSmall.copyWith(
                  color: DesignTokens.textTertiary,
                ),
              ),
            ),
          const SizedBox(height: DesignTokens.spaceMd),
        ],

        // Clinician Feedback Section
        _buildFeedbackSection(),
      ],
    );
  }

  /// Builds the clinician feedback section
  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(color: DesignTokens.borderGray, height: 24),

        // Show badge if feedback submitted
        if (_feedbackState.feedbackSubmitted) ...[
          const ClinicianReviewedBadge(),
          const FeedbackConfirmation(),
        ] else
          // Show feedback actions
          ClinicianFeedbackActions(
            feedbackState: _feedbackState,
            onAccurate: _handleAccurate,
            onNeedsCorrection: _handleNeedsCorrection,
          ),
      ],
    );
  }

  Widget _buildCompactEvidenceCard(Evidence evidence) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(DesignTokens.spaceSm),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceBlack.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: DesignTokens.borderGray.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            evidence.evidenceText.length > 120
                ? '${evidence.evidenceText.substring(0, 120)}...'
                : evidence.evidenceText,
            style: DesignTokens.bodySmall.copyWith(
              color: DesignTokens.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _launchUrl(evidence.sourceUrl),
            child: Row(
              children: [
                Icon(Icons.launch, size: 12, color: DesignTokens.clinicalTeal),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    evidence.sourceName,
                    style: DesignTokens.labelSmall.copyWith(
                      color: DesignTokens.clinicalTeal,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
