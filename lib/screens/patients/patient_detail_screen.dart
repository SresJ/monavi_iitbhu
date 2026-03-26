import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'dart:math' as math;
import '../../providers/patient_provider.dart';
import '../../providers/analysis_provider.dart';
import '../../models/patient.dart';
import '../../models/analysis.dart';
import '../../config/breakpoints.dart';
import '../../config/design_tokens.dart';
import '../../widgets/loading/skeleton_loader.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with TickerProviderStateMixin {
  Patient? _patient;
  bool _isLoading = true;
  late AnimationController _orbitController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _borderController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPatientData();
    });
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _borderController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    setState(() => _isLoading = true);
    try {
      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      final analysisProvider = Provider.of<AnalysisProvider>(
        context,
        listen: false,
      );
      final patient = await patientProvider.getPatientById(widget.patientId);
      await analysisProvider.loadPatientAnalyses(widget.patientId);
      setState(() {
        _patient = patient;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Iconsax.warning_2, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Error Loading Patient',
                  style: DesignTokens.bodyMedium.copyWith(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: DesignTokens.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignTokens.cardBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: DesignTokens.error.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: DesignTokens.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Iconsax.trash, color: DesignTokens.error, size: 22),
            ),
            const SizedBox(width: 12),
            Text('Delete Patient?', style: DesignTokens.headingMedium),
          ],
        ),
        content: Text(
          'This Action Cannot Be Undone.',
          style: DesignTokens.bodyLarge.copyWith(
            color: DesignTokens.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: DesignTokens.labelLarge.copyWith(
                color: DesignTokens.textSecondary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: DesignTokens.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: DesignTokens.error.withOpacity(0.3)),
              ),
              child: Text(
                'Delete',
                style: DesignTokens.labelLarge.copyWith(
                  color: DesignTokens.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final patientProvider = Provider.of<PatientProvider>(
        context,
        listen: false,
      );
      final success = await patientProvider.deletePatient(widget.patientId);
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _handleEdit() {
    if (_patient != null) {
      Navigator.pushNamed(
        context,
        '/patients/${widget.patientId}/edit',
        arguments: _patient,
      ).then((_) => _loadPatientData());
    }
  }

  void _handleNewAnalysis() {
    if (_patient != null) {
      Navigator.pushNamed(context, '/analysis/new', arguments: _patient);
    }
  }

  void _handleAnalysisClick(Analysis analysis) {
    Navigator.pushNamed(context, '/analysis/${analysis.analysisId}');
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      final loadingCompact = Breakpoints.isCompactWidth(
        MediaQuery.sizeOf(context).width,
      );
      return Scaffold(
        backgroundColor: DesignTokens.voidBlack,
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            _buildFloatingParticles(compact: loadingCompact),
            const SafeArea(child: _LoadingSkeleton()),
          ],
        ),
      );
    }

    if (_patient == null) {
      return Scaffold(
        backgroundColor: DesignTokens.voidBlack,
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackButton(),
                    const Spacer(),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Iconsax.user_remove,
                            color: DesignTokens.textTertiary,
                            size: 64,
                          ),
                          const SizedBox(height: DesignTokens.spaceLg),
                          Text(
                            'Patient Not Found',
                            style: DesignTokens.headingLarge.copyWith(
                              color: DesignTokens.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final narrowForEffects = Breakpoints.isCompactWidth(
      MediaQuery.sizeOf(context).width,
    );

    return Scaffold(
      backgroundColor: DesignTokens.voidBlack,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildFloatingParticles(compact: narrowForEffects),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadPatientData,
              color: DesignTokens.clinicalTeal,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = Breakpoints.isCompactWidth(
                    constraints.maxWidth,
                  );
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceLg,
                        vertical: DesignTokens.spaceMd,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildNavigation().animate().fadeIn(duration: 500.ms),

                          const SizedBox(height: DesignTokens.spaceXl),

                          _buildHeroHeader(compact: compact)
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 100.ms)
                              .slideY(begin: 0.05, end: 0),

                          _buildMinimalStats(compact: compact).animate().fadeIn(
                                duration: 600.ms,
                                delay: 150.ms,
                              ),

                          const SizedBox(height: DesignTokens.spaceXl),

                          _buildHeroNewAnalysisButton(compact: compact)
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 200.ms)
                              .scale(
                                begin: const Offset(0.98, 0.98),
                                end: const Offset(1, 1),
                              ),

                          const SizedBox(height: DesignTokens.spaceXl),

                          _buildWhatChanged(compact: compact)
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 250.ms)
                              .slideY(begin: 0.05, end: 0),

                          const SizedBox(height: DesignTokens.spaceLg),

                          _buildClinicalFocus(compact: compact)
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 300.ms)
                              .slideY(begin: 0.05, end: 0),

                          const SizedBox(height: DesignTokens.spaceLg),

                          _buildEnhancedLastVisitCard(compact: compact)
                              .animate()
                              .fadeIn(
                                duration: 600.ms,
                                delay: 350.ms,
                              ),

                          const SizedBox(height: DesignTokens.spaceMd),

                          _buildHistory(),

                          const SizedBox(height: 40),
                        ],
                      ),
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
              left: -100 + math.sin(_orbitController.value * 2 * math.pi) * 40,
              top: -60 + math.cos(_orbitController.value * 2 * math.pi) * 40,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      DesignTokens.medicalBlue.withOpacity(0.22),
                      DesignTokens.medicalBlue.withOpacity(0.08),
                      DesignTokens.medicalBlue.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right:
                  -120 +
                  math.cos(_orbitController.value * 2 * math.pi + 1.5) * 50,
              top:
                  280 +
                  math.sin(_orbitController.value * 2 * math.pi + 1.5) * 50,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      DesignTokens.clinicalTeal.withOpacity(0.18),
                      DesignTokens.clinicalTeal.withOpacity(0.06),
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

  Widget _buildFloatingParticles({required bool compact}) {
    final count = compact ? 3 : 6;
    final cols = compact ? 2 : 3;
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Stack(
          children: List.generate(count, (index) {
            final xStep = compact ? 120.0 : 140.0;
            final x = (index % cols) * xStep + 36;
            final y =
                (index ~/ cols) * (compact ? 260.0 : 350.0) +
                160 +
                math.sin(
                      (_floatController.value + index * 0.15) * 2 * math.pi,
                    ) *
                    15;
            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: compact ? 4 : 5,
                height: compact ? 4 : 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignTokens.clinicalTeal.withOpacity(0.25),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: DesignTokens.cardBlack.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DesignTokens.borderGray.withOpacity(0.3)),
        ),
        child: Icon(
          Iconsax.arrow_left,
          color: DesignTokens.textSecondary,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBackButton(),
        Row(
          children: [
            GestureDetector(
              onTap: _handleEdit,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DesignTokens.clinicalTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DesignTokens.clinicalTeal.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  Iconsax.edit_2,
                  color: DesignTokens.clinicalTeal,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSm),
            GestureDetector(
              onTap: _handleDelete,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DesignTokens.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DesignTokens.error.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  Iconsax.trash,
                  color: DesignTokens.error.withOpacity(0.8),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroHeader({required bool compact}) {
    final avatarSize = compact ? 88.0 : 100.0;
    final nameStyle = (compact
            ? DesignTokens.headingLarge
            : DesignTokens.displayMedium)
        .copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: compact ? -0.5 : -1.5,
      height: 1.1,
    );

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final infoColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: DesignTokens.clinicalTeal.withOpacity(
                    0.4 + _pulseController.value * 0.2,
                  ),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.medicalBlue.withOpacity(
                      0.2 + _pulseController.value * 0.1,
                    ),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  _patient!.avatarPath,
                  width: avatarSize,
                  height: avatarSize,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: DesignTokens.medicalGradient,
                    ),
                    child: Center(
                      child: Text(
                        _patient!.initials,
                        style: DesignTokens.headingLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: compact ? DesignTokens.spaceMd : DesignTokens.spaceLg),
            Text(
              _patient!.displayName,
              style: nameStyle,
              maxLines: compact ? 3 : 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: DesignTokens.spaceSm),
            if (_patient!.ageSexDisplay.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Iconsax.user,
                    color: DesignTokens.textTertiary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _patient!.ageSexDisplay,
                      style: DesignTokens.headingSmall.copyWith(
                        color: DesignTokens.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            if (_patient!.mrn != null) ...[
              const SizedBox(height: DesignTokens.spaceSm),
              Row(
                children: [
                  Icon(
                    Iconsax.document,
                    color: DesignTokens.textTertiary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _patient!.mrn!,
                      style: DesignTokens.bodyLarge.copyWith(
                        color: DesignTokens.textTertiary,
                        letterSpacing: 1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );

        final trajectory = _buildRecoveryTrajectory(compact: compact);

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              infoColumn,
              const SizedBox(height: DesignTokens.spaceLg),
              trajectory,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: infoColumn),
            const SizedBox(width: DesignTokens.spaceMd),
            Expanded(flex: 3, child: trajectory),
          ],
        );
      },
    );
  }

  Widget _buildRecoveryTrajectory({required bool compact}) {
    final name = _patient!.fullName.toLowerCase();
    final data = _getTrajectoryData(name);

    Widget visitColumn(int i) {
      final visit = data[i];
      return Tooltip(
        message: visit['tooltip'] as String,
        textStyle: DesignTokens.bodySmall.copyWith(color: Colors.white),
        decoration: BoxDecoration(
          color: DesignTokens.cardBlack,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'V${i + 1}',
              style: DesignTokens.labelSmall.copyWith(
                color: DesignTokens.textTertiary,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 6),
            _HumanSilhouette(
              fillPercent: visit['fill'] as double,
              fillColor: visit['color'] as Color,
              compact: compact,
            ),
            const SizedBox(height: 8),
            Icon(
              visit['trend'] == 'up'
                  ? Iconsax.arrow_up_3
                  : visit['trend'] == 'down'
                  ? Iconsax.arrow_down_2
                  : Iconsax.minus,
              size: compact ? 16 : 18,
              color: visit['trend'] == 'up'
                  ? DesignTokens.confidenceHigh
                  : visit['trend'] == 'down'
                  ? DesignTokens.error
                  : DesignTokens.textTertiary,
            ),
          ],
        ),
      );
    }

    final visitsRow = compact
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(5, (i) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: i < 4 ? DesignTokens.spaceMd : 0,
                  ),
                  child: visitColumn(i),
                );
              }),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, visitColumn),
          );

    return Container(
      padding: EdgeInsets.all(compact ? 16 : 24),
      decoration: BoxDecoration(
        color: DesignTokens.cardBlack.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DesignTokens.clinicalTeal.withOpacity(0.3)),
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
                  Iconsax.health,
                  color: DesignTokens.clinicalTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recovery Trajectory',
                      style: DesignTokens.headingSmall.copyWith(
                        color: DesignTokens.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Last 5 Visits',
                      style: DesignTokens.labelSmall.copyWith(
                        color: DesignTokens.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 16 : 24),
          visitsRow,
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getTrajectoryData(String name) {
    if (name.contains('sarthak')) {
      return [
        {
          'fill': 0.4,
          'color': const Color(0xFFFFA726),
          'trend': 'up',
          'tooltip': 'Visit 1: Needs Attention',
        },
        {
          'fill': 0.6,
          'color': const Color(0xFFFFEB3B),
          'trend': 'up',
          'tooltip': 'Visit 2: Stabilizing',
        },
        {
          'fill': 0.65,
          'color': const Color(0xFFFFEB3B),
          'trend': 'up',
          'tooltip': 'Visit 3: Stabilizing',
        },
        {
          'fill': 0.8,
          'color': const Color(0xFF66BB6A),
          'trend': 'up',
          'tooltip': 'Visit 4: Improving',
        },
        {
          'fill': 0.95,
          'color': const Color(0xFF26A69A),
          'trend': 'up',
          'tooltip':
              'Jan 21: Recovered\n• Fever resolved\n• Breathlessness resolved\n• No new symptoms',
        },
      ];
    } else if (name.contains('harsh')) {
      return [
        {
          'fill': 0.6,
          'color': const Color(0xFFFFEB3B),
          'trend': 'up',
          'tooltip': 'Visit 1: Stabilizing',
        },
        {
          'fill': 0.8,
          'color': const Color(0xFF66BB6A),
          'trend': 'up',
          'tooltip': 'Visit 2: Improving',
        },
        {
          'fill': 0.4,
          'color': const Color(0xFFFFA726),
          'trend': 'down',
          'tooltip':
              'Jan 12: Needs Attention\n• New cough onset\n• Oxygen saturation dropped\n• Follow-up triggered',
        },
        {
          'fill': 0.6,
          'color': const Color(0xFFFFEB3B),
          'trend': 'up',
          'tooltip': 'Visit 4: Stabilizing',
        },
        {
          'fill': 0.8,
          'color': const Color(0xFF66BB6A),
          'trend': 'up',
          'tooltip': 'Visit 5: Improving',
        },
      ];
    }
    // Default trajectory
    return [
      {
        'fill': 0.25,
        'color': const Color(0xFFEF5350),
        'trend': 'stable',
        'tooltip': 'Visit 1: Critical',
      },
      {
        'fill': 0.4,
        'color': const Color(0xFFFFA726),
        'trend': 'up',
        'tooltip': 'Visit 2: Needs Attention',
      },
      {
        'fill': 0.55,
        'color': const Color(0xFFFFEB3B),
        'trend': 'up',
        'tooltip': 'Visit 3: Stabilizing',
      },
      {
        'fill': 0.7,
        'color': const Color(0xFF66BB6A),
        'trend': 'up',
        'tooltip': 'Visit 4: Improving',
      },
      {
        'fill': 0.85,
        'color': const Color(0xFF66BB6A),
        'trend': 'up',
        'tooltip': 'Visit 5: Improving',
      },
    ];
  }

  // MINIMIZED: First Visit Date + Analysis Count - small corner section
  Widget _buildMinimalStats({required bool compact}) {
    return Consumer<AnalysisProvider>(
      builder: (context, analysisProvider, child) {
        final totalAnalyses = analysisProvider.patientAnalyses.length;
        final since = DateFormat('MMM yyyy').format(_patient!.createdAt);

        final analysesStyle = DesignTokens.bodyLarge.copyWith(
          color: DesignTokens.confidenceHigh.withValues(alpha: 0.7),
        );

        Widget analysesLine() {
          return Row(
            children: [
              Icon(
                Iconsax.document_text,
                color: DesignTokens.textSecondary,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '$totalAnalyses analyses',
                  style: analysesStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }

        Widget sinceLine() {
          return Row(
            children: [
              Icon(Iconsax.calendar, color: DesignTokens.textSecondary, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Since $since',
                  style: analysesStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              analysesLine(),
              const SizedBox(height: DesignTokens.spaceSm),
              sinceLine(),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: analysesLine()),
            const SizedBox(width: 12),
            Expanded(child: sinceLine()),
          ],
        );
      },
    );
  }

  // HERO: New Analysis Button - Glassmorphic with animated border
  Widget _buildHeroNewAnalysisButton({required bool compact}) {
    final titleStyle = (compact
            ? DesignTokens.headingSmall
            : DesignTokens.headingMedium)
        .copyWith(
      color: Colors.white.withOpacity(0.95),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );

    final inner = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 24,
        vertical: compact ? 14 : 18,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.medicalBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Iconsax.add,
                        color: Colors.white.withOpacity(0.9),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'New Analysis',
                        style: titleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Iconsax.add,
                    color: Colors.white.withOpacity(0.9),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Text('New Analysis', style: titleStyle),
              ],
            ),
    );

    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, child) {
        return GestureDetector(
          onTap: _handleNewAnalysis,
          child: Container(
            alignment: Alignment.centerLeft,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: CustomPaint(
              painter: _GlowBorderPainter(
                progress: _borderController.value,
                borderRadius: 20,
                glowColor: DesignTokens.textSecondary,
              ),
              child: inner,
            ),
          ),
        );
      },
    );
  }

  // ENHANCED: Last Visit Card
  Widget _buildEnhancedLastVisitCard({required bool compact}) {
    return Consumer<AnalysisProvider>(
      builder: (context, analysisProvider, child) {
        final analyses = analysisProvider.patientAnalyses;
        if (analyses.isEmpty) return const SizedBox.shrink();

        final lastVisit = analyses.first;
        final topDiag = lastVisit.topDiagnosis;

        Color statusColor;
        String statusText;
        IconData statusIcon;

        if (topDiag == null) {
          statusColor = DesignTokens.textTertiary;
          statusText = 'Pending';
          statusIcon = Iconsax.clock;
        } else if (topDiag.confidenceLevel == 'high') {
          statusColor = DesignTokens.confidenceHigh;
          statusText = 'Normal';
          statusIcon = Iconsax.tick_circle;
        } else if (topDiag.confidenceLevel == 'medium') {
          statusColor = DesignTokens.confidenceMed;
          statusText = 'Review';
          statusIcon = Iconsax.info_circle;
        } else {
          statusColor = DesignTokens.confidenceLow;
          statusText = 'Attention';
          statusIcon = Iconsax.warning_2;
        }

        return GestureDetector(
          onTap: () => _handleAnalysisClick(lastVisit),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DesignTokens.spaceLg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      DesignTokens.cardBlack.withOpacity(0.85),
                      DesignTokens.cardBlack.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withOpacity(
                      0.35 + _pulseController.value * 0.1,
                    ),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.12),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: DesignTokens.clinicalTeal.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Iconsax.calendar_1,
                            color: DesignTokens.clinicalTeal,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Last Visit',
                            style: DesignTokens.headingSmall.copyWith(
                              color: DesignTokens.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, color: statusColor, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                statusText,
                                style: DesignTokens.labelSmall.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.spaceLg),
                    Text(
                      DateFormat(
                        'EEEE, MMMM d, yyyy',
                      ).format(lastVisit.createdAt),
                      style: (compact
                              ? DesignTokens.headingSmall
                              : DesignTokens.headingMedium)
                          .copyWith(
                        color: DesignTokens.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: compact ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: DesignTokens.spaceSm),
                    if (topDiag != null)
                      Text(
                        _capitalizeWords(topDiag.diagnosisName),
                        style: DesignTokens.bodyLarge.copyWith(
                          color: DesignTokens.textSecondary,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: DesignTokens.spaceMd),
                    Row(
                      children: [
                        Text(
                          'View Details',
                          style: DesignTokens.labelMedium.copyWith(
                            color: DesignTokens.clinicalTeal,
                            fontWeight: FontWeight.w500,
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
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildClinicalFocus({required bool compact}) {
    return Consumer<AnalysisProvider>(
      builder: (context, analysisProvider, child) {
        final analyses = analysisProvider.patientAnalyses;

        if (analysisProvider.isLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLoader(
                width: 160,
                height: 28,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: DesignTokens.spaceLg),
              SkeletonLoader(
                width: 300,
                height: 48,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          );
        }

        if (analyses.isEmpty) {
          return _buildEmptyState();
        }

        final latest = analyses.first;
        final topDiag = latest.topDiagnosis;

        String status;
        Color statusColor;
        IconData statusIcon;

        if (topDiag == null) {
          status = 'Pending Review';
          statusColor = DesignTokens.textTertiary;
          statusIcon = Iconsax.clock;
        } else if (topDiag.confidenceLevel == 'high') {
          status = 'Clear';
          statusColor = DesignTokens.confidenceHigh;
          statusIcon = Iconsax.tick_circle;
        } else if (topDiag.confidenceLevel == 'medium') {
          status = 'Review Suggested';
          statusColor = DesignTokens.confidenceMed;
          statusIcon = Iconsax.info_circle;
        } else {
          status = 'Needs Attention';
          statusColor = DesignTokens.confidenceLow;
          statusIcon = Iconsax.warning_2;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.health,
                  color: DesignTokens.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Needs Attention',
                  style: DesignTokens.headingSmall.copyWith(
                    color: DesignTokens.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceLg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        statusColor.withOpacity(0.15),
                        statusColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withOpacity(
                        0.3 + _pulseController.value * 0.1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              statusIcon,
                              color: statusColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spaceMd),
                          Expanded(
                            child: Text(
                              status,
                              style: (compact
                                      ? DesignTokens.headingSmall
                                      : DesignTokens.headingMedium)
                                  .copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (topDiag != null) ...[
                        const SizedBox(height: DesignTokens.spaceLg),
                        Text(
                          _capitalizeWords(topDiag.diagnosisName),
                          style: DesignTokens.headingSmall.copyWith(
                            color: DesignTokens.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: DesignTokens.spaceMd),
                        _buildConfidenceBar(topDiag, statusColor),
                      ],
                      const SizedBox(height: DesignTokens.spaceLg),
                      GestureDetector(
                        onTap: () => _handleAnalysisClick(latest),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: DesignTokens.clinicalTeal.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: DesignTokens.clinicalTeal.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Full Analysis',
                                style: DesignTokens.labelLarge.copyWith(
                                  color: DesignTokens.clinicalTeal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Iconsax.arrow_right_3,
                                color: DesignTokens.clinicalTeal,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(DesignTokens.spaceXl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DesignTokens.cardBlack.withOpacity(0.7),
                DesignTokens.cardBlack.withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: DesignTokens.borderGray.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignTokens.medicalBlue.withOpacity(0.1),
                ),
                child: Icon(
                  Iconsax.document_text,
                  color: DesignTokens.medicalBlue,
                  size: 36,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceLg),
              Text(
                'No Clinical Data Yet',
                style: DesignTokens.headingMedium.copyWith(
                  color: DesignTokens.textPrimary,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceSm),
              Text(
                'Create An Analysis To Get Started',
                style: DesignTokens.bodyLarge.copyWith(
                  color: DesignTokens.textTertiary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfidenceBar(Diagnosis diagnosis, Color color) {
    final percent = diagnosis.confidencePercentage;
    return Row(
      children: [
        Text(
          '$percent%',
          style: DesignTokens.headingSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: DesignTokens.spaceMd),
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: DesignTokens.surfaceBlack,
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: diagnosis.confidence,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: DesignTokens.spaceMd),
        Flexible(
          child: Text(
            diagnosis.confidenceLevel.toUpperCase(),
            style: DesignTokens.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildWhatChanged({required bool compact}) {
    return Consumer<AnalysisProvider>(
      builder: (context, analysisProvider, child) {
        if (analysisProvider.isLoading) {
          return _buildChangedSkeleton();
        }

        final analyses = analysisProvider.patientAnalyses;
        if (analyses.length < 2) {
          return const SizedBox.shrink();
        }

        final current = analyses.first;
        final previous = analyses[1];
        final changes = _computeChanges(current, previous);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            compact ? DesignTokens.spaceMd : DesignTokens.spaceLg,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DesignTokens.medicalBlue.withOpacity(0.08),
                DesignTokens.clinicalTeal.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: DesignTokens.clinicalTeal.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: DesignTokens.clinicalTeal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Iconsax.refresh_2,
                      color: DesignTokens.clinicalTeal,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceMd),
                  Expanded(
                    child: Text(
                      'What Changed Since Last Visit',
                      style: DesignTokens.headingSmall.copyWith(
                        color: DesignTokens.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spaceLg),
              if (changes.isEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Iconsax.tick_circle,
                      color: DesignTokens.confidenceHigh,
                      size: 20,
                    ),
                    const SizedBox(width: DesignTokens.spaceSm),
                    Expanded(
                      child: Text(
                        'No significant changes since last visit',
                        style: DesignTokens.bodyLarge.copyWith(
                          color: DesignTokens.textSecondary,
                        ),
                      ),
                    ),
                  ],
                )
              else
                ...changes.take(4).map((c) => _buildChangeItem(c)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChangedSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: DesignTokens.cardBlack.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DesignTokens.borderGray.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoader(
                width: 44,
                height: 44,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: DesignTokens.spaceMd),
              SkeletonLoader(
                width: 220,
                height: 24,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceLg),
          SkeletonLoader(
            width: double.infinity,
            height: 36,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _computeChanges(
    Analysis current,
    Analysis previous,
  ) {
    final changes = <Map<String, dynamic>>[];

    final currLevel = current.topDiagnosis?.confidenceLevel ?? '';
    final prevLevel = previous.topDiagnosis?.confidenceLevel ?? '';
    if (currLevel != prevLevel && currLevel.isNotEmpty) {
      final improved = _levelRank(currLevel) > _levelRank(prevLevel);
      changes.add({
        'text': 'Risk level changed to ${currLevel.toLowerCase()}',
        'type': improved ? 'positive' : 'negative',
        'icon': improved ? Iconsax.shield_tick : Iconsax.warning_2,
      });
    }

    final currConf = current.topDiagnosis?.confidencePercentage ?? 0;
    final prevConf = previous.topDiagnosis?.confidencePercentage ?? 0;
    final confDiff = currConf - prevConf;
    if (confDiff.abs() >= 5) {
      changes.add({
        'text':
            'Diagnostic confidence ${confDiff > 0 ? "increased" : "decreased"} ${confDiff.abs()}%',
        'type': confDiff > 0 ? 'positive' : 'negative',
        'icon': confDiff > 0 ? Iconsax.arrow_up_2 : Iconsax.arrow_down_2,
      });
    }

    final currSymptoms = current.summary.associatedSymptoms.toSet();
    final prevSymptoms = previous.summary.associatedSymptoms.toSet();
    final newSymptoms = currSymptoms.difference(prevSymptoms);
    final resolved = prevSymptoms.difference(currSymptoms);
    if (newSymptoms.isNotEmpty) {
      final sample = newSymptoms.first.length > 25
          ? '${newSymptoms.first.substring(0, 25)}...'
          : newSymptoms.first;
      changes.add({
        'text': newSymptoms.length == 1
            ? '${_capitalize(sample)} (new)'
            : '${newSymptoms.length} new symptoms reported',
        'type': 'negative',
        'icon': Iconsax.add_circle,
      });
    }
    if (resolved.isNotEmpty) {
      changes.add({
        'text':
            '${resolved.length} symptom${resolved.length > 1 ? 's' : ''} resolved',
        'type': 'positive',
        'icon': Iconsax.tick_circle,
      });
    }

    return changes;
  }

  int _levelRank(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _buildChangeItem(Map<String, dynamic> change) {
    Color color;
    switch (change['type']) {
      case 'positive':
        color = DesignTokens.confidenceHigh;
        break;
      case 'negative':
        color = DesignTokens.confidenceMed;
        break;
      default:
        color = DesignTokens.textSecondary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spaceSm),
      child: Row(
        children: [
          Icon(change['icon'] as IconData, color: color, size: 18),
          const SizedBox(width: DesignTokens.spaceSm),
          Expanded(
            child: Text(
              change['text'] as String,
              style: DesignTokens.bodyMedium.copyWith(
                color: DesignTokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return Consumer<AnalysisProvider>(
      builder: (context, analysisProvider, child) {
        final analyses = analysisProvider.patientAnalyses;
        if (analyses.length <= 1) return const SizedBox.shrink();

        final history = analyses.skip(1).take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DesignTokens.spaceLg),
            Row(
              children: [
                Icon(
                  Iconsax.clock,
                  color: DesignTokens.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Previous Analyses',
                  style: DesignTokens.headingSmall.copyWith(
                    color: DesignTokens.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spaceMd),
            ...history.asMap().entries.map((entry) {
              final index = entry.key;
              final analysis = entry.value;
              return _buildTimelineItem(analysis, index);
            }),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms);
      },
    );
  }

  Widget _buildTimelineItem(Analysis analysis, int index) {
    final topDiag = analysis.topDiagnosis;
    final color = topDiag != null
        ? DesignTokens.getConfidenceColor(topDiag.confidenceLevel)
        : DesignTokens.textTertiary;

    return Padding(
          padding: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
          child: GestureDetector(
            onTap: () => _handleAnalysisClick(analysis),
            child: Container(
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DesignTokens.cardBlack.withOpacity(0.6),
                    DesignTokens.cardBlack.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: DesignTokens.borderGray.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMM d, yyyy').format(analysis.createdAt),
                          style: DesignTokens.bodyMedium.copyWith(
                            color: DesignTokens.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (topDiag != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _capitalizeWords(topDiag.diagnosisName),
                            style: DesignTokens.bodySmall.copyWith(
                              color: DesignTokens.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (topDiag != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${topDiag.confidencePercentage}%',
                        style: DesignTokens.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: DesignTokens.spaceSm),
                  Icon(
                    Iconsax.arrow_right_3,
                    color: DesignTokens.textTertiary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: (80 * index).ms)
        .slideX(begin: 0.03, end: 0);
  }
}

// Animated border painter for glassmorphic button with tracking glow
class _GlowBorderPainter extends CustomPainter {
  final double progress;
  final double borderRadius;
  final Color glowColor;

  _GlowBorderPainter({
    required this.progress,
    required this.borderRadius,
    this.glowColor = const Color(0xFF14B8A6),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics().toList();

    // Base border
    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, basePaint);

    // Glowing segment that travels around
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
  bool shouldRepaint(covariant _GlowBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowColor != glowColor;
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: DesignTokens.spaceXl),
          SkeletonLoader(
            width: 100,
            height: 100,
            borderRadius: BorderRadius.circular(50),
          ),
          const SizedBox(height: DesignTokens.spaceLg),
          SkeletonLoader(
            width: 280,
            height: 40,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(height: DesignTokens.spaceMd),
          SkeletonLoader(
            width: 150,
            height: 24,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: DesignTokens.spaceXl),
          SkeletonLoader(
            width: double.infinity,
            height: 60,
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
    );
  }
}

class _HumanSilhouette extends StatefulWidget {
  final double fillPercent;
  final Color fillColor;
  final bool compact;

  const _HumanSilhouette({
    required this.fillPercent,
    required this.fillColor,
    this.compact = false,
  });

  @override
  State<_HumanSilhouette> createState() => _HumanSilhouetteState();
}

class _HumanSilhouetteState extends State<_HumanSilhouette>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final sz = widget.compact ? const Size(44, 78) : const Size(56, 100);
        return CustomPaint(
          size: sz,
          painter: _HumanPainter(
            fillPercent: widget.fillPercent,
            fillColor: widget.fillColor,
            wavePhase: _waveController.value * 2 * 3.14159,
          ),
        );
      },
    );
  }
}

class _HumanPainter extends CustomPainter {
  final double fillPercent;
  final Color fillColor;
  final double wavePhase;

  _HumanPainter({
    required this.fillPercent,
    required this.fillColor,
    required this.wavePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Human silhouette path
    final path = Path();
    // Head
    path.addOval(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.1),
        width: w * 0.38,
        height: w * 0.38,
      ),
    );
    // Body
    path.moveTo(w * 0.3, h * 0.22);
    path.lineTo(w * 0.18, h * 0.55);
    path.lineTo(w * 0.28, h * 0.55);
    path.lineTo(w * 0.35, h * 0.95);
    path.lineTo(w * 0.45, h * 0.95);
    path.lineTo(w * 0.5, h * 0.55);
    path.lineTo(w * 0.55, h * 0.95);
    path.lineTo(w * 0.65, h * 0.95);
    path.lineTo(w * 0.72, h * 0.55);
    path.lineTo(w * 0.82, h * 0.55);
    path.lineTo(w * 0.7, h * 0.22);
    path.close();

    // Draw outline
    final outlinePaint = Paint()
      ..color = DesignTokens.borderGray.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, outlinePaint);

    // Draw unfilled background
    final bgPaint = Paint()..color = DesignTokens.borderGray.withOpacity(0.15);
    canvas.drawPath(path, bgPaint);

    // Create wave clip path
    final fillY = h * (1 - fillPercent);
    final wavePath = Path();
    wavePath.moveTo(0, fillY);
    for (double x = 0; x <= w; x += 2) {
      final y = fillY + math.sin((x / w * 2 * 3.14159) + wavePhase) * 3;
      wavePath.lineTo(x, y);
    }
    wavePath.lineTo(w, h);
    wavePath.lineTo(0, h);
    wavePath.close();

    // Clip and fill
    canvas.save();
    canvas.clipPath(path);
    canvas.clipPath(wavePath);
    final fillPaint = Paint()..color = fillColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), fillPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HumanPainter old) =>
      old.fillPercent != fillPercent ||
      old.fillColor != fillColor ||
      old.wavePhase != wavePhase;
}
