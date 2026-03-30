import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../config/breakpoints.dart';
import '../../config/design_tokens.dart';
import '../../widgets/buttons/clinical_button.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.voidBlack,
      body: Stack(
        children: [
          // Animated background orbs
          _buildAnimatedBackground(),

          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop =
                    Breakpoints.isLandingDesktopWidth(constraints.maxWidth);
                final shortViewport = Breakpoints.isShortViewportHeight(
                  constraints.maxHeight,
                );
                final narrow = Breakpoints.isCompactWidth(constraints.maxWidth);

                return SingleChildScrollView(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    padding: EdgeInsets.all(
                      isDesktop ? DesignTokens.spaceXxxl : DesignTokens.spaceLg,
                    ),
                    child: isDesktop
                        ? _buildDesktopLayout(context)
                        : _buildMobileLayout(
                            context,
                            shortViewport: shortViewport,
                            narrowWidth: narrow,
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _orbitController,
      builder: (context, child) {
        return Stack(
          children: [
            // Large blue orb
            Positioned(
              left: -100 + math.sin(_orbitController.value * 2 * math.pi) * 50,
              top: 100 + math.cos(_orbitController.value * 2 * math.pi) * 50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      DesignTokens.medicalBlue.withOpacity(0.3),
                      DesignTokens.medicalBlue.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Teal orb
            Positioned(
              right:
                  -150 +
                  math.cos(_orbitController.value * 2 * math.pi + 1) * 70,
              top:
                  200 + math.sin(_orbitController.value * 2 * math.pi + 1) * 70,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      DesignTokens.clinicalTeal.withOpacity(0.25),
                      DesignTokens.clinicalTeal.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Small accent orb
            Positioned(
              left:
                  MediaQuery.of(context).size.width / 2 +
                  math.sin(_orbitController.value * 2 * math.pi + 2) * 100,
              bottom:
                  100 +
                  math.cos(_orbitController.value * 2 * math.pi + 2) * 100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      DesignTokens.confidenceHigh.withOpacity(0.2),
                      DesignTokens.confidenceHigh.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left side - Text content
        Expanded(flex: 4, child: _buildTextContent(context)),
        const SizedBox(width: DesignTokens.spaceXxxl),
        // Right side - Feature cards
        Expanded(flex: 6, child: _buildFeatureCards(context)),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context, {
    required bool shortViewport,
    required bool narrowWidth,
  }) {
    final heroGap = shortViewport
        ? DesignTokens.spaceLg
        : DesignTokens.spaceXxl;
    return Column(
      mainAxisAlignment: shortViewport
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      children: [
        _buildTextContent(
          context,
          shortViewport: shortViewport,
          narrowWidth: narrowWidth,
        ),
        SizedBox(height: heroGap),
        _buildFeatureCards(
          context,
          shortViewport: shortViewport,
        ),
      ],
    );
  }

  Widget _buildTextContent(
    BuildContext context, {
    bool shortViewport = false,
    bool narrowWidth = false,
  }) {
    final titleStyle = shortViewport
        ? DesignTokens.displayMedium
        : DesignTokens.displayLarge;

    final afterTitleGap =
        shortViewport ? DesignTokens.spaceSm : DesignTokens.spaceMd;
    final beforeCtaGap =
        shortViewport ? DesignTokens.spaceLg : DesignTokens.spaceXxl;
    final afterCtaGap =
        shortViewport ? DesignTokens.spaceMd : DesignTokens.spaceXl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceMd,
            vertical: DesignTokens.spaceXs,
          ),
          decoration: BoxDecoration(
            gradient: DesignTokens.medicalGradient,
            borderRadius: DesignTokens.radiusLg,
            boxShadow: DesignTokens.glowBlue,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              const SizedBox(width: DesignTokens.spaceXs),
              Text(
                'AI-Powered Clinical Intelligence',
                style: DesignTokens.labelSmall.copyWith(color: Colors.white),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),

        const SizedBox(height: DesignTokens.spaceLg),

        // Main title with gradient
        ShaderMask(
              shaderCallback: (bounds) =>
                  DesignTokens.medicalGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
              child: Text(
                'CLINICAL AI',
                style: titleStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: narrowWidth ? -1.2 : -2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
            .animate()
            .fadeIn(duration: 800.ms, delay: 200.ms)
            .slideX(begin: -0.1, end: 0),

        SizedBox(height: afterTitleGap),

        Text(
              'Enterprise-Grade Healthcare Intelligence',
              style: (shortViewport
                      ? DesignTokens.headingMedium
                      : DesignTokens.headingLarge)
                  .copyWith(
                color: DesignTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            )
            .animate()
            .fadeIn(duration: 800.ms, delay: 400.ms)
            .slideX(begin: -0.1, end: 0),

        const SizedBox(height: DesignTokens.spaceLg),

        Text(
          'Advanced clinical reasoning powered by AI. Generate differential diagnoses with confidence scores, evidence-based recommendations, and intelligent follow-up Q&A.',
          style: (shortViewport
                  ? DesignTokens.bodyMedium
                  : DesignTokens.bodyLarge)
              .copyWith(
            color: DesignTokens.textSecondary,
            height: shortViewport ? 1.5 : 1.8,
          ),
        ).animate().fadeIn(duration: 800.ms, delay: 600.ms),

        SizedBox(height: beforeCtaGap),

        // CTA Buttons
        Wrap(
          spacing: DesignTokens.spaceMd,
          runSpacing: DesignTokens.spaceMd,
          children: [
            MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ClinicalButton.primary(
                    label: 'Get Started',
                    icon: Icons.rocket_launch,
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms, delay: 800.ms)
                .scale(begin: const Offset(0.8, 0.8)),

            MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ClinicalButton.secondary(
                    label: 'Live Demo',
                    icon: Icons.play_circle_outline,
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms, delay: 900.ms)
                .scale(begin: const Offset(0.8, 0.8)),
          ],
        ),

        SizedBox(height: afterCtaGap),

        // Stats
        _buildStats(narrowWidth: narrowWidth)
            .animate()
            .fadeIn(duration: 800.ms, delay: 1000.ms),
      ],
    );
  }

  Widget _buildStats({required bool narrowWidth}) {
    final items = [
      _buildStatItem('88%', 'Accuracy'),
      _buildStatItem('200+', 'Diagnoses'),
      _buildStatItem('<3s', 'Response'),
    ];
    if (narrowWidth) {
      return Wrap(
        spacing: DesignTokens.spaceLg,
        runSpacing: DesignTokens.spaceMd,
        alignment: WrapAlignment.start,
        children: items,
      );
    }
    return Row(
      children: [
        items[0],
        const SizedBox(width: DesignTokens.spaceXl),
        items[1],
        const SizedBox(width: DesignTokens.spaceXl),
        items[2],
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              DesignTokens.medicalGradient.createShader(bounds),
          child: Text(
            value,
            style: DesignTokens.headingMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          label,
          style: DesignTokens.labelMedium.copyWith(
            color: DesignTokens.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCards(
    BuildContext context, {
    bool shortViewport = false,
  }) {
    final betweenCards =
        shortViewport ? DesignTokens.spaceMd : DesignTokens.spaceLg;
    return Column(
      children: [
        _buildGlassCard(
          icon: Icons.library_books_outlined,
          title: 'Explainable & Evidence-Backed AI',
          description:
              'Every diagnosis is supported with clinical evidence and clear reasoning, not black-box outputs.',
          color: DesignTokens.medicalBlue,
          delay: 200,
        ),

        SizedBox(height: betweenCards),

        _buildGlassCard(
          icon: Icons.compare_arrows_outlined,
          title: 'What Changed Since Last Visit',
          description:
              'Highlights only meaningful clinical changes across visits, eliminating redundant review.',
          color: DesignTokens.clinicalTeal,
          delay: 350,
        ),

        SizedBox(height: betweenCards),

        _buildGlassCard(
          icon: Icons.stacked_line_chart_outlined,
          title: 'Differential Diagnosis with Confidence',
          description:
              'Ranked differential diagnoses with confidence levels and symptom-based justification.',
          color: DesignTokens.confidenceHigh,
          delay: 500,
        ),

        SizedBox(height: betweenCards),

        _buildGlassCard(
          icon: Icons.shield_outlined,
          title: 'Doctor Productivity & AI Safety',
          description:
              'Designed to save time while clearly signaling uncertainty, missing data, and AI confidence.',
          color: DesignTokens.confidenceMed,
          delay: 650,
        ),

        SizedBox(height: betweenCards),

        _buildGlassCard(
          icon: Icons.forum_outlined,
          title: 'Context-Aware Clinical Follow-Up (Q&A)',
          description:
              'Ask follow-up questions with answers strictly grounded in patient context and evidence.',
          color: DesignTokens.selectedAccent,
          delay: 800,
        ),
      ],
    );
  }

  Widget _buildGlassCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required int delay,
  }) {
    return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceMd,
              vertical: DesignTokens.spaceSm, // ⬅ reduced
            ),
            decoration: BoxDecoration(
              color: DesignTokens.cardBlack.withOpacity(0.5),
              borderRadius: DesignTokens.radiusMd, // ⬅ smaller radius
              border: Border.all(color: color.withOpacity(0.18), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ICON (smaller & flatter)
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceSm),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: DesignTokens.radiusSm,
                  ),
                  child: Icon(icon, color: color, size: 22), // ⬅ smaller
                ),

                const SizedBox(width: DesignTokens.spaceSm),

                // TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // ⬅ key
                    children: [
                      Text(
                        title,
                        style: DesignTokens.labelLarge.copyWith(
                          color: DesignTokens.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4), // ⬅ tighter
                      Text(
                        description,
                        maxLines: 2, // ⬅ critical
                        overflow: TextOverflow.ellipsis,
                        style: DesignTokens.labelSmall.copyWith(
                          color: DesignTokens.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: delay.ms)
        .slideY(begin: 0.15, end: 0);
  }
}
