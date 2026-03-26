import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/design_tokens.dart';

/// Skeleton loader for clinical interface
/// Provides layout-preserving placeholders during loading
class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    Key? key,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: DesignTokens.cardBlack,
      highlightColor: DesignTokens.borderGray.withOpacity(0.3),
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: DesignTokens.cardBlack,
          borderRadius: borderRadius ?? DesignTokens.radiusSm,
        ),
      ),
    );
  }
}

/// Skeleton for metric cards
class SkeletonMetricCard extends StatelessWidget {
  const SkeletonMetricCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceLg,
        vertical: DesignTokens.spaceLg,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.cardBlack,
        borderRadius: DesignTokens.radiusLg,
        border: Border.all(
          color: DesignTokens.borderGray.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SkeletonLoader(width: 120, height: 64),
          const SizedBox(height: DesignTokens.spaceSm),
          SkeletonLoader(
            width: 140,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for patient cards
class SkeletonPatientCard extends StatelessWidget {
  const SkeletonPatientCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceLg,
        vertical: DesignTokens.spaceMd,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.cardBlack,
        borderRadius: DesignTokens.radiusLg,
        border: Border.all(
          color: DesignTokens.borderGray.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const SkeletonLoader(width: 52, height: 52),
          const SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: double.infinity,
                  height: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: 120,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
