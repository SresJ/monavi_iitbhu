import 'package:flutter/material.dart';

/// Shared layout breakpoints for adaptive UI (Phase 1 — mobile migration).
///
/// Use [Breakpoints] for `LayoutBuilder` / explicit widths, and
/// [BreakpointContext] on [BuildContext] for full-screen checks.
abstract final class Breakpoints {
  Breakpoints._();

  // --- Width thresholds (logical pixels) ---

  /// Widths at or below this use **compact** branching (typical phone portrait).
  static const double compactMaxWidth = 600.0;

  /// Widths **above** this show the two-column chart row on Analytics
  /// (diagnosis donut + confidence gauge side by side).
  static const double twoColumnChartsMinWidth = 700.0;

  /// Widths **above** this use the landing **desktop** split (row: copy + features).
  static const double landingDesktopMinWidth = 900.0;

  // --- Interaction ---

  /// Minimum tap target (Material / accessibility guidance).
  static const double minTouchTarget = 48.0;

  /// Viewport height below this uses tighter vertical spacing (e.g. landscape phone).
  static const double shortViewportMaxHeight = 520.0;

  // --- Predicates (explicit width, e.g. from LayoutBuilder) ---

  static bool isCompactWidth(double width) => width <= compactMaxWidth;

  static bool isTwoColumnChartsWidth(double width) =>
      width > twoColumnChartsMinWidth;

  static bool isLandingDesktopWidth(double width) =>
      width > landingDesktopMinWidth;

  static bool isShortViewportHeight(double height) =>
      height < shortViewportMaxHeight;
}

/// Media-query helpers for the current route / screen.
extension BreakpointContext on BuildContext {
  Size get breakpointSize => MediaQuery.sizeOf(this);

  double get breakpointWidth => breakpointSize.width;

  /// Shortest side of the window (useful for foldables / split-screen).
  double get breakpointShortestSide => breakpointSize.shortestSide;

  /// True when width is compact. Does not use [breakpointShortestSide] by default
  /// to avoid misclassifying landscape tablets; combine manually if needed.
  bool get isLayoutCompact => Breakpoints.isCompactWidth(breakpointWidth);

  /// True when landing should use the wide desktop layout.
  bool get isLandingDesktopLayout =>
      Breakpoints.isLandingDesktopWidth(breakpointWidth);

  /// True when analytics charts should sit in one row.
  bool get isChartTwoColumnLayout =>
      Breakpoints.isTwoColumnChartsWidth(breakpointWidth);

  /// True when vertical space is tight (landscape handset, short window).
  bool get isShortViewport =>
      Breakpoints.isShortViewportHeight(breakpointSize.height);
}

/// Optional: cap system text scale so display headings stay usable on phones.
///
/// Wrap a subtree (or use in [MaterialApp.builder]) when you want clamping.
/// Not applied globally unless you opt in.
class ClampedTextScale extends StatelessWidget {
  const ClampedTextScale({
    super.key,
    required this.child,
    this.minScaleFactor = 0.85,
    this.maxScaleFactor = 1.25,
  });

  final Widget child;
  final double minScaleFactor;
  final double maxScaleFactor;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        textScaler: mq.textScaler.clamp(
          minScaleFactor: minScaleFactor,
          maxScaleFactor: maxScaleFactor,
        ),
      ),
      child: child,
    );
  }
}
