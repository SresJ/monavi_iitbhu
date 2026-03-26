import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../config/design_tokens.dart';

enum ClinicalButtonVariant { primary, secondary, ghost }
enum ClinicalButtonSize { small, medium, large }

class ClinicalButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final ClinicalButtonVariant variant;
  final ClinicalButtonSize size;
  final bool isLoading;
  final bool fullWidth;

  const ClinicalButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.variant = ClinicalButtonVariant.primary,
    this.size = ClinicalButtonSize.medium,
    this.isLoading = false,
    this.fullWidth = false,
  }) : super(key: key);

  // Named constructors for convenience
  factory ClinicalButton.primary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    IconData? trailingIcon,
    ClinicalButtonSize size = ClinicalButtonSize.medium,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return ClinicalButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      trailingIcon: trailingIcon,
      variant: ClinicalButtonVariant.primary,
      size: size,
      isLoading: isLoading,
      fullWidth: fullWidth,
    );
  }

  factory ClinicalButton.secondary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    IconData? trailingIcon,
    ClinicalButtonSize size = ClinicalButtonSize.medium,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return ClinicalButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      trailingIcon: trailingIcon,
      variant: ClinicalButtonVariant.secondary,
      size: size,
      isLoading: isLoading,
      fullWidth: fullWidth,
    );
  }

  factory ClinicalButton.ghost({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    IconData? trailingIcon,
    ClinicalButtonSize size = ClinicalButtonSize.medium,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return ClinicalButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      trailingIcon: trailingIcon,
      variant: ClinicalButtonVariant.ghost,
      size: size,
      isLoading: isLoading,
      fullWidth: fullWidth,
    );
  }

  @override
  State<ClinicalButton> createState() => _ClinicalButtonState();
}

class _ClinicalButtonState extends State<ClinicalButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: DesignTokens.quick,
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.97 : (_isHovered ? 1.02 : 1.0)),
          child: _buildButton(isDisabled),
        ),
      ),
    );
  }

  Widget _buildButton(bool isDisabled) {
    switch (widget.variant) {
      case ClinicalButtonVariant.primary:
        return _buildPrimaryButton(isDisabled);
      case ClinicalButtonVariant.secondary:
        return _buildSecondaryButton(isDisabled);
      case ClinicalButtonVariant.ghost:
        return _buildGhostButton(isDisabled);
    }
  }

  Widget _buildPrimaryButton(bool isDisabled) {
    return Container(
      width: widget.fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        gradient: isDisabled
            ? null
            : const LinearGradient(
                colors: [DesignTokens.medicalBlue, DesignTokens.clinicalTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDisabled ? DesignTokens.borderGray : null,
        borderRadius: DesignTokens.radiusMd,
        boxShadow: _isHovered && !isDisabled ? DesignTokens.glowBlue : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : widget.onPressed,
          borderRadius: DesignTokens.radiusMd,
          child: Padding(
            padding: _getPadding(),
            child: _buildContent(DesignTokens.textPrimary, isDisabled),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(bool isDisabled) {
    return Container(
      width: widget.fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: DesignTokens.radiusMd,
        border: Border.all(
          color: isDisabled
              ? DesignTokens.borderGray
              : DesignTokens.clinicalTeal,
          width: 1,
        ),
        boxShadow: _isHovered && !isDisabled ? DesignTokens.glowTeal : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : widget.onPressed,
          borderRadius: DesignTokens.radiusMd,
          child: Padding(
            padding: _getPadding(),
            child: _buildContent(
              isDisabled
                  ? DesignTokens.textTertiary
                  : DesignTokens.clinicalTeal,
              isDisabled,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGhostButton(bool isDisabled) {
    return SizedBox(
      width: widget.fullWidth ? double.infinity : null,
      child: TextButton(
        onPressed: isDisabled ? null : widget.onPressed,
        style: TextButton.styleFrom(
          foregroundColor:
              isDisabled ? DesignTokens.textTertiary : DesignTokens.clinicalTeal,
          padding: _getPadding(),
        ),
        child: _buildContent(
          isDisabled ? DesignTokens.textTertiary : DesignTokens.clinicalTeal,
          isDisabled,
        ),
      ),
    );
  }

  Widget _buildContent(Color color, bool isDisabled) {
    if (widget.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitCircle(
            color: color,
            size: _getIconSize(),
          ),
          const SizedBox(width: DesignTokens.spaceSm),
          Text(
            'Loading...',
            style: _getTextStyle().copyWith(color: color),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: _getIconSize(), color: color),
          const SizedBox(width: DesignTokens.spaceSm),
        ],
        Text(
          widget.label,
          style: _getTextStyle().copyWith(color: color),
        ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: DesignTokens.spaceSm),
          Icon(widget.trailingIcon, size: _getIconSize(), color: color),
        ],
      ],
    );
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ClinicalButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceMd,
          vertical: DesignTokens.spaceSm,
        );
      case ClinicalButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceLg,
          vertical: DesignTokens.spaceMd,
        );
      case ClinicalButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceXl,
          vertical: DesignTokens.spaceLg,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case ClinicalButtonSize.small:
        return DesignTokens.labelMedium;
      case ClinicalButtonSize.medium:
        return DesignTokens.labelLarge;
      case ClinicalButtonSize.large:
        return DesignTokens.headingSmall;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ClinicalButtonSize.small:
        return 16;
      case ClinicalButtonSize.medium:
        return 20;
      case ClinicalButtonSize.large:
        return 24;
    }
  }
}
