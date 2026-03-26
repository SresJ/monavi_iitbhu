import 'package:flutter/material.dart';
import '../../config/design_tokens.dart';
import '../../models/patient.dart';

/// PATIENT CARD - LANDING PAGE STYLE
///
/// NOT a database row. A person preview.
/// Feels like: "A glass card from the landing page"
///
/// Rules:
/// - Glass-like gradient background
/// - Subtle glow effects on hover
/// - Large avatar with gradient
/// - Focus on identity, not metadata
class PatientCard extends StatefulWidget {
  final Patient patient;
  final VoidCallback? onTap;

  const PatientCard({
    Key? key,
    required this.patient,
    this.onTap,
  }) : super(key: key);

  @override
  State<PatientCard> createState() => _PatientCardState();
}

class _PatientCardState extends State<PatientCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _onHoverStart() {
    setState(() => _isHovered = true);
    _glowController.forward();
  }

  void _onHoverEnd() {
    setState(() => _isHovered = false);
    _glowController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverStart(),
      onExit: (_) => _onHoverEnd(),
      cursor:
          widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: DesignTokens.quick,
            decoration: BoxDecoration(
              // Glass-like gradient background
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DesignTokens.cardBlack.withOpacity(_isHovered ? 0.7 : 0.5),
                  DesignTokens.cardBlack.withOpacity(_isHovered ? 0.4 : 0.25),
                ],
              ),
              borderRadius: DesignTokens.radiusLg,
              border: Border.all(
                color: _isHovered
                    ? DesignTokens.medicalBlue.withOpacity(0.4)
                    : DesignTokens.borderGray.withOpacity(0.25),
                width: 1,
              ),
              // Glow effect on hover
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: DesignTokens.medicalBlue
                            .withOpacity(0.15 + _glowController.value * 0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: DesignTokens.radiusLg,
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spaceLg),
                  child: Row(
                    children: [
                      // Avatar with profile image
                      AnimatedContainer(
                        duration: DesignTokens.quick,
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isHovered
                                ? DesignTokens.clinicalTeal.withOpacity(0.6)
                                : DesignTokens.borderGray.withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: DesignTokens.medicalBlue.withOpacity(
                                  _isHovered
                                      ? 0.25 + _glowController.value * 0.1
                                      : 0.1),
                              blurRadius: _isHovered ? 20 : 12,
                              spreadRadius: _isHovered ? 2 : 1,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            widget.patient.avatarPath,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to initials if image fails
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: DesignTokens.medicalGradient,
                                ),
                                child: Center(
                                  child: Text(
                                    widget.patient.initials,
                                    style: DesignTokens.headingSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spaceMd),

                      // Patient info - identity focused
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Name - PRIMARY (capitalized)
                            Text(
                              widget.patient.displayName,
                              style: DesignTokens.headingSmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _isHovered
                                    ? DesignTokens.textPrimary
                                    : DesignTokens.textPrimary.withOpacity(0.95),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            // Age/Sex - secondary (capitalized)
                            if (widget.patient.ageSexDisplay.isNotEmpty)
                              Text(
                                widget.patient.ageSexDisplay,
                                style: DesignTokens.bodyMedium.copyWith(
                                  color: DesignTokens.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spaceMd),

                      // Subtle arrow indicator
                      AnimatedContainer(
                        duration: DesignTokens.quick,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isHovered
                              ? DesignTokens.medicalBlue.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: DesignTokens.radiusSm,
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: _isHovered
                              ? DesignTokens.clinicalTeal
                              : DesignTokens.textTertiary.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
