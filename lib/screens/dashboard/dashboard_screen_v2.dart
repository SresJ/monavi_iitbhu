import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../config/breakpoints.dart';
import '../../config/design_tokens.dart';
import '../../shell/main_shell.dart';

/// DASHBOARD SCREEN V2 - PREMIUM LANDING PAGE STYLE
///
/// Features:
/// - Fake static data (no API calls needed)
/// - Interactive animated cards
/// - Fancy icons (Iconsax)
/// - Animated background with particles
/// - Big interactive insight button
/// - No back button
class DashboardScreenV2 extends StatefulWidget {
  const DashboardScreenV2({Key? key}) : super(key: key);

  @override
  State<DashboardScreenV2> createState() => _DashboardScreenV2State();
}

class _DashboardScreenV2State extends State<DashboardScreenV2>
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _floatController;
  late AnimationController _borderController;

  // Fake static data - no calculations needed
  final int _totalPatients = 52;
  final int _totalAnalyses = 205;
  final int _recentAnalyses = 34;
  final double _accuracyRate = 88;

  // Fake recent patients (Indian names)
  final List<Map<String, dynamic>> _recentPatients = [
    {'name': 'Ananya Sharma', 'age': 32, 'sex': 'Female', 'status': 'Active'},
    {'name': 'Kajol Verma', 'age': 48, 'sex': 'Female', 'status': 'Review'},
    {'name': 'Priya Iyer', 'age': 29, 'sex': 'Female', 'status': 'Clear'},
    {'name': 'Shreya Patel', 'age': 61, 'sex': 'Female', 'status': 'Active'},
  ];

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

    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _floatController.dispose();
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compactParticles = Breakpoints.isCompactWidth(
      MediaQuery.sizeOf(context).width,
    );

    return Scaffold(
      backgroundColor: DesignTokens.voidBlack,
      body: Stack(
        children: [
          // Enhanced animated background
          _buildAnimatedBackground(),

          // Floating particles (fewer on compact for clarity / perf)
          _buildFloatingParticles(compact: compactParticles),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = Breakpoints.isCompactWidth(
                    constraints.maxWidth,
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceLg,
                      vertical: DesignTokens.spaceMd,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(compact: compact)
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: -0.1, end: 0),

                        const SizedBox(height: DesignTokens.spaceMd),

                        _buildHealthAndChartSection(compact)
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 50.ms)
                            .slideY(begin: 0.05, end: 0),

                        const SizedBox(height: DesignTokens.spaceLg),

                        _buildStatusCards(compact)
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 100.ms)
                            .slideY(begin: 0.1, end: 0),

                        const SizedBox(height: DesignTokens.spaceLg),

                        _buildInsightButton(compact: compact)
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 200.ms)
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1, 1),
                            ),

                        const SizedBox(height: DesignTokens.spaceXl),

                        _buildRecentPatientsSection(compact: compact)
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 300.ms)
                            .slideY(begin: 0.1, end: 0),

                        const SizedBox(height: DesignTokens.spaceXl),

                        _buildQuickActions(compact: compact).animate().fadeIn(
                              duration: 600.ms,
                              delay: 400.ms,
                            ),

                        SizedBox(height: compact ? 120 : 100),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthAndChartSection(bool compact) {
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSystemHealthBanner(),
          const SizedBox(height: DesignTokens.spaceMd),
          _buildSystemSummaryBanner(),
          const SizedBox(height: DesignTokens.spaceMd),
          _buildAnalyticsGraphWidget(compact: true),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildSystemHealthBanner(),
              const SizedBox(height: DesignTokens.spaceMd),
              _buildSystemSummaryBanner(),
            ],
          ),
        ),
        const SizedBox(width: DesignTokens.spaceMd),
        Expanded(
          child: _buildAnalyticsGraphWidget(compact: false),
        ),
      ],
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_orbitController, _waveController]),
      builder: (context, child) {
        return Stack(
          children: [
            // Large blue orb - top left with wave motion
            Positioned(
              left: -120 + math.sin(_orbitController.value * 2 * math.pi) * 50,
              top: -50 + math.cos(_orbitController.value * 2 * math.pi) * 50,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      DesignTokens.medicalBlue.withOpacity(0.25),
                      DesignTokens.medicalBlue.withOpacity(0.1),
                      DesignTokens.medicalBlue.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Teal orb - right side
            Positioned(
              right:
                  -150 +
                  math.cos(_orbitController.value * 2 * math.pi + 1) * 60,
              top:
                  250 + math.sin(_orbitController.value * 2 * math.pi + 1) * 60,
              child: Container(
                width: 400,
                height: 400,
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

            // Green accent orb - bottom
            Positioned(
              left:
                  MediaQuery.of(context).size.width / 3 +
                  math.sin(_orbitController.value * 2 * math.pi + 2) * 70,
              bottom:
                  -100 +
                  math.cos(_orbitController.value * 2 * math.pi + 2) * 70,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      DesignTokens.confidenceHigh.withOpacity(0.15),
                      DesignTokens.confidenceHigh.withOpacity(0.05),
                      DesignTokens.confidenceHigh.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Purple accent - new
            Positioned(
              right:
                  50 + math.sin(_orbitController.value * 2 * math.pi + 3) * 40,
              top:
                  100 + math.cos(_orbitController.value * 2 * math.pi + 3) * 40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withOpacity(0.12),
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

  Widget _buildFloatingParticles({required bool compact}) {
    final count = compact ? 4 : 8;
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Stack(
          children: List.generate(count, (index) {
            final offset = index * 0.125;
            final cols = compact ? 2 : 4;
            final xStep = compact ? 140.0 : 100.0;
            final x = (index % cols) * xStep + 40;
            final y =
                (index ~/ cols) * (compact ? 220.0 : 300.0) +
                180 +
                math.sin((_floatController.value + offset) * 2 * math.pi) * 20;

            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: compact ? 5 : 6,
                height: compact ? 5 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignTokens.clinicalTeal.withOpacity(0.3),
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.clinicalTeal.withOpacity(0.2),
                      blurRadius: 8,
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
    final statusRow = Row(
      children: [
        Icon(
          Iconsax.timer_1,
          color: DesignTokens.confidenceHigh,
          size: 14,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'AI System Status:',
            style: DesignTokens.labelMedium.copyWith(
              color: DesignTokens.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Stable',
          style: DesignTokens.labelMedium.copyWith(
            color: DesignTokens.confidenceHigh,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back, Doctor',
          style: DesignTokens.bodyLarge.copyWith(
            color: DesignTokens.textSecondary,
          ),
          maxLines: compact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: DesignTokens.spaceSm),
        if (compact)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              statusRow,
              const SizedBox(height: 6),
              Text(
                '88% confidence avg',
                style: DesignTokens.labelSmall.copyWith(
                  color: DesignTokens.textTertiary,
                ),
              ),
            ],
          )
        else ...[
          statusRow,
          const SizedBox(height: 6),
          Text(
            '     88% confidence avg',
            style: DesignTokens.labelSmall.copyWith(
              color: DesignTokens.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSystemHealthBanner() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _borderController]),
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: DesignTokens.confidenceHigh.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: 3,
              color: DesignTokens.confidenceHigh.withOpacity(0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: DesignTokens.confidenceHigh,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.confidenceHigh.withOpacity(
                        0.4 + _pulseController.value * 0.2,
                      ),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated time saved today: ~123 min',
                    style: DesignTokens.bodyMedium.copyWith(
                      color: DesignTokens.confidenceHigh,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Equivalent to: ~6 patients consults',
                    style: DesignTokens.bodyMedium.copyWith(
                      color: DesignTokens.confidenceHigh,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSystemSummaryBanner() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: DesignTokens.confidenceMed.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: 3,
              color: DesignTokens.confidenceMed.withOpacity(0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: DesignTokens.confidenceMed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.confidenceMed.withOpacity(
                        0.4 + _pulseController.value * 0.2,
                      ),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You saved 11.4 hours this week',
                    style: DesignTokens.bodyMedium.copyWith(
                      color: DesignTokens.confidenceMed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Clinical Clarity improved by 46%',
                    style: DesignTokens.bodyMedium.copyWith(
                      color: DesignTokens.confidenceMed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsGraphWidget({required bool compact}) {
    final timeSavedData = [60.0, 85.0, 110.0, 130.0, 160.0, 180.0, 190.0];
    final clarityData = [62.0, 68.0, 72.0, 76.0, 80.0, 83.0, 86.0];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final legendItems = <Widget>[
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DesignTokens.clinicalTeal,
                  DesignTokens.confidenceHigh,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Time Saved (min)',
            style: DesignTokens.labelSmall.copyWith(
              color: DesignTokens.textTertiary,
            ),
          ),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 3,
            color: const Color(0xFF67E8F9),
          ),
          const SizedBox(width: 6),
          Text(
            'Clinical Clarity (%)',
            style: DesignTokens.labelSmall.copyWith(
              color: DesignTokens.textTertiary,
            ),
          ),
        ],
      ),
      Tooltip(
        message:
            'Based on reduced rework, fewer missing information alerts, and clinician feedback.',
        child: Icon(
          Icons.info_outline,
          size: 12,
          color: DesignTokens.textTertiary,
        ),
      ),
    ];

    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DesignTokens.cardBlack.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: DesignTokens.clinicalTeal.withValues(alpha: 0.8),
              width: 3,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (compact)
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: legendItems,
                )
              else
                Row(
                  children: [
                    legendItems[0],
                    const SizedBox(width: 16),
                    legendItems[1],
                    const SizedBox(width: 4),
                    legendItems[2],
                  ],
                ),
              const SizedBox(height: 12),
              SizedBox(
                height: compact ? 160 : 140,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 &&
                                idx < days.length &&
                                value == idx.toDouble()) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  days[idx],
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
                    maxX: 6,
                    minY: 0,
                    maxY: 200,
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          7,
                          (i) => FlSpot(i.toDouble(), timeSavedData[i]),
                        ),
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [
                            DesignTokens.clinicalTeal,
                            DesignTokens.confidenceHigh,
                          ],
                        ),
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) =>
                              FlDotCirclePainter(
                                radius: 3,
                                color: DesignTokens.confidenceHigh,
                                strokeWidth: 0,
                              ),
                        ),
                        belowBarData: BarAreaData(show: false),
                      ),
                      LineChartBarData(
                        spots: List.generate(
                          7,
                          (i) => FlSpot(i.toDouble(), clarityData[i]),
                        ),
                        isCurved: true,
                        color: const Color(0xFF67E8F9),
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) =>
                              FlDotCirclePainter(
                                radius: 3,
                                color: const Color(0xFF67E8F9),
                                strokeWidth: 0,
                              ),
                        ),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCards(bool compact) {
    final patientsCard = _buildStatCard(
      compact: compact,
      icon: Iconsax.people,
      value: _totalPatients.toString(),
      label: 'Total Patients',
      color: DesignTokens.medicalBlue,
      trend: '+12',
      trendUp: true,
    );
    final analysesCard = _buildStatCard(
      compact: compact,
      icon: Iconsax.document_text,
      value: _totalAnalyses.toString(),
      label: 'Total Analyses',
      color: DesignTokens.clinicalTeal,
      trend: '+$_recentAnalyses',
      trendUp: true,
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          patientsCard,
          const SizedBox(height: DesignTokens.spaceMd),
          analysesCard,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: patientsCard),
        const SizedBox(width: DesignTokens.spaceMd),
        Expanded(child: analysesCard),
      ],
    );
  }

  Widget _buildStatCard({
    required bool compact,
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required String trend,
    required bool trendUp,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            // Add haptic feedback or navigation
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DesignTokens.cardBlack.withOpacity(0.8),
                  DesignTokens.cardBlack.withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.2 + _pulseController.value * 0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1 + _pulseController.value * 0.05),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (trendUp
                                    ? DesignTokens.confidenceHigh
                                    : DesignTokens.error)
                                .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trendUp ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
                            color: trendUp
                                ? DesignTokens.confidenceHigh
                                : DesignTokens.error,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            trend,
                            style: DesignTokens.labelSmall.copyWith(
                              color: trendUp
                                  ? DesignTokens.confidenceHigh
                                  : DesignTokens.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: (compact
                            ? DesignTokens.headingMedium
                            : DesignTokens.headingLarge)
                        .copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: DesignTokens.bodySmall.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightButton({required bool compact}) {
    final titleStyle = (compact
            ? DesignTokens.headingSmall
            : DesignTokens.headingMedium)
        .copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    );

    final iconBox = Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        gradient: DesignTokens.medicalGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.medicalBlue.withOpacity(0.4),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Iconsax.chart,
        color: Colors.white,
        size: compact ? 24 : 28,
      ),
    );

    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'View Analytics',
          style: titleStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Iconsax.verify,
              color: DesignTokens.confidenceHigh,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${_accuracyRate.toStringAsFixed(1)}% Accuracy Rate',
                style: DesignTokens.bodyMedium.copyWith(
                  color: DesignTokens.confidenceHigh,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );

    final arrow = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Iconsax.arrow_right_3,
        color: DesignTokens.clinicalTeal,
        size: compact ? 20 : 24,
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _waveController]),
      builder: (context, child) {
        return GestureDetector(
          onTap: () => MainShellScope.goToTab(context, 2),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? DesignTokens.spaceMd : DesignTokens.spaceLg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DesignTokens.medicalBlue.withOpacity(0.3),
                  DesignTokens.clinicalTeal.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: DesignTokens.clinicalTeal.withOpacity(
                  0.3 + _pulseController.value * 0.2,
                ),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.clinicalTeal.withOpacity(
                    0.2 + _pulseController.value * 0.1,
                  ),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          iconBox,
                          const SizedBox(width: DesignTokens.spaceMd),
                          Expanded(child: textColumn),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.spaceSm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: arrow,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      iconBox,
                      const SizedBox(width: DesignTokens.spaceLg),
                      Expanded(child: textColumn),
                      arrow,
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildRecentPatientsSection({required bool compact}) {
    final titleRow = Row(
      children: [
        Icon(
          Iconsax.clock,
          color: DesignTokens.textSecondary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'Recent Patients',
            style: DesignTokens.headingSmall.copyWith(
              color: DesignTokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final viewAll = GestureDetector(
      onTap: () => MainShellScope.goToTab(context, 1),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: DesignTokens.clinicalTeal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: DesignTokens.clinicalTeal.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'View All',
              style: DesignTokens.labelMedium.copyWith(
                color: DesignTokens.clinicalTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Iconsax.arrow_right_3,
              color: DesignTokens.clinicalTeal,
              size: 16,
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (compact)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleRow,
              const SizedBox(height: DesignTokens.spaceSm),
              viewAll,
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: titleRow),
              viewAll,
            ],
          ),
        const SizedBox(height: DesignTokens.spaceMd),

        // Patient tiles
        ...List.generate(_recentPatients.length, (index) {
          return _buildPatientTile(_recentPatients[index], index);
        }),
      ],
    );
  }

  Widget _buildPatientTile(Map<String, dynamic> patient, int index) {
    final statusColors = {
      'Active': DesignTokens.medicalBlue,
      'Review': DesignTokens.confidenceMed,
      'Clear': DesignTokens.confidenceHigh,
    };
    final statusColor =
        statusColors[patient['status']] ?? DesignTokens.textSecondary;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
              child: GestureDetector(
                onTap: () => MainShellScope.goToTab(context, 1),
                child: Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceMd),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        DesignTokens.cardBlack.withOpacity(0.7),
                        DesignTokens.cardBlack.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: DesignTokens.borderGray.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Avatar with profile image
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: statusColor.withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.15),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/profile${index + 1}.jpg',
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: DesignTokens.medicalGradient,
                                ),
                                child: Center(
                                  child: Text(
                                    _getInitials(patient['name']),
                                    style: DesignTokens.labelLarge.copyWith(
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

                      // Patient info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _capitalizeWords(patient['name']),
                              style: DesignTokens.bodyLarge.copyWith(
                                color: DesignTokens.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${patient['age']} Yrs · ${_capitalizeFirst(patient['sex'])}',
                              style: DesignTokens.bodySmall.copyWith(
                                color: DesignTokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _capitalizeFirst(patient['status']),
                          style: DesignTokens.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(width: DesignTokens.spaceSm),

                      Icon(
                        Iconsax.arrow_right_3,
                        color: DesignTokens.textTertiary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms, delay: (100 * index).ms)
            .slideX(begin: 0.05, end: 0);
      },
    );
  }

  Widget _buildQuickActions({required bool compact}) {
    final addPatient = _buildActionButton(
      compact: compact,
      icon: Iconsax.user_add,
      label: 'Add Patient',
      color: DesignTokens.medicalBlue,
      onTap: () => MainShellScope.goToTab(context, 1),
    );
    final newAnalysis = _buildActionButton(
      compact: compact,
      icon: Iconsax.document_text_1,
      label: 'New Analysis',
      color: DesignTokens.clinicalTeal,
      onTap: () => MainShellScope.goToTab(context, 1),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          addPatient,
          const SizedBox(height: DesignTokens.spaceMd),
          newAnalysis,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: addPatient),
        const SizedBox(width: DesignTokens.spaceMd),
        Expanded(child: newAnalysis),
      ],
    );
  }

  Widget _buildActionButton({
    required bool compact,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceMd,
              vertical: compact ? DesignTokens.spaceMd : DesignTokens.spaceLg,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: compact ? 20 : 22),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    style: DesignTokens.labelLarge.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}

class _GlowingBorderPainter extends CustomPainter {
  final double progress;
  final Color glowColor;
  final double borderRadius;

  _GlowingBorderPainter({
    required this.progress,
    required this.glowColor,
    this.borderRadius = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics().toList();

    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, basePaint);

    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

    for (final metric in pathMetrics) {
      final length = metric.length;
      final start = length * progress;
      final end = start + length * 0.15;

      if (end <= length) {
        final glowSegment = metric.extractPath(start, end);
        canvas.drawPath(glowSegment, glowPaint);
      } else {
        final first = metric.extractPath(start, length);
        final second = metric.extractPath(0, end - length);
        canvas.drawPath(first, glowPaint);
        canvas.drawPath(second, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GlowingBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowColor != glowColor;
  }
}
