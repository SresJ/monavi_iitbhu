import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/design_tokens.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/buttons/clinical_button.dart';
import '../../widgets/inputs/clinical_input.dart';
import '../../widgets/effects/hover_scale_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validate
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

    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Login failed',
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
                  shaderCallback: (bounds) =>
                      DesignTokens.medicalGradient.createShader(
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
                  'Sign in to continue',
                  textAlign: TextAlign.center,
                  style: DesignTokens.bodyLarge.copyWith(
                    color: DesignTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXxl),

                // Login form with glassmorphism
                GlassMorphismCard(
                      borderColor: DesignTokens.medicalBlue.withOpacity(0.3),
                      padding: const EdgeInsets.all(DesignTokens.spaceXl),
                      boxShadow: [
                        BoxShadow(
                          color: DesignTokens.medicalBlue.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 3,
                        ),
                      ],
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClinicalInput(
                              label: 'Email',
                              hint: 'Enter your email',
                              controller: _emailController,
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              errorText: _emailError,
                              autofocus: true,
                            ),
                            const SizedBox(height: DesignTokens.spaceLg),
                            ClinicalInput(
                              label: 'Password',
                              hint: 'Enter your password',
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
                            const SizedBox(height: DesignTokens.spaceXl),
                            ClinicalButton.primary(
                              label: 'Sign In',
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _handleLogin,
                              isLoading: authProvider.isLoading,
                              fullWidth: true,
                              size: ClinicalButtonSize.large,
                            ),
                            const SizedBox(height: DesignTokens.spaceMd),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: DesignTokens.bodyMedium.copyWith(
                                    color: DesignTokens.textSecondary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pushReplacementNamed('/register');
                                  },
                                  child: Text(
                                    'Register',
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
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms)
                    .scale(begin: const Offset(0.95, 0.95)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
