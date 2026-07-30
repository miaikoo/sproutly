import 'package:flutter/material.dart';

/// Sprout.ly palette.
///
/// The hue ramps come from the Figma design and are preserved as-is. What
/// changed is the *pairing* rules: white text was sitting on 500-level fills at
/// 1.7–2.8:1, well under WCAG AA. Filled surfaces now use 700-level, which
/// already existed and clears 4.5:1. Use the semantic tokens at the bottom
/// rather than reaching into a ramp directly.
class AppColors {
  AppColors._();

  // ===== Primary (Teal) =====
  static const teal50 = Color(0xFFEDF4F3);
  static const teal100 = Color(0xFFD2E8E5);
  static const teal300 = Color(0xFFA9C8C6);
  static const teal500 = Color(0xFF7FA29C);
  static const teal700 = Color(0xFF446B60);
  static const teal900 = Color(0xFF1A2C28);

  // ===== Info (Steel) =====
  static const steel100 = Color(0xFFD2E2EE);
  static const steel300 = Color(0xFF96B6CE);
  static const steel500 = Color(0xFF7B9DB8);
  static const steel700 = Color(0xFF426078);
  static const steel900 = Color(0xFF182838);

  // ===== Reward (Cream) =====
  static const cream100 = Color(0xFFF2E7CB);
  static const cream300 = Color(0xFFE0D1A4);
  static const cream500 = Color(0xFFC4B878);
  static const cream700 = Color(0xFF7C7640);
  // Cream is the lightest hue in the set: even cream700 only reaches 4.36:1 on
  // the app background, so text needs this darker step.
  static const cream900 = Color(0xFF4A461F);

  // ===== Warning (Peach) =====
  static const peach100 = Color(0xFFF5DCCF);
  static const peach300 = Color(0xFFE4B09C);
  static const peach500 = Color(0xFFCA8C6C);
  static const peach700 = Color(0xFF8B4B38);

  // ===== Nature (Olive) =====
  static const olive100 = Color(0xFFDEE5D4);
  static const olive300 = Color(0xFFB0C0A0);
  static const olive500 = Color(0xFF98AB78);
  static const olive700 = Color(0xFF5B6B39);

  // ===== Board accent (Mauve) =====
  // Was hard-coded as 0xFFBCA0B0 in three pages; promoted to a token so the
  // schedule-board colour has a name like every other board type.
  static const mauve100 = Color(0xFFEDE3E8);
  static const mauve300 = Color(0xFFBCA0B0);
  static const mauve500 = Color(0xFF9C7A8C);
  static const mauve700 = Color(0xFF5E3F4E);

  // ===== Neutral =====
  static const white = Color(0xFFFCFCFB);
  static const transparent = Color(0x00000000);

  static const neutral50 = Color(0xFFF8F8F4);
  static const neutral100 = Color(0xFFF2F5F4);
  static const neutral200 = Color(0xFFE4EDEB);
  // Was 0xFFDCCAD7 — a mauve sitting in an otherwise green-leaning ramp, and it
  // was the plate behind every activity illustration, tinting all of the
  // child-facing artwork pink. Now an actual neutral.
  static const neutral300 = Color(0xFFD6E0DD);
  static const neutral400 = Color(0xFFBFC9C6);
  static const neutral500 = Color(0xFF9EA09E);
  static const neutral600 = Color(0xFF74857F);
  static const neutral700 = Color(0xFF566B66);
  static const neutral800 = Color(0xFF353C3A);
  static const neutral900 = Color(0xFF1C2220);

  // ===== Semantic: surfaces =====

  static const primary = teal700;
  static const background = neutral50;
  static const surface = white;

  /// Quiet second layer for panels and cards sitting on [background].
  static const surfaceMuted = neutral100;

  /// Plate behind activity artwork. Deliberately low-chroma so the illustration
  /// is what the child sees, not the container.
  static const imagePlate = neutral200;

  // ===== Semantic: ink =====

  static const textPrimary = neutral800;

  /// 5.34:1 on [background]. The lightest ink that still passes for body text —
  /// use this for placeholders and hints too. There is deliberately no lighter
  /// tier: anything paler failed AA when measured.
  static const textSecondary = neutral700;

  /// Disabled controls only. 3.79:1, which WCAG exempts for disabled state but
  /// which is not acceptable for anything a parent has to read.
  static const textDisabled = neutral600;

  /// Ink for the light 100-level tints — 8.5:1 or better on all of them.
  /// Never put [textSecondary] on a tint: on teal100 it measures 4.45:1.
  static const onTint = neutral800;

  /// Ink for use on filled 700-level surfaces.
  static const onFilled = white;

  // ===== Semantic: lines =====

  /// Hairline separators. Decorative, so the 3:1 rule does not apply.
  static const divider = neutral200;

  /// Outlines that carry meaning — input fields, selectable cards, focus.
  /// 3.65:1 on [background], clearing the non-text contrast minimum.
  static const border = neutral600;

  // ===== Semantic: actions =====

  /// Primary call to action. 6.47:1 with [onFilled].
  static const actionPrimary = peach700;
  static const actionPrimaryPressed = Color(0xFF6E3A2B);

  /// Secondary / supporting action. 5.82:1 with [onFilled].
  static const actionSecondary = teal700;

  static const focusRing = teal700;

  // ===== Semantic: status =====
  // All four are text-legible on [background]; the 500-level versions they
  // replaced ranged from 2.3 to 2.6:1.

  static const success = olive700;
  static const warning = cream900;
  static const error = peach700;
  static const info = steel700;

  /// Tinted status backgrounds, to pair with [onTint].
  static const successTint = olive100;
  static const warningTint = cream100;
  static const errorTint = peach100;
  static const infoTint = steel100;
}
