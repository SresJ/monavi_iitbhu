import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../config/design_tokens.dart';

class ClinicalLoading extends StatefulWidget {
  final String? message;
  final List<String>? rotatingMessages;

  const ClinicalLoading({
    Key? key,
    this.message,
    this.rotatingMessages,
  }) : super(key: key);

  @override
  State<ClinicalLoading> createState() => _ClinicalLoadingState();
}

class _ClinicalLoadingState extends State<ClinicalLoading> {
  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.rotatingMessages != null &&
        widget.rotatingMessages!.isNotEmpty) {
      _startRotation();
    }
  }

  void _startRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && widget.rotatingMessages != null) {
        setState(() {
          _currentMessageIndex =
              (_currentMessageIndex + 1) % widget.rotatingMessages!.length;
        });
        _startRotation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String displayMessage = widget.message ?? 'Loading...';

    if (widget.rotatingMessages != null &&
        widget.rotatingMessages!.isNotEmpty) {
      displayMessage = widget.rotatingMessages![_currentMessageIndex];
    }

    return Container(
      color: DesignTokens.voidBlack.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SpinKitCircle(
              color: DesignTokens.clinicalTeal,
              size: 64,
            ),
            const SizedBox(height: DesignTokens.spaceLg),
            AnimatedSwitcher(
              duration: DesignTokens.standard,
              child: Text(
                displayMessage,
                key: ValueKey(displayMessage),
                style: DesignTokens.bodyLarge.copyWith(
                  color: DesignTokens.clinicalTeal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Show loading overlay
void showClinicalLoading(
  BuildContext context, {
  String? message,
  List<String>? rotatingMessages,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (context) => ClinicalLoading(
      message: message,
      rotatingMessages: rotatingMessages,
    ),
  );
}

/// Hide loading overlay
void hideClinicalLoading(BuildContext context) {
  Navigator.of(context).pop();
}
