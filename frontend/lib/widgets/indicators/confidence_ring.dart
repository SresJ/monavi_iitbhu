import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';

class ConfidenceRing extends StatefulWidget {
  final double confidence; // 0.0 - 1.0
  final String confidenceLevel; // high/medium/low
  final double size;
  final bool animate;

  const ConfidenceRing({
    super.key,
    required this.confidence,
    required this.confidenceLevel,
    this.size = 120,
    this.animate = true,
  });

  @override
  State<ConfidenceRing> createState() => _ConfidenceRingState();
}

class _ConfidenceRingState extends State<ConfidenceRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.confidence,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = DesignTokens.getConfidenceColor(widget.confidenceLevel);

    // Calculate responsive font sizes based on ring size
    final isSmall = widget.size <= 60;
    final percentFontSize = isSmall ? 14.0 : 22.0;
    final labelFontSize = isSmall ? 8.0 : 11.0;
    final lineWidth = isSmall ? 4.0 : 6.0;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final displayPercentage = (_animation.value * 100).round();

        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Subtle glow, not overpowering
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CircularPercentIndicator(
            radius: widget.size / 2,
            lineWidth: lineWidth,
            percent: widget.animate ? _animation.value : widget.confidence,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$displayPercentage%',
                  style: GoogleFonts.inter(
                    fontSize: percentFontSize,
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1.1,
                  ),
                ),
                if (!isSmall) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.confidenceLevel.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w600,
                      color: color.withOpacity(0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
            progressColor: color,
            backgroundColor: DesignTokens.borderGray.withOpacity(0.5),
            circularStrokeCap: CircularStrokeCap.round,
            animation: false, // We handle animation manually
          ),
        );
      },
    );
  }
}
