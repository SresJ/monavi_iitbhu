import 'package:flutter/material.dart';
import '../../config/design_tokens.dart';

/// Reusable card with hover scale effect and glow
class HoverScaleCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? glowColor;
  final double scale;
  final Duration duration;

  const HoverScaleCard({
    Key? key,
    required this.child,
    this.onTap,
    this.glowColor,
    this.scale = 1.02,
    this.duration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  State<HoverScaleCard> createState() => _HoverScaleCardState();
}

class _HoverScaleCardState extends State<HoverScaleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(_isHovered ? widget.scale : 1.0),
          decoration: BoxDecoration(
            borderRadius: DesignTokens.radiusLg,
            boxShadow: _isHovered && widget.glowColor != null
                ? [
                    BoxShadow(
                      color: widget.glowColor!.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Glass morphism container with blur effect
class GlassMorphismCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final List<BoxShadow>? boxShadow;

  const GlassMorphismCard({
    Key? key,
    required this.child,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.padding,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.cardBlack.withOpacity(0.6),
            DesignTokens.cardBlack.withOpacity(0.3),
          ],
        ),
        borderRadius: borderRadius ?? DesignTokens.radiusLg,
        border: Border.all(
          color: borderColor ?? DesignTokens.borderGray.withOpacity(0.3),
          width: borderWidth,
        ),
        boxShadow: boxShadow ?? DesignTokens.depth2,
      ),
      child: child,
    );
  }
}

/// Animated confidence ring
class ConfidenceRing extends StatefulWidget {
  final double confidence; // 0.0 to 1.0
  final String level; // high, medium, low
  final double size;

  const ConfidenceRing({
    Key? key,
    required this.confidence,
    required this.level,
    this.size = 60,
  }) : super(key: key);

  @override
  State<ConfidenceRing> createState() => _ConfidenceRingState();
}

class _ConfidenceRingState extends State<ConfidenceRing> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = DesignTokens.getConfidenceColor(widget.level);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.0),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3 + _pulseController.value * 0.3),
                blurRadius: 16 + _pulseController.value * 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: widget.size * 0.7,
              height: widget.size * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  '${(widget.confidence * 100).round()}%',
                  style: DesignTokens.labelLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
