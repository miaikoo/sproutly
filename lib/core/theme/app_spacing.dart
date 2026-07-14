import 'package:flutter/widgets.dart';

/// Standard spacing system (8-point grid)
///
/// Use this instead of hardcoding numbers.
/// Example:
///
/// Padding(
///   padding: EdgeInsets.all(AppSpacing.md),
/// )
///
/// AppSpacing.gapMD
///
class AppSpacing {
  AppSpacing._();

  // Spacing Values
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;

  // Vertical Gaps
  static const gapXXS = SizedBox(height: xxs);
  static const gapXS = SizedBox(height: xs);
  static const gapSM = SizedBox(height: sm);
  static const gapMD = SizedBox(height: md);
  static const gapLG = SizedBox(height: lg);
  static const gapXL = SizedBox(height: xl);
  static const gapXXL = SizedBox(height: xxl);
  static const gapXXXL = SizedBox(height: xxxl);

  // Horizontal Gaps
  static const gapHXXS = SizedBox(width: xxs);
  static const gapHXS = SizedBox(width: xs);
  static const gapHSM = SizedBox(width: sm);
  static const gapHMD = SizedBox(width: md);
  static const gapHLG = SizedBox(width: lg);
  static const gapHXL = SizedBox(width: xl);
  static const gapHXXL = SizedBox(width: xxl);

  // Common Page Padding
  static const pagePadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: md,
  );

  static const cardPadding = EdgeInsets.all(md);

  static const dialogPadding = EdgeInsets.all(xl);

  static const listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
}