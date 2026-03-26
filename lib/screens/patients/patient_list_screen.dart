import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'dart:math' as math;
import '../../config/design_tokens.dart';
import '../../providers/patient_provider.dart';
import '../../widgets/inputs/clinical_input.dart';
import '../../widgets/buttons/clinical_button.dart';
import '../../widgets/loading/skeleton_loader.dart';

/// PATIENT LIST SCREEN - PREMIUM PEOPLE GALLERY
///
/// Features:
/// - No back button (bottom navigation handles this)
/// - Fancy Iconsax icons
/// - Profile images for avatars
/// - Capitalized text
/// - Interactive animations
/// - Animated background
class PatientListScreen extends StatefulWidget {
  const PatientListScreen({Key? key}) : super(key: key);

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  late AnimationController _orbitController;
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  bool _isSearchFocused = false;

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

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPatients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _orbitController.dispose();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    final provider = context.read<PatientProvider>();
    await provider.fetchPatients();
  }

  Future<void> _showAddPatientDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const _AddPatientDialog(),
    );
  }

  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientProvider>();

    return Scaffold(
      backgroundColor: DesignTokens.voidBlack,
      body: Stack(
        children: [
          // Animated background orbs
          _buildAnimatedBackground(),

          // Floating particles
          _buildFloatingParticles(),

          // Content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadPatients,
              color: DesignTokens.clinicalTeal,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header - NO back button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceLg,
                        vertical: DesignTokens.spaceMd,
                      ),
                      child: _buildHeader(),
                    ),
                  ),

                  // Search
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceLg,
                      ),
                      child: _buildSearch(provider),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: DesignTokens.spaceLg),
                  ),

                  // Patient count badge
                  if (!provider.isLoading && provider.patients.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spaceLg,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: DesignTokens.medicalBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: DesignTokens.medicalBlue.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Iconsax.people,
                                    color: DesignTokens.medicalBlue,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${provider.patients.length} ${provider.patients.length == 1 ? 'Person' : 'People'}',
                                    style: DesignTokens.labelMedium.copyWith(
                                      color: DesignTokens.medicalBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: DesignTokens.spaceMd),
                  ),

                  // Patient list or states
                  if (provider.isLoading && provider.patients.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spaceLg,
                        ),
                        child: _buildLoadingSkeleton(),
                      ),
                    )
                  else if (provider.patients.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spaceLg,
                        ),
                        child: _buildEmptyState(),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceLg,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final patient = provider.patients[index];
                            return _buildPersonTile(patient, index);
                          },
                          childCount: provider.patients.length,
                        ),
                      ),
                    ),

                  // Bottom spacing (FAB + nav bar + home indicator)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 120 + MediaQuery.paddingOf(context).bottom,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAddButton(),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _orbitController,
      builder: (context, child) {
        return Stack(
          children: [
            // Blue orb - top left
            Positioned(
              left: -100 + math.sin(_orbitController.value * 2 * math.pi) * 40,
              top: 50 + math.cos(_orbitController.value * 2 * math.pi) * 40,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      DesignTokens.medicalBlue.withOpacity(0.2),
                      DesignTokens.medicalBlue.withOpacity(0.08),
                      DesignTokens.medicalBlue.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Teal orb - right
            Positioned(
              right: -120 +
                  math.cos(_orbitController.value * 2 * math.pi + 1.2) * 50,
              top: 300 +
                  math.sin(_orbitController.value * 2 * math.pi + 1.2) * 50,
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
            // Purple accent
            Positioned(
              left: MediaQuery.of(context).size.width / 2 +
                  math.sin(_orbitController.value * 2 * math.pi + 2) * 30,
              bottom: 100 +
                  math.cos(_orbitController.value * 2 * math.pi + 2) * 30,
              child: Container(
                width: 180,
                height: 180,
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

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          children: List.generate(6, (index) {
            final x = (index % 3) * 130.0 + 50;
            final y = (index ~/ 3) * 350.0 + 150 +
                math.sin((_pulseController.value + index * 0.15) * 2 * math.pi) * 15;

            return Positioned(
              left: x,
              top: y,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignTokens.clinicalTeal.withOpacity(0.25),
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.clinicalTeal.withOpacity(0.15),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: DesignTokens.medicalGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.medicalBlue.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Iconsax.people,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceMd),
            Expanded(
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    DesignTokens.medicalGradient.createShader(bounds),
                child: Text(
                  'Patients',
                  style: DesignTokens.headingLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.spaceSm),
        Text(
          'Manage Your Patient Records',
          style: DesignTokens.bodyLarge.copyWith(
            color: DesignTokens.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildSearch(PatientProvider provider) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
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
              color: _isSearchFocused
                  ? DesignTokens.clinicalTeal.withOpacity(0.5)
                  : DesignTokens.borderGray.withOpacity(0.3),
              width: _isSearchFocused ? 2 : 1,
            ),
            boxShadow: _isSearchFocused
                ? [
                    BoxShadow(
                      color: DesignTokens.clinicalTeal.withOpacity(0.15),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Focus(
            onFocusChange: (focused) {
              setState(() => _isSearchFocused = focused);
            },
            child: TextField(
              controller: _searchController,
              style: DesignTokens.bodyMedium.copyWith(
                color: DesignTokens.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search By Name...',
                hintStyle: DesignTokens.bodyMedium.copyWith(
                  color: DesignTokens.textTertiary,
                ),
                prefixIcon: Icon(
                  Iconsax.search_normal,
                  color: _isSearchFocused
                      ? DesignTokens.clinicalTeal
                      : DesignTokens.textTertiary,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceMd,
                  vertical: DesignTokens.spaceMd,
                ),
              ),
              onChanged: (value) {
                provider.searchPatients(value);
              },
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms);
  }

  Widget _buildPersonTile(patient, int index) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/patients/${patient.patientId}');
            },
            child: Container(
              padding: const EdgeInsets.all(DesignTokens.spaceMd),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DesignTokens.cardBlack.withOpacity(0.7),
                    DesignTokens.cardBlack.withOpacity(0.35),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: DesignTokens.borderGray.withOpacity(0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.medicalBlue.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar with profile image
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DesignTokens.clinicalTeal.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: DesignTokens.medicalBlue.withOpacity(
                              0.15 + _pulseController.value * 0.08),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        patient.avatarPath,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: DesignTokens.medicalGradient,
                            ),
                            child: Center(
                              child: Text(
                                patient.initials,
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

                  // Person info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name - PRIMARY (capitalized)
                        Text(
                          patient.displayName,
                          style: DesignTokens.bodyLarge.copyWith(
                            color: DesignTokens.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // Age/Sex - secondary (capitalized)
                        if (patient.ageSexDisplay.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Iconsax.user,
                                color: DesignTokens.textTertiary,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  patient.ageSexDisplay,
                                  style: DesignTokens.bodySmall.copyWith(
                                    color: DesignTokens.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Arrow with container
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: DesignTokens.clinicalTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Iconsax.arrow_right_3,
                      color: DesignTokens.clinicalTeal,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: (80 * index).ms).slideX(
              begin: 0.05,
              end: 0,
              curve: Curves.easeOut,
            );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: DesignTokens.spaceXxxl,
        horizontal: DesignTokens.spaceLg,
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      DesignTokens.medicalBlue.withOpacity(0.25),
                      DesignTokens.clinicalTeal.withOpacity(0.25),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.medicalBlue.withOpacity(
                          0.15 + _pulseController.value * 0.1),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Iconsax.people,
                  size: 48,
                  color: DesignTokens.clinicalTeal,
                ),
              );
            },
          ),
          const SizedBox(height: DesignTokens.spaceXl),
          Text(
            'No Patients Yet',
            style: DesignTokens.headingMedium.copyWith(
              color: DesignTokens.textPrimary,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceSm),
          Text(
            'Add Your First Patient To Begin',
            style: DesignTokens.bodyLarge.copyWith(
              color: DesignTokens.textTertiary,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXl),
          GestureDetector(
            onTap: _showAddPatientDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceLg,
                vertical: DesignTokens.spaceMd,
              ),
              decoration: BoxDecoration(
                gradient: DesignTokens.medicalGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.medicalBlue.withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.user_add,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Add Patient',
                    style: DesignTokens.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: DesignTokens.spaceMd),
          child: SkeletonLoader(
            width: double.infinity,
            height: 96,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return GestureDetector(
          onTap: _showAddPatientDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceLg,
              vertical: DesignTokens.spaceMd,
            ),
            decoration: BoxDecoration(
              gradient: DesignTokens.medicalGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.medicalBlue.withOpacity(
                      0.35 + _pulseController.value * 0.15),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Iconsax.user_add,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'Add Patient',
                  style: DesignTokens.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Add Patient Dialog - Clean, minimal with fancy icons
class _AddPatientDialog extends StatefulWidget {
  const _AddPatientDialog({Key? key}) : super(key: key);

  @override
  State<_AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<_AddPatientDialog> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _sexController = TextEditingController();
  final _mrnController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _sexController.dispose();
    _mrnController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Iconsax.warning_2, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'Name Is Required',
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
      return;
    }

    final provider = context.read<PatientProvider>();

    final patient = await provider.createPatient(
      fullName: _nameController.text.trim(),
      age: int.tryParse(_ageController.text),
      sex: _sexController.text.trim().isEmpty
          ? null
          : _sexController.text.trim(),
      mrn: _mrnController.text.trim().isEmpty
          ? null
          : _mrnController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    if (patient != null && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'Patient Added Successfully',
                style: DesignTokens.bodyMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: DesignTokens.confidenceHigh,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Iconsax.close_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                provider.errorMessage ?? 'Could Not Add Patient',
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientProvider>();

    return Dialog(
      backgroundColor: DesignTokens.cardBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: DesignTokens.borderGray.withOpacity(0.3),
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(DesignTokens.spaceXl),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: DesignTokens.medicalGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: DesignTokens.medicalBlue.withOpacity(0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Iconsax.user_add,
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
                          'Add New Patient',
                          style: DesignTokens.headingMedium.copyWith(
                            color: DesignTokens.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Enter Patient Information',
                          style: DesignTokens.bodySmall.copyWith(
                            color: DesignTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Iconsax.close_circle,
                      color: DesignTokens.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spaceXl),

              // Form
              _buildInputField(
                label: 'Full Name',
                controller: _nameController,
                hint: 'John Doe',
                icon: Iconsax.user,
                autofocus: true,
              ),
              const SizedBox(height: DesignTokens.spaceMd),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: 'Age',
                      controller: _ageController,
                      hint: '45',
                      icon: Iconsax.calendar,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceMd),
                  Expanded(
                    child: _buildInputField(
                      label: 'Sex',
                      controller: _sexController,
                      hint: 'Male/Female',
                      icon: Iconsax.user,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spaceMd),
              _buildInputField(
                label: 'MRN (Optional)',
                controller: _mrnController,
                hint: 'Medical Record Number',
                icon: Iconsax.document,
              ),
              const SizedBox(height: DesignTokens.spaceMd),
              _buildInputField(
                label: 'Email (Optional)',
                controller: _emailController,
                hint: 'patient@email.com',
                icon: Iconsax.sms,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: DesignTokens.spaceMd),
              _buildInputField(
                label: 'Phone (Optional)',
                controller: _phoneController,
                hint: '+1-555-0123',
                icon: Iconsax.call,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: DesignTokens.spaceXl),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: DesignTokens.labelLarge.copyWith(
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceMd),
                  GestureDetector(
                    onTap: provider.isLoading ? null : _handleCreate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceLg,
                        vertical: DesignTokens.spaceSm,
                      ),
                      decoration: BoxDecoration(
                        gradient: DesignTokens.medicalGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: DesignTokens.medicalBlue.withOpacity(0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Iconsax.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Add Patient',
                                  style: DesignTokens.labelLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool autofocus = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DesignTokens.labelMedium.copyWith(
            color: DesignTokens.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: DesignTokens.surfaceBlack,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: DesignTokens.borderGray.withOpacity(0.3),
            ),
          ),
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            keyboardType: keyboardType,
            style: DesignTokens.bodyMedium.copyWith(
              color: DesignTokens.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: DesignTokens.bodyMedium.copyWith(
                color: DesignTokens.textTertiary,
              ),
              prefixIcon: Icon(
                icon,
                color: DesignTokens.textTertiary,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceMd,
                vertical: DesignTokens.spaceMd,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
