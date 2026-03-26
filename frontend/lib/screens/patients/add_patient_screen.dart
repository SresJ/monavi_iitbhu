import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/patient_provider.dart';
import '../../config/design_tokens.dart';
import '../../widgets/buttons/clinical_button.dart';
import '../../widgets/inputs/clinical_input.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _mrnController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedSex = 'male';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _mrnController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final patientProvider = Provider.of<PatientProvider>(context, listen: false);

    final patient = await patientProvider.createPatient(
      fullName: _fullNameController.text.trim(),
      age: _ageController.text.isNotEmpty ? int.tryParse(_ageController.text) : null,
      sex: _selectedSex,
      mrn: _mrnController.text.trim().isNotEmpty ? _mrnController.text.trim() : null,
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
    );

    setState(() => _isSubmitting = false);

    if (patient != null && mounted) {
      Navigator.of(context).pop(patient);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient created successfully'),
          backgroundColor: DesignTokens.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(patientProvider.errorMessage ?? 'Failed to create patient'),
          backgroundColor: DesignTokens.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: DesignTokens.voidBlack,
      appBar: AppBar(
        backgroundColor: DesignTokens.surfaceBlack,
        title: Text('Add New Patient', style: DesignTokens.headingSmall),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          DesignTokens.spaceLg,
          DesignTokens.spaceLg,
          DesignTokens.spaceLg,
          DesignTokens.spaceLg + bottomInset,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient Information', style: DesignTokens.headingMedium),
              const SizedBox(height: DesignTokens.spaceXs),
              Text(
                'Enter patient details to create a new record',
                style: DesignTokens.bodyMedium.copyWith(color: DesignTokens.textSecondary),
              ),
              const SizedBox(height: DesignTokens.spaceXl),
              _buildBasicInfoSection(),
              const SizedBox(height: DesignTokens.spaceXl),
              _buildContactSection(),
              const SizedBox(height: DesignTokens.spaceXl),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: DesignTokens.cardBlack,
        borderRadius: DesignTokens.radiusLg,
        border: Border.all(color: DesignTokens.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Basic Information', style: DesignTokens.labelLarge),
          const SizedBox(height: DesignTokens.spaceMd),

          // Full Name
          ClinicalInput(
            controller: _fullNameController,
            label: 'Full Name',
            hint: 'Enter patient full name',
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Full name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: DesignTokens.spaceMd),

          // Age
          ClinicalInput(
            controller: _ageController,
            label: 'Age',
            hint: 'Enter age',
            prefixIcon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final age = int.tryParse(value);
                if (age == null || age < 0 || age > 150) {
                  return 'Enter a valid age';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: DesignTokens.spaceMd),

          // Sex Selection
          Text('Sex', style: DesignTokens.labelLarge),
          const SizedBox(height: DesignTokens.spaceXs),
          Row(
            children: [
              Expanded(
                child: _buildSexOption('male', 'Male', Icons.male),
              ),
              const SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                child: _buildSexOption('female', 'Female', Icons.female),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceMd),

          // Medical Record Number
          ClinicalInput(
            controller: _mrnController,
            label: 'Medical Record Number (Optional)',
            hint: 'Enter MRN',
            prefixIcon: Icons.badge_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSexOption(String value, String label, IconData icon) {
    final isSelected = _selectedSex == value;
    return InkWell(
      onTap: () => setState(() => _selectedSex = value),
      borderRadius: DesignTokens.radiusMd,
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spaceMd),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignTokens.medicalBlue.withOpacity(0.2)
              : DesignTokens.surfaceBlack,
          borderRadius: DesignTokens.radiusMd,
          border: Border.all(
            color: isSelected ? DesignTokens.medicalBlue : DesignTokens.borderGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? DesignTokens.medicalBlue : DesignTokens.textSecondary,
            ),
            const SizedBox(width: DesignTokens.spaceXs),
            Text(
              label,
              style: DesignTokens.labelLarge.copyWith(
                color: isSelected ? DesignTokens.medicalBlue : DesignTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: DesignTokens.cardBlack,
        borderRadius: DesignTokens.radiusLg,
        border: Border.all(color: DesignTokens.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Information', style: DesignTokens.labelLarge),
          const SizedBox(height: DesignTokens.spaceMd),

          // Email
          ClinicalInput(
            controller: _emailController,
            label: 'Email (Optional)',
            hint: 'patient@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Enter a valid email';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: DesignTokens.spaceMd),

          // Phone
          ClinicalInput(
            controller: _phoneController,
            label: 'Phone (Optional)',
            hint: '+1 (555) 123-4567',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceMd),
              side: BorderSide(color: DesignTokens.borderGray),
              shape: RoundedRectangleBorder(borderRadius: DesignTokens.radiusMd),
            ),
            child: Text(
              'Cancel',
              style: DesignTokens.labelLarge.copyWith(color: DesignTokens.textSecondary),
            ),
          ),
        ),
        const SizedBox(width: DesignTokens.spaceMd),
        Expanded(
          flex: 2,
          child: ClinicalButton(
            label: _isSubmitting ? 'Creating...' : 'Create Patient',
            onPressed: _isSubmitting ? null : _handleSubmit,
            isLoading: _isSubmitting,
            fullWidth: true,
          ),
        ),
      ],
    );
  }
}
