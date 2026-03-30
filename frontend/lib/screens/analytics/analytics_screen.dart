import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../config/breakpoints.dart';
import '../../config/design_tokens.dart';
import '../../shell/main_shell.dart';

/// ANALYTICS SCREEN - PREMIUM INSIGHTS VIEW
///
/// Features:
/// - Fake static data (no API needed)
/// - Interactive animated background
/// - Fancy Iconsax icons
/// - Capitalized text
/// - Pulsing animations
/// - Beautiful charts
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _floatController;

  // Fake static data
  final int _totalAnalyses = 1892;
  final int _highConfidence = 1456;
  final int _lowConfidence = 124;
  final double _avgConfidence = 0.88;
  final int _weeklyGrowth = 12;

  // Hardcoded data for Diagnosis Distribution (Donut)
  final List<_DiagnosisData> _diagnosisData = [
    _DiagnosisData('Gastrointestinal', 35, const Color(0xFF4FC3F7)),
    _DiagnosisData('Musculoskeletal', 25, const Color(0xFF81C784)),
    _DiagnosisData('Infectious', 20, const Color(0xFFFFB74D)),
    _DiagnosisData('Other', 20, const Color(0xFFBA68C8)),
  ];

  // Case Distribution
  final double _clearCases = 60;
  final double _reviewNeeded = 25;
  final double _complexCases = 15;

  // AI Confidence for gauge
  final double _aiConfidence = 0.88;

  // Patient count last 14 days
  final List<int> _patientCounts = [3, 4, 5, 6, 4, 7, 8, 6, 5, 7, 9, 8, 6, 7];

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.voidBlack,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildFloatingParticles(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceLg,
                  vertical: DesignTokens.spaceMd,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final sectionW = constraints.maxWidth;
                    final compact = Breakpoints.isCompactWidth(sectionW);
                    final twoColCharts =
                        Breakpoints.isTwoColumnChartsWidth(sectionW);
                    final bottomPad =
                        72.0 + MediaQuery.paddingOf(context).bottom;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(compact: compact)
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: -0.1, end: 0),

                        SizedBox(
                          height: compact
                              ? DesignTokens.spaceLg
                              : DesignTokens.spaceXl,
                        ),

                        _buildSystemStatus(compact: compact)
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 100.ms)
                            .slideY(begin: 0.05, end: 0),

                        SizedBox(
                          height: compact
                              ? DesignTokens.spaceLg
                              : DesignTokens.spaceXl,
                        ),

                        (twoColCharts
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildDiagnosisDonut(
                                          compact: compact,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: DesignTokens.spaceMd,
                                      ),
                                      Expanded(
                                        child: _buildAIConfidenceGauge(
                                          compact: compact,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildDiagnosisDonut(compact: compact),
                                      const SizedBox(
                                        height: DesignTokens.spaceMd,
                                      ),
                                      _buildAIConfidenceGauge(
                                        compact: compact,
                                      ),
                                    ],
                                  ))
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 200.ms),

                        const SizedBox(height: DesignTokens.spaceLg),

                        _buildCaseDistributionBar(
                          compact: compact,
                          sectionWidth: sectionW,
                        ).animate().fadeIn(
                              duration: 600.ms,
                              delay: 300.ms,
                            ),

                        const SizedBox(height: DesignTokens.spaceLg),

                        _buildPatientCountChart(
                          compact: compact,
                          sectionWidth: sectionW,
                        ).animate().fadeIn(
                              duration: 600.ms,
                              delay: 400.ms,
                            ),

                        SizedBox(
                          height: compact
                              ? DesignTokens.spaceLg
                              : DesignTokens.spaceXl,
                        ),

                        _buildQuickStats(compact: compact).animate().fadeIn(
                              duration: 600.ms,
                              delay: 500.ms,
                            ),

                        SizedBox(height: bottomPad),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_orbitController, _waveController]),
      builder: (context, child) {
        return Stack(
          children: [
            // Teal orb - top right
            Positioned(
              right: -100 + math.sin(_orbitController.value * 2 * math.pi) * 50,
              top: 40 + math.cos(_orbitController.value * 2 * math.pi) * 50,
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      DesignTokens.clinicalTeal.withOpacity(0.2),
                      DesignTokens.clinicalTeal.withOpacity(0.08),
                      DesignTokens.clinicalTeal.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Blue orb - left bottom
            Positioned(
              left:
                  -130 +
                  math.cos(_orbitController.value * 2 * math.pi + 1.5) * 60,
              bottom:
                  180 +
                  math.sin(_orbitController.value * 2 * math.pi + 1.5) * 60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      DesignTokens.medicalBlue.withOpacity(0.18),
                      DesignTokens.medicalBlue.withOpacity(0.06),
                      DesignTokens.medicalBlue.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Green orb - center
            Positioned(
              left:
                  MediaQuery.of(context).size.width / 2 -
                  100 +
                  math.sin(_orbitController.value * 2 * math.pi + 2.5) * 40,
              top:
                  350 +
                  math.cos(_orbitController.value * 2 * math.pi + 2.5) * 40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      DesignTokens.confidenceHigh.withOpacity(0.12),
                      DesignTokens.confidenceHigh.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Purple orb - bottom right
            Positioned(
              right:
                  30 +
                  math.sin(_orbitController.value * 2 * math.pi + 3.5) * 30,
              bottom:
                  50 +
                  math.cos(_orbitController.value * 2 * math.pi + 3.5) * 30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withOpacity(0.15),
                      const Color(0xFF8B5CF6).withOpacity(0.0),
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

  Widget _buildFloatingParticles() {
    final compact = Breakpoints.isCompactWidth(
      MediaQuery.sizeOf(context).width,
    );
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Stack(
          children: List.generate(compact ? 5 : 10, (index) {
            final offset = index * 0.1;
            final x = (index % 5) * 80.0 + 30;
            final y =
                (index ~/ 5) * 400.0 +
                150 +
                math.sin((_floatController.value + offset) * 2 * math.pi) * 18;

            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignTokens.clinicalTeal.withOpacity(0.28),
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.clinicalTeal.withOpacity(0.18),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildHeader({required bool compact}) {
    final titleStyle = (compact
            ? DesignTokens.headingLarge
            : DesignTokens.displaySmall)
        .copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  MainShellScope.goToTab(context, 0);
                }
              },
              style: IconButton.styleFrom(
                backgroundColor: DesignTokens.cardBlack.withOpacity(0.6),
                side: BorderSide(color: DesignTokens.borderGray.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                minimumSize: const Size(
                  Breakpoints.minTouchTarget,
                  Breakpoints.minTouchTarget,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(
                Iconsax.arrow_left,
                color: DesignTokens.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSm),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: DesignTokens.confidenceHigh.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: DesignTokens.confidenceHigh.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.chart_success,
                          color: DesignTokens.confidenceHigh,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '+$_weeklyGrowth% This Week',
                          style: DesignTokens.labelMedium.copyWith(
                            color: DesignTokens.confidenceHigh,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: compact ? DesignTokens.spaceMd : DesignTokens.spaceLg,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(compact ? 10 : 12),
              decoration: BoxDecoration(
                gradient: DesignTokens.medicalGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.medicalBlue.withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Iconsax.chart,
                color: Colors.white,
                size: compact ? 22 : 26,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceMd),
            Expanded(
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    DesignTokens.medicalGradient.createShader(bounds),
                child: Text(
                  'Analytics',
                  style: titleStyle.copyWith(color: Colors.white),
                  maxLines: compact ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceSm),
        Text(
          'AI Performance & Insights',
          style: (compact
                  ? DesignTokens.bodyMedium
                  : DesignTokens.bodyLarge)
              .copyWith(
            color: DesignTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSystemStatus({required bool compact}) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final iconBox = Container(
          width: compact ? 64 : 80,
          height: compact ? 64 : 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DesignTokens.confidenceHigh.withOpacity(0.15),
            border: Border.all(
              color: DesignTokens.confidenceHigh.withOpacity(0.4),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.confidenceHigh.withOpacity(
                  0.2 + _pulseController.value * 0.1,
                ),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(
            Iconsax.verify,
            color: DesignTokens.confidenceHigh,
            size: compact ? 28 : 36,
          ),
        );

        final textBlock = Column(
          crossAxisAlignment:
              compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(
              'System Healthy',
              textAlign: compact ? TextAlign.center : TextAlign.start,
              style: DesignTokens.headingMedium.copyWith(
                color: DesignTokens.confidenceHigh,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'AI Is Operating With High Confidence',
              textAlign: compact ? TextAlign.center : TextAlign.start,
              style: DesignTokens.bodyMedium.copyWith(
                color: DesignTokens.textSecondary,
              ),
            ),
          ],
        );

        return Container(
          padding: EdgeInsets.all(
            compact ? DesignTokens.spaceMd : DesignTokens.spaceLg,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DesignTokens.confidenceHigh.withOpacity(0.15),
                DesignTokens.confidenceHigh.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: DesignTokens.confidenceHigh.withOpacity(
                0.3 + _pulseController.value * 0.15,
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: DesignTokens.confidenceHigh.withOpacity(
                  0.15 + _pulseController.value * 0.08,
                ),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: compact
              ? Column(
                  children: [
                    iconBox,
                    const SizedBox(height: DesignTokens.spaceMd),
                    textBlock,
                  ],
                )
              : Row(
                  children: [
                    iconBox,
                    const SizedBox(width: DesignTokens.spaceLg),
                    Expanded(child: textBlock),
                  ],
                ),
        );
      },
    );
  }

  // ===================== CHART 1: DIAGNOSIS DISTRIBUTION (DONUT) =====================
  Widget _buildDiagnosisDonut({required bool compact}) {
    return Container(
      padding: EdgeInsets.all(compact ? DesignTokens.spaceMd : DesignTokens.spaceLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.cardBlack.withOpacity(0.8),
            DesignTokens.cardBlack.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DesignTokens.borderGray.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Iconsax.health, color: DesignTokens.textSecondary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Diagnosis Distribution',
                  style: DesignTokens.headingSmall.copyWith(
                    color: DesignTokens.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          SizedBox(
            height: compact ? 168 : 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: compact ? 42 : 50,
                    sections: _diagnosisData.map((d) {
                      return PieChartSectionData(
                        value: d.percentage.toDouble(),
                        color: d.color,
                        radius: compact ? 28 : 32,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.diagram,
                      color: DesignTokens.textTertiary,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Diagnoses',
                      style: DesignTokens.labelSmall.copyWith(
                        color: DesignTokens.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _diagnosisData.map((d) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: d.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${d.label} ${d.percentage}%',
                    style: DesignTokens.labelSmall.copyWith(
                      color: DesignTokens.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ===================== CHART 2: AI CONFIDENCE GAUGE =====================
  Widget _buildAIConfidenceGauge({required bool compact}) {
    String statusText = _aiConfidence >= 0.75
        ? 'Stable'
        : _aiConfidence >= 0.50
        ? 'Caution'
        : 'Uncertain';

    Color gaugeColor = _aiConfidence >= 0.75
        ? DesignTokens.confidenceHigh
        : _aiConfidence >= 0.50
        ? DesignTokens.confidenceMed
        : DesignTokens.confidenceLow;

    return Container(
      padding: EdgeInsets.all(compact ? DesignTokens.spaceMd : DesignTokens.spaceLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.cardBlack.withOpacity(0.8),
            DesignTokens.cardBlack.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DesignTokens.borderGray.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Iconsax.chart_1,
                color: DesignTokens.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'AI Confidence',
                  style: DesignTokens.headingSmall.copyWith(
                    color: DesignTokens.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          SizedBox(
            height: compact ? 128 : 140,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Center(
                  child: SizedBox(
                    width: compact ? 140 : 160,
                    height: compact ? 88 : 100,
                    child: CustomPaint(
                      painter: _GaugePainter(
                        progress: _aiConfidence,
                        color: gaugeColor,
                        pulseValue: _pulseController.value,
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '${(_aiConfidence * 100).round()}%',
                            style: DesignTokens.headingLarge.copyWith(
                              color: gaugeColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          Text(
            'AI Confidence: $statusText',
            style: DesignTokens.bodyMedium.copyWith(
              color: gaugeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== CHART 3: CASE DISTRIBUTION (STACKED HORIZONTAL BAR) =====================
  Widget _buildCaseDistributionBar({
    required bool compact,
    required double sectionWidth,
  }) {
    final barHeight = compact ? 40.0 : 44.0;
    final minBarWidth = 340.0;
    final useHScroll = sectionWidth < minBarWidth;

    final barRow = Row(
      children: [
        Expanded(
          flex: _clearCases.round(),
          child: Container(
            color: DesignTokens.confidenceHigh,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              'Clear ${_clearCases.round()}%',
              style: DesignTokens.labelMedium.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 11 : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: _reviewNeeded.round(),
          child: Container(
            color: DesignTokens.confidenceMed,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              'Review ${_reviewNeeded.round()}%',
              style: DesignTokens.labelMedium.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 11 : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: _complexCases.round(),
          child: Container(
            color: DesignTokens.confidenceLow,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              '${_complexCases.round()}%',
              style: DesignTokens.labelSmall.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: compact ? 11 : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.all(compact ? DesignTokens.spaceMd : DesignTokens.spaceLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.cardBlack.withOpacity(0.8),
            DesignTokens.cardBlack.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DesignTokens.borderGray.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.status_up,
                color: DesignTokens.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Case Distribution',
                  style: DesignTokens.headingSmall.copyWith(
                    color: DesignTokens.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: barHeight,
              child: useHScroll
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: minBarWidth,
                        height: barHeight,
                        child: barRow,
                      ),
                    )
                  : barRow,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== CHART 4: PATIENT COUNT LINE GRAPH =====================
  Widget _buildPatientCountChart({
    required bool compact,
    required double sectionWidth,
  }) {
    final chartHeight = compact ? 176.0 : 160.0;
    final chartWidth = math.max(sectionWidth, 320.0);
    final scrollChart = sectionWidth < 320;

    return Container(
      padding: EdgeInsets.all(compact ? DesignTokens.spaceMd : DesignTokens.spaceLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.cardBlack.withOpacity(0.8),
            DesignTokens.cardBlack.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DesignTokens.borderGray.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.graph, color: DesignTokens.textSecondary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Patient Count - Last 14 Days',
                  style: DesignTokens.headingSmall.copyWith(
                    color: DesignTokens.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          SizedBox(
            height: chartHeight,
            child: scrollChart
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: chartWidth,
                      height: chartHeight,
                      child: LineChart(_patientLineChartData()),
                    ),
                  )
                : LineChart(_patientLineChartData()),
          ),
        ],
      ),
    );
  }

  LineChartData _patientLineChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 3,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: DesignTokens.borderGray.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final day = value.toInt() + 1;
              if (day == 1 || day == 7 || day == 14) {
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'D$day',
                    style: DesignTokens.labelSmall.copyWith(
                      color: DesignTokens.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 13,
      minY: 0,
      maxY: 12,
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            _patientCounts.length,
            (i) => FlSpot(i.toDouble(), _patientCounts[i].toDouble()),
          ),
          isCurved: true,
          curveSmoothness: 0.3,
          color: DesignTokens.clinicalTeal,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: DesignTokens.clinicalTeal,
                strokeWidth: 2,
                strokeColor: DesignTokens.cardBlack,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: DesignTokens.clinicalTeal.withOpacity(0.12),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats({required bool compact}) {
    final gap = compact ? DesignTokens.spaceSm : DesignTokens.spaceMd;

    Widget rowPair({
      required Widget a,
      required Widget b,
    }) {
      return Row(
        children: [
          Expanded(child: a),
          SizedBox(width: gap),
          Expanded(child: b),
        ],
      );
    }

    final cards = <Widget>[
      rowPair(
        a: _buildMiniStatCard(
          compact: compact,
          icon: Iconsax.document_text,
          value: _totalAnalyses.toString(),
          label: 'Total Analyses',
          color: DesignTokens.medicalBlue,
        ),
        b: _buildMiniStatCard(
          compact: compact,
          icon: Iconsax.verify,
          value: '${(_avgConfidence * 100).round()}%',
          label: 'Avg Confidence',
          color: DesignTokens.clinicalTeal,
        ),
      ),
      SizedBox(height: gap),
      rowPair(
        a: _buildMiniStatCard(
          compact: compact,
          icon: Iconsax.tick_circle,
          value: _highConfidence.toString(),
          label: 'Clear Cases',
          color: DesignTokens.confidenceHigh,
        ),
        b: _buildMiniStatCard(
          compact: compact,
          icon: Iconsax.warning_2,
          value: _lowConfidence.toString(),
          label: 'Complex',
          color: DesignTokens.confidenceLow,
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.activity, color: DesignTokens.textSecondary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Quick Stats',
                style: DesignTokens.headingSmall.copyWith(
                  color: DesignTokens.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceMd),
        if (compact)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMiniStatCard(
                compact: true,
                icon: Iconsax.document_text,
                value: _totalAnalyses.toString(),
                label: 'Total Analyses',
                color: DesignTokens.medicalBlue,
              ),
              SizedBox(height: gap),
              _buildMiniStatCard(
                compact: true,
                icon: Iconsax.verify,
                value: '${(_avgConfidence * 100).round()}%',
                label: 'Avg Confidence',
                color: DesignTokens.clinicalTeal,
              ),
              SizedBox(height: gap),
              _buildMiniStatCard(
                compact: true,
                icon: Iconsax.tick_circle,
                value: _highConfidence.toString(),
                label: 'Clear Cases',
                color: DesignTokens.confidenceHigh,
              ),
              SizedBox(height: gap),
              _buildMiniStatCard(
                compact: true,
                icon: Iconsax.warning_2,
                value: _lowConfidence.toString(),
                label: 'Complex',
                color: DesignTokens.confidenceLow,
              ),
            ],
          )
        else
          ...cards,
      ],
    );
  }

  Widget _buildMiniStatCard({
    required bool compact,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(
            compact ? DesignTokens.spaceSm : DesignTokens.spaceMd,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DesignTokens.cardBlack.withOpacity(0.7),
                DesignTokens.cardBlack.withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2 + _pulseController.value * 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.06 + _pulseController.value * 0.03),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(compact ? 6 : 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: compact ? 16 : 18),
              ),
              SizedBox(height: compact ? 6 : DesignTokens.spaceSm),
              Text(
                value,
                style: (compact
                        ? DesignTokens.headingSmall
                        : DesignTokens.headingMedium)
                    .copyWith(
                  color: DesignTokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: DesignTokens.bodySmall.copyWith(
                  color: DesignTokens.textSecondary,
                  fontSize: compact ? 11 : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

// Data class for diagnosis
class _DiagnosisData {
  final String label;
  final int percentage;
  final Color color;
  _DiagnosisData(this.label, this.percentage, this.color);
}

// Custom painter for semi-circle gauge - FIXED SIZE
class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double pulseValue;

  _GaugePainter({
    required this.progress,
    required this.color,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = math.min(size.width / 2, size.height) - 12;

    // Background arc
    final bgPaint = Paint()
      ..color = DesignTokens.surfaceBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    // Glow arc
    final glowPaint = Paint()
      ..color = color.withOpacity(0.2 + pulseValue * 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * progress,
      false,
      glowPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.pulseValue != pulseValue;
  }
}
