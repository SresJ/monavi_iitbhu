import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../config/design_tokens.dart';

/// Reusable animated orb background - matches landing page
class AnimatedOrbBackground extends StatefulWidget {
  const AnimatedOrbBackground({super.key});

  @override
  State<AnimatedOrbBackground> createState() => _AnimatedOrbBackgroundState();
}

class _AnimatedOrbBackgroundState extends State<AnimatedOrbBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Large blue orb
            Positioned(
              left: -100 + math.sin(_controller.value * 2 * math.pi) * 50,
              top: 100 + math.cos(_controller.value * 2 * math.pi) * 50,
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
              right: -150 + math.cos(_controller.value * 2 * math.pi + 1) * 70,
              top: 200 + math.sin(_controller.value * 2 * math.pi + 1) * 70,
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
              left: MediaQuery.of(context).size.width / 2 +
                  math.sin(_controller.value * 2 * math.pi + 2) * 100,
              bottom: 100 + math.cos(_controller.value * 2 * math.pi + 2) * 100,
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
}
