import 'package:flutter/material.dart';
import '../../config/design_tokens.dart';

class ClinicalInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool autofocus;

  const ClinicalInput({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  State<ClinicalInput> createState() => _ClinicalInputState();
}

class _ClinicalInputState extends State<ClinicalInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: DesignTokens.labelMedium,
          ),
          const SizedBox(height: DesignTokens.spaceSm),
        ],
        AnimatedContainer(
          duration: DesignTokens.quick,
          decoration: BoxDecoration(
            color: DesignTokens.cardBlack,
            borderRadius: DesignTokens.radiusMd,
            border: Border.all(
              color: hasError
                  ? DesignTokens.error
                  : (_isFocused
                      ? DesignTokens.clinicalTeal
                      : DesignTokens.borderGray),
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused && !hasError ? DesignTokens.glowTeal : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            onChanged: widget.onChanged,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            style: DesignTokens.bodyMedium,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: DesignTokens.bodyMedium.copyWith(
                color: DesignTokens.textTertiary,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? DesignTokens.clinicalTeal
                          : DesignTokens.textSecondary,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconButton(
                      icon: Icon(
                        widget.suffixIcon,
                        color: _isFocused
                            ? DesignTokens.clinicalTeal
                            : DesignTokens.textSecondary,
                      ),
                      onPressed: widget.onSuffixIconTap,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceMd,
                vertical: DesignTokens.spaceMd,
              ),
            ),
          ),
        ),
        if (widget.helperText != null && !hasError) ...[
          const SizedBox(height: DesignTokens.spaceSm),
          Text(
            widget.helperText!,
            style: DesignTokens.bodySmall.copyWith(
              color: DesignTokens.textSecondary,
            ),
          ),
        ],
        if (hasError) ...[
          const SizedBox(height: DesignTokens.spaceSm),
          Text(
            widget.errorText!,
            style: DesignTokens.bodySmall.copyWith(
              color: DesignTokens.error,
            ),
          ),
        ],
      ],
    );
  }
}

/// Textarea variant for multiline input
class ClinicalTextarea extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final int minLines;
  final int maxLines;
  final Function(String)? onChanged;

  const ClinicalTextarea({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.minLines = 5,
    this.maxLines = 10,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClinicalInput(
      label: label,
      hint: hint,
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }
}
