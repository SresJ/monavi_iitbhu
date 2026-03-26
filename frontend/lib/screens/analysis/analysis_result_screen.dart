import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../config/breakpoints.dart';
import '../../config/design_tokens.dart';
import '../../providers/analysis_provider.dart';
import '../../models/analysis.dart';
import '../../widgets/cards/diagnosis_card.dart';
import '../../widgets/loading/enhanced_clinical_loading.dart';
import '../../services/pdf_service.dart';

/// ANALYSIS RESULT SCREEN - PREMIUM UI
class AnalysisResultScreen extends StatefulWidget {
  final String analysisId;

  const AnalysisResultScreen({Key? key, required this.analysisId})
    : super(key: key);

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _orbitController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late List<AnimationController> _cardControllers;

  int? _hoveredPieIndex;

  // Hardcoded missing info data for expandable cards
  final List<_MissingInfoItem> _missingInfoItems = [
    _MissingInfoItem(
      name: 'Complete Blood Count (CBC)',
      status: 'Missing',
      color: const Color(0xFF4FC3F7),
      lastDone: null,
      note:
          'Essential for detecting infections, anemia, and other blood disorders.',
      hasPreviousReport: false,
    ),
    _MissingInfoItem(
      name: 'Abdominal Ultrasound',
      status: 'Outdated',
      color: const Color(0xFF81C784),
      lastDone: DateTime(2024, 8, 15),
      note: 'Helps visualize internal organs and detect abnormalities.',
      hasPreviousReport: true,
    ),
    _MissingInfoItem(
      name: 'Liver Function Test',
      status: 'Missing',
      color: const Color(0xFFFFB74D),
      lastDone: null,
      note: 'Evaluates liver health and detects potential liver damage.',
      hasPreviousReport: false,
    ),
    _MissingInfoItem(
      name: 'Lipid Panel',
      status: 'Outdated',
      color: const Color(0xFFBA68C8),
      lastDone: DateTime(2024, 3, 22),
      note: 'Assesses cardiovascular risk through cholesterol levels.',
      hasPreviousReport: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _cardControllers = [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalysis();
    });
  }

  Future<void> _loadAnalysis() async {
    final provider = context.read<AnalysisProvider>();
    await provider.getAnalysisById(widget.analysisId);

    final analysis = provider.currentAnalysis;
    if (analysis != null) {
      _cardControllers = List.generate(
        analysis.diagnoses.length,
        (index) => AnimationController(
          duration: const Duration(milliseconds: 600),
          vsync: this,
        ),
      );

      _fadeController.forward();

      for (int i = 0; i < _cardControllers.length; i++) {
        Future.delayed(Duration(milliseconds: 150 * i), () {
          if (mounted) {
            _cardControllers[i].forward();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _orbitController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisProvider>();
    final analysis = provider.currentAnalysis;

    if (provider.isLoading && analysis == null) {
      return Scaffold(
        backgroundColor: DesignTokens.voidBlack,
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            const Center(
              child: EnhancedClinicalLoading(
                message: 'Loading Analysis Results...',
                size: 60,
              ),
            ),
          ],
        ),
      );
    }

    if (analysis == null) {
      final compactNull = Breakpoints.isCompactWidth(
        MediaQuery.sizeOf(context).width,
      );
      return Scaffold(
        backgroundColor: DesignTokens.voidBlack,
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(null, compact: compactNull),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: DesignTokens.confidenceLow.withOpacity(
                                0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Iconsax.document,
                              color: DesignTokens.confidenceLow,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: DesignTokens.spaceLg),
                          Text(
                            'Analysis Not Found',
                            style: DesignTokens.headingMedium.copyWith(
                              color: DesignTokens.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: DesignTokens.voidBlack,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildFloatingParticles(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeController,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = Breakpoints.isCompactWidth(
                    constraints.maxWidth,
                  );
                  final bottomPad = MediaQuery.paddingOf(context).bottom;
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      DesignTokens.spaceLg,
                      DesignTokens.spaceLg,
                      DesignTokens.spaceLg,
                      DesignTokens.spaceLg + bottomPad + (compact ? 24 : 0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(analysis, compact: compact)
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: -0.1, end: 0),

                        const SizedBox(height: DesignTokens.spaceLg),

                        _buildCompactHeader(analysis, compact: compact)
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 100.ms)
                            .slideY(begin: 0.05, end: 0),

                        const SizedBox(height: DesignTokens.spaceLg),

                        _buildFollowUpCTA(analysis.analysisId, compact: compact)
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 200.ms)
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1, 1),
                            ),

                        const SizedBox(height: DesignTokens.spaceXl),
                        _buildQuickSummary(analysis.summary)
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 300.ms)
                            .slideY(begin: 0.05, end: 0),
                        const SizedBox(height: DesignTokens.spaceXl),
                        _buildDifferentialPieChart(
                          analysis,
                          compact: compact,
                        ).animate().fadeIn(duration: 600.ms, delay: 250.ms),

                        const SizedBox(height: DesignTokens.spaceXl),

                        _buildDifferentialDiagnoses(analysis, compact: compact),

                        const SizedBox(height: DesignTokens.spaceXl),

                        if (analysis.diagnosticTests.isNotEmpty) ...[
                          _buildCompactDiagnosticTests(
                            analysis.diagnosticTests,
                            compact: compact,
                          ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                          const SizedBox(height: DesignTokens.spaceLg),
                        ],

                        _buildExpandableMissingInfo(compact: compact).animate().fadeIn(
                              duration: 600.ms,
                              delay: 450.ms,
                            ),

                        const SizedBox(height: DesignTokens.spaceXl),

                        _buildClinicalDisclaimer().animate().fadeIn(
                              duration: 600.ms,
                              delay: 500.ms,
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

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _orbitController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              right: -80 + math.sin(_orbitController.value * 2 * math.pi) * 40,
              top: 60 + math.cos(_orbitController.value * 2 * math.pi) * 40,
              child: Container(
                width: 300,
                height: 300,
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
            Positioned(
              left:
                  -100 +
                  math.cos(_orbitController.value * 2 * math.pi + 1.5) * 50,
              top:
                  250 +
                  math.sin(_orbitController.value * 2 * math.pi + 1.5) * 50,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      DesignTokens.clinicalTeal.withOpacity(0.15),
                      DesignTokens.clinicalTeal.withOpacity(0.05),
                      DesignTokens.clinicalTeal.withOpacity(0.0),
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
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Stack(
          children: List.generate(6, (index) {
            final offset = index * 0.15;
            final x = (index % 3) * 120.0 + 50;
            final y =
                (index ~/ 3) * 300.0 +
                200 +
                math.sin((_floatController.value + offset) * 2 * math.pi) * 12;
            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignTokens.medicalBlue.withOpacity(0.3),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildHeader(Analysis? analysis, {required bool compact}) {
    final back = GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: DesignTokens.cardBlack.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: DesignTokens.borderGray.withOpacity(0.3),
          ),
        ),
        child: Icon(
          Iconsax.arrow_left,
          color: DesignTokens.textSecondary,
          size: 22,
        ),
      ),
    );

    final titleStyle = (compact
            ? DesignTokens.headingSmall
            : DesignTokens.headingMedium)
        .copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    );

    final titleRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: DesignTokens.medicalGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Iconsax.document_text,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: DesignTokens.spaceMd),
        Flexible(
          child: ShaderMask(
            shaderCallback: (bounds) =>
                DesignTokens.medicalGradient.createShader(bounds),
            child: Text(
              'Analysis Results',
              style: titleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );

    final Widget trailing = analysis != null
        ? GestureDetector(
            onTap: () => _exportPdf(analysis.analysisId),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: DesignTokens.cardBlack.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DesignTokens.clinicalTeal.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Iconsax.document_download,
                color: DesignTokens.clinicalTeal,
                size: 22,
              ),
            ),
          )
        : const SizedBox(width: 42);

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              back,
              if (analysis != null) trailing else const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          titleRow,
        ],
      );
    }

    return Row(
      children: [
        back,
        Expanded(
          child: Center(child: titleRow),
        ),
        trailing,
      ],
    );
  }

  Widget _buildCompactHeader(Analysis analysis, {required bool compact}) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
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
        border: Border.all(color: DesignTokens.medicalBlue.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DesignTokens.medicalBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Iconsax.health,
              color: DesignTokens.medicalBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (compact)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        analysis.analysisId.toUpperCase(),
                        style: DesignTokens.labelMedium.copyWith(
                          color: DesignTokens.clinicalTeal,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: DesignTokens.medicalBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          DateFormat('MMM dd, HH:mm').format(analysis.createdAt),
                          style: DesignTokens.labelSmall.copyWith(
                            color: DesignTokens.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          analysis.analysisId.toUpperCase(),
                          style: DesignTokens.labelMedium.copyWith(
                            color: DesignTokens.clinicalTeal,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spaceSm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: DesignTokens.medicalBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          DateFormat('MMM dd, HH:mm').format(analysis.createdAt),
                          style: DesignTokens.labelSmall.copyWith(
                            color: DesignTokens.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (analysis.summary.age != null ||
                    analysis.summary.sex != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    [
                      if (analysis.summary.age != null)
                        '${analysis.summary.age} Years Old',
                      if (analysis.summary.sex != null)
                        _capitalizeFirst(analysis.summary.sex!),
                    ].join(' • '),
                    style: DesignTokens.bodyMedium.copyWith(
                      color: DesignTokens.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpCTA(String analysisId, {required bool compact}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/analysis/$analysisId/chat');
      },
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spaceLg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DesignTokens.medicalBlue.withOpacity(0.2),
              DesignTokens.clinicalTeal.withOpacity(0.12),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: DesignTokens.medicalBlue.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: DesignTokens.medicalGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Iconsax.message_question,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ask Follow-Up Questions',
                              style: DesignTokens.headingSmall.copyWith(
                                color: DesignTokens.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Get AI-Powered Answers With Full Analysis Context',
                              style: DesignTokens.bodySmall.copyWith(
                                color: DesignTokens.textSecondary,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceSm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: DesignTokens.medicalBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Iconsax.arrow_right,
                        color: DesignTokens.medicalBlue,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: DesignTokens.medicalGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Iconsax.message_question,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ask Follow-Up Questions',
                          style: DesignTokens.headingSmall.copyWith(
                            color: DesignTokens.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Get AI-Powered Answers With Full Analysis Context',
                          style: DesignTokens.bodySmall.copyWith(
                            color: DesignTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: DesignTokens.medicalBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Iconsax.arrow_right,
                      color: DesignTokens.medicalBlue,
                      size: 20,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ===================== DIFFERENTIAL DIAGNOSIS PIE CHART =====================
  Widget _buildDifferentialPieChart(Analysis analysis, {required bool compact}) {
    final diagnoses = analysis.sortedDiagnoses;
    if (diagnoses.isEmpty) return const SizedBox.shrink();

    final colors = [
      const Color(0xFF4FC3F7),
      const Color(0xFF81C784),
      const Color(0xFFFFB74D),
      const Color(0xFFBA68C8),
      const Color(0xFFE57373),
    ];

    Widget pieChartCore() {
      return PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  _hoveredPieIndex = null;
                  return;
                }
                final idx =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
                _hoveredPieIndex = idx >= 0 ? idx : null;
              });
            },
          ),
          sectionsSpace: 2,
          centerSpaceRadius: compact ? 34 : 40,
          sections: List.generate(diagnoses.length, (index) {
            final d = diagnoses[index];
            final isHovered = _hoveredPieIndex == index;
            return PieChartSectionData(
              value: d.confidence * 100,
              color: colors[index % colors.length],
              radius: isHovered ? (compact ? 46 : 55) : (compact ? 38 : 45),
              showTitle: false,
            );
          }),
        ),
      );
    }

    Widget legendColumn() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hoveredPieIndex != null &&
              _hoveredPieIndex! < diagnoses.length) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors[_hoveredPieIndex! % colors.length]
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors[_hoveredPieIndex! % colors.length]
                      .withOpacity(0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diagnoses[_hoveredPieIndex!].diagnosisName,
                    style: DesignTokens.labelLarge.copyWith(
                      color: colors[_hoveredPieIndex! % colors.length],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(diagnoses[_hoveredPieIndex!].confidence * 100).round()}% Confidence',
                    style: DesignTokens.bodyMedium.copyWith(
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    diagnoses[_hoveredPieIndex!].confidenceRationale.isNotEmpty
                        ? diagnoses[_hoveredPieIndex!].confidenceRationale.first
                        : 'Based on clinical presentation',
                    style: DesignTokens.bodySmall.copyWith(
                      color: DesignTokens.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ] else ...[
            ...diagnoses.take(4).toList().asMap().entries.map((entry) {
              final idx = entry.key;
              final d = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[idx % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        d.diagnosisName,
                        style: DesignTokens.labelSmall.copyWith(
                          color: DesignTokens.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${(d.confidence * 100).round()}%',
                      style: DesignTokens.labelSmall.copyWith(
                        color: colors[idx % colors.length],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.cardBlack.withOpacity(0.8),
            DesignTokens.cardBlack.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DesignTokens.borderGray.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.diagram, color: DesignTokens.clinicalTeal, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Differential Diagnosis',
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
          const SizedBox(height: DesignTokens.spaceLg),
          if (compact) ...[
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Center(
                child: SizedBox(
                  width: 188,
                  height: 188,
                  child: pieChartCore(),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            legendColumn(),
          ] else
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(child: pieChartCore()),
                  const SizedBox(width: DesignTokens.spaceMd),
                  Expanded(child: legendColumn()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickSummary(Summary summary) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
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
        border: Border.all(color: DesignTokens.borderGray.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DesignTokens.medicalBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Iconsax.note_text,
                  color: DesignTokens.medicalBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              Text(
                'Clinical Summary',
                style: DesignTokens.labelLarge.copyWith(
                  color: DesignTokens.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (summary.chiefComplaint != null) ...[
            const SizedBox(height: DesignTokens.spaceMd),
            Text(
              _capitalizeFirst(summary.chiefComplaint!),
              style: DesignTokens.bodyMedium.copyWith(
                color: DesignTokens.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (summary.associatedSymptoms.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spaceMd),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: summary.associatedSymptoms.take(5).map((symptom) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.medicalBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: DesignTokens.medicalBlue.withOpacity(0.25),
                    ),
                  ),
                  child: Text(
                    _capitalizeFirst(symptom),
                    style: DesignTokens.labelSmall.copyWith(
                      color: DesignTokens.medicalBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDifferentialDiagnoses(
    Analysis analysis, {
    required bool compact,
  }) {
    final sortedDiagnoses = analysis.sortedDiagnoses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DesignTokens.clinicalTeal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Iconsax.chart_square,
                color: DesignTokens.clinicalTeal,
                size: 18,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSm),
            Expanded(
              child: Text(
                'Differential Diagnoses',
                style: DesignTokens.headingMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: compact ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: DesignTokens.clinicalTeal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${sortedDiagnoses.length} Diagnoses',
                style: DesignTokens.labelSmall.copyWith(
                  color: DesignTokens.clinicalTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 350.ms),
        const SizedBox(height: DesignTokens.spaceMd),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedDiagnoses.length,
          itemBuilder: (context, index) {
            if (index >= _cardControllers.length) {
              return const SizedBox.shrink();
            }

            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _cardControllers[index],
                      curve: Curves.easeOut,
                    ),
                  ),
              child: FadeTransition(
                opacity: _cardControllers[index],
                child: Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
                  child: DiagnosisCard(
                    diagnosis: sortedDiagnoses[index],
                    rank: index + 1,
                    initiallyExpanded: index == 0,
                    compact: compact,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompactDiagnosticTests(
    List<DiagnosticTest> tests, {
    required bool compact,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceMd),
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
        border: Border.all(color: DesignTokens.clinicalTeal.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DesignTokens.clinicalTeal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Iconsax.microscope,
                  color: DesignTokens.clinicalTeal,
                  size: 18,
                ),
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              Expanded(
                child: Text(
                  'Recommended Tests',
                  style: DesignTokens.labelLarge.copyWith(
                    color: DesignTokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: compact ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: DesignTokens.spaceSm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignTokens.clinicalTeal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${tests.length}',
                  style: DesignTokens.labelSmall.copyWith(
                    color: DesignTokens.clinicalTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          ...tests.map(
            (test) => Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: DesignTokens.clinicalTeal,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceSm),
                  Expanded(
                    child: Text(
                      _capitalizeFirst(test.testName),
                      style: DesignTokens.bodyMedium.copyWith(
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== EXPANDABLE MISSING INFO CARDS =====================
  Widget _buildExpandableMissingInfo({required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DesignTokens.confidenceMed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Iconsax.info_circle,
                color: DesignTokens.confidenceMed,
                size: 18,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSm),
            Expanded(
              child: Text(
                'Missing Information',
                style: DesignTokens.labelLarge.copyWith(
                  color: DesignTokens.confidenceMed,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: compact ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DesignTokens.confidenceMed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${_missingInfoItems.length}',
                style: DesignTokens.labelSmall.copyWith(
                  color: DesignTokens.confidenceMed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceMd),
        ..._missingInfoItems.map((item) => _MissingInfoCard(item: item)),
      ],
    );
  }

  Widget _buildClinicalDisclaimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceBlack.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesignTokens.borderGray.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.shield_tick, color: DesignTokens.textTertiary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'AI-generated insights support clinical decision-making and do not replace professional judgment.',
              style: DesignTokens.bodySmall.copyWith(
                color: DesignTokens.textTertiary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(String analysisId) async {
    final provider = context.read<AnalysisProvider>();
    final analysis = provider.currentAnalysis;

    if (analysis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Iconsax.warning_2, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text('Analysis not available', style: DesignTokens.bodyMedium.copyWith(color: Colors.white)),
            ],
          ),
          backgroundColor: DesignTokens.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            const SizedBox(width: 12),
            Text('Generating PDF...', style: DesignTokens.bodyMedium.copyWith(color: Colors.white)),
          ],
        ),
        backgroundColor: DesignTokens.clinicalTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      await PdfService.generateAndShareAnalysisReport(analysis);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Iconsax.warning_2, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text('Failed to generate PDF', style: DesignTokens.bodyMedium.copyWith(color: Colors.white)),
              ],
            ),
            backgroundColor: DesignTokens.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}

// ===================== MISSING INFO DATA CLASS =====================
class _MissingInfoItem {
  final String name;
  final String status;
  final Color color;
  final DateTime? lastDone;
  final String note;
  final bool hasPreviousReport;

  _MissingInfoItem({
    required this.name,
    required this.status,
    required this.color,
    this.lastDone,
    required this.note,
    required this.hasPreviousReport,
  });
}

// ===================== EXPANDABLE MISSING INFO CARD =====================
class _MissingInfoCard extends StatefulWidget {
  final _MissingInfoItem item;
  const _MissingInfoCard({required this.item});

  @override
  State<_MissingInfoCard> createState() => _MissingInfoCardState();
}

class _MissingInfoCardState extends State<_MissingInfoCard> {
  bool _isExpanded = false;

  void _showFakeReportModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignTokens.cardBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Iconsax.document_text, color: widget.item.color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.item.name,
                style: DesignTokens.headingSmall.copyWith(
                  color: DesignTokens.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Previous Report',
              style: DesignTokens.labelMedium.copyWith(
                color: DesignTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignTokens.surfaceBlack,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date: ${widget.item.lastDone != null ? DateFormat('MMM dd, yyyy').format(widget.item.lastDone!) : 'N/A'}',
                    style: DesignTokens.bodyMedium.copyWith(
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Result: Within normal limits',
                    style: DesignTokens.bodyMedium.copyWith(
                      color: DesignTokens.confidenceHigh,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Notes: No significant findings. Recommend follow-up in 6 months.',
                    style: DesignTokens.bodySmall.copyWith(
                      color: DesignTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: widget.item.color)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
      decoration: BoxDecoration(
        color: widget.item.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.item.color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.name,
                      style: DesignTokens.bodyMedium.copyWith(
                        color: DesignTokens.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.item.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.item.status,
                      style: DesignTokens.labelSmall.copyWith(
                        color: widget.item.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                    color: widget.item.color,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spaceMd,
                0,
                DesignTokens.spaceMd,
                DesignTokens.spaceMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: DesignTokens.borderGray, height: 1),
                  const SizedBox(height: DesignTokens.spaceSm),
                  Text(
                    widget.item.lastDone != null
                        ? 'Last done: ${DateFormat('MMM dd, yyyy').format(widget.item.lastDone!)}'
                        : 'Never done',
                    style: DesignTokens.labelSmall.copyWith(
                      color: DesignTokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.note,
                    style: DesignTokens.bodySmall.copyWith(
                      color: DesignTokens.textSecondary,
                    ),
                  ),
                  if (widget.item.hasPreviousReport) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _showFakeReportModal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: widget.item.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.document,
                              color: widget.item.color,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'View Previous Report',
                              style: DesignTokens.labelSmall.copyWith(
                                color: widget.item.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
