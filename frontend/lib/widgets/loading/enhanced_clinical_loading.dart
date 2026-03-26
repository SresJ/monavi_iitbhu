import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../config/design_tokens.dart';

class EnhancedClinicalLoading extends StatelessWidget {
  final String? message;
  final double size;

  const EnhancedClinicalLoading({
    Key? key,
    this.message,
    this.size = 60.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SpinKitPulsingGrid(
          size: size,
          itemBuilder: (context, index) {
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: DesignTokens.medicalGradient,
                borderRadius: BorderRadius.circular(4),
                boxShadow: DesignTokens.glowBlue,
              ),
            );
          },
        ),
        if (message != null) ...[
          const SizedBox(height: DesignTokens.spaceMd),
          Text(
            message!,
            style: DesignTokens.bodyMedium.copyWith(
              color: DesignTokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Shimmer loading skeleton for cards
class ShimmerCard extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const ShimmerCard({
    Key? key,
    this.height = 100,
    this.width,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? DesignTokens.radiusLg,
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _controller.value * 2, 0),
              end: Alignment(1.0 + _controller.value * 2, 0),
              colors: [
                DesignTokens.cardBlack,
                DesignTokens.borderGray,
                DesignTokens.cardBlack,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
