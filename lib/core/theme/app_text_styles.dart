import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Type scale — transcribed from `ref/text system.html` (Figma).
///
/// Font primer **Nunito** (display, heading, label, button, angka), font
/// sekunder **Nunito Sans** (body dan teks panjang). Keduanya kini benar-benar
/// ter-bundle di `assets/fonts/` sebagai variable font; sebelumnya nama font ini
/// dideklarasikan tanpa filenya pernah ada, jadi semuanya jatuh ke Roboto.
///
/// Sizes are the spec's rem values at 16px root, and `height` is the spec's
/// unitless line-height.
class AppTextStyles {
  AppTextStyles._();

  static const primary = 'Nunito';
  static const secondary = 'Nunito Sans';

  // ===== Display — Nunito, w700 =====

  /// 2.25rem · w700 · lh 1.1 · ls -0.02em
  static const displayXL = TextStyle(
    fontFamily: primary,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.72,
    color: AppColors.textPrimary,
  );

  /// 1.875rem · w700 · lh 1.15 · ls -0.015em
  static const displayL = TextStyle(
    fontFamily: primary,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.45,
    color: AppColors.textPrimary,
  );

  /// 1.5rem · w700 · lh 1.2 · ls -0.01em
  static const displayM = TextStyle(
    fontFamily: primary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.24,
    color: AppColors.textPrimary,
  );

  // ===== Heading — Nunito, w600 =====

  /// 1.25rem · w600 · lh 1.3
  static const headingL = TextStyle(
    fontFamily: primary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// 1.125rem · w600 · lh 1.35
  static const headingM = TextStyle(
    fontFamily: primary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  /// 1rem · w600 · lh 1.4
  static const headingS = TextStyle(
    fontFamily: primary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ===== Body — Nunito Sans, w400 =====

  /// 1.0625rem · w400 · lh 1.65
  static const bodyL = TextStyle(
    fontFamily: secondary,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.65,
    color: AppColors.textPrimary,
  );

  /// 0.9375rem · w400 · lh 1.6
  static const bodyM = TextStyle(
    fontFamily: secondary,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  /// 0.875rem · w400 · lh 1.55
  static const bodyS = TextStyle(
    fontFamily: secondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: AppColors.textPrimary,
  );

  // ===== Label — Nunito, w600, uppercase in use =====

  /// 0.875rem · w600 · lh 1.4 · ls 0.04em
  static const labelL = TextStyle(
    fontFamily: primary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.56,
    color: AppColors.textPrimary,
  );

  /// 0.75rem · w600 · lh 1.4 · ls 0.06em
  static const labelM = TextStyle(
    fontFamily: primary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.72,
    color: AppColors.textPrimary,
  );

  /// 0.6875rem · w600 · lh 1.4 · ls 0.08em
  static const labelS = TextStyle(
    fontFamily: primary,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.88,
    color: AppColors.textPrimary,
  );

  // ===== Button — Nunito, w600, lh 1 =====

  /// 1rem · w600 · lh 1 · ls 0.01em
  static const buttonL = TextStyle(
    fontFamily: primary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: 0.16,
  );

  /// 0.875rem · w600 · lh 1 · ls 0.01em
  static const buttonM = TextStyle(
    fontFamily: primary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: 0.14,
  );

  /// 0.75rem · w600 · lh 1 · ls 0.02em
  static const buttonS = TextStyle(
    fontFamily: primary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: 0.24,
  );

  // ===== Data / waktu — Nunito, w700, lh 1 =====

  /// 3rem · w700 · lh 1 · ls -0.03em
  static const timeXL = TextStyle(
    fontFamily: primary,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: -1.44,
    color: AppColors.textPrimary,
  );

  /// 2rem · w700 · lh 1 · ls -0.02em
  static const timeL = TextStyle(
    fontFamily: primary,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: -0.64,
    color: AppColors.textPrimary,
  );

  // ===== Caption — Nunito Sans =====

  /// 0.75rem · w400 · lh 1.5
  static const caption = TextStyle(
    fontFamily: secondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );
}
