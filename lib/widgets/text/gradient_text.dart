import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/design_tokens.dart';

/// Gradient text widget - matches landing page hero text
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient? gradient;
  final int? animationDelay;

  const GradientText({
    Key? key,
    required this.text,
    this.style,
    this.gradient,
    this.animationDelay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textWidget = ShaderMask(
      shaderCallback: (bounds) => (gradient ?? DesignTokens.medicalGradient)
          .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: (style ?? DesignTokens.displayMedium).copyWith(
          color: Colors.white,
        ),
      ),
    );

    if (animationDelay != null) {
      return textWidget
          .animate()
          .fadeIn(duration: 800.ms, delay: animationDelay!.ms)
          .slideX(begin: -0.1, end: 0);
    }

    return textWidget;
  }
}
