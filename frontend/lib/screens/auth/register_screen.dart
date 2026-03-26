import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_tokens.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/buttons/clinical_button.dart';
import '../../widgets/inputs/clinical_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _specialtyController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  String? _fullNameError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _fullNameError = null;
    });

    // Validate
    if (_fullNameController.text.isEmpty) {
      setState(() => _fullNameError = 'Full name is required');
      return;
    }

    if (_emailController.text.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return;
    }

    if (!_emailController.text.contains('@')) {
      setState(() => _emailError = 'Invalid email format');
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      specialty: _specialtyController.text.trim().isEmpty
          ? null
          : _specialtyController.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Registration failed',
            style: DesignTokens.bodyMedium,
          ),
          backgroundColor: DesignTokens.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: DesignTokens.voidBlack,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.spaceLg),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo/Brand
                ShaderMask(
                  shaderCallback: (bounds) => DesignTokens.medicalGradient
                      .createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  child: Text(
                    'Clinical AI',
                    textAlign: TextAlign.center,
                    style: DesignTokens.displayMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceSm),
                Text(
                  'Create your account',
                  textAlign: TextAlign.center,
                  style: DesignTokens.bodyLarge.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXxl),

                // Register form
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceXl),
                  decoration: BoxDecoration(
                    color: DesignTokens.cardBlack,
                    borderRadius: DesignTokens.radiusLg,
                    border: Border.all(
                      color: DesignTokens.borderGray,
                      width: 1,
                    ),
                    boxShadow: DesignTokens.depth3,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClinicalInput(
                          label: 'Full Name',
                          hint: 'Dr. John Smith',
                          controller: _fullNameController,
                          prefixIcon: Icons.person_outlined,
                          errorText: _fullNameError,
                          autofocus: true,
                        ),
                        const SizedBox(height: DesignTokens.spaceLg),
                        ClinicalInput(
                          label: 'Email',
                          hint: 'your.email@hospital.com',
                          controller: _emailController,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          errorText: _emailError,
                        ),
                        const SizedBox(height: DesignTokens.spaceLg),
                        ClinicalInput(
                          label: 'Password',
                          hint: 'At least 6 characters',
                          controller: _passwordController,
                          prefixIcon: Icons.lock_outlined,
                          suffixIcon: _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          onSuffixIconTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          obscureText: _obscurePassword,
                          errorText: _passwordError,
                        ),
                        const SizedBox(height: DesignTokens.spaceLg),
                        ClinicalInput(
                          label: 'Specialty (Optional)',
                          hint: 'e.g., Cardiology, Internal Medicine',
                          controller: _specialtyController,
                          prefixIcon: Icons.medical_services_outlined,
                        ),
                        const SizedBox(height: DesignTokens.spaceXl),
                        ClinicalButton.primary(
                          label: 'Create Account',
                          onPressed:
                              authProvider.isLoading ? null : _handleRegister,
                          isLoading: authProvider.isLoading,
                          fullWidth: true,
                          size: ClinicalButtonSize.large,
                        ),
                        const SizedBox(height: DesignTokens.spaceMd),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: DesignTokens.bodyMedium.copyWith(
                                color: DesignTokens.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushReplacementNamed('/login');
                              },
                              child: Text(
                                'Sign In',
                                style: DesignTokens.labelLarge.copyWith(
                                  color: DesignTokens.clinicalTeal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
