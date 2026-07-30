import 'package:flutter/material.dart';

/// Sprout.ly palette — transcribed from `ref/color system.html` (Figma).
///
/// Seven ramps, ten steps each (50–900). Low values for backgrounds and soft
/// areas, high values for text and firm elements.
///
/// **Every value here is the Figma value.** The previous version of this file
/// had drifted: `teal700` was `446B60` instead of `446860`, `peach500` was
/// `CA8C6C` instead of `C4806C`, and `neutral300` was `DCCAD7` — a transposition
/// of `CCDAD7` that turned the plate behind every activity picture mauve. The
/// raw hex scattered through the pages was, ironically, correct; the tokens were
/// the drift.
class AppColors {
  AppColors._();

  // ===== Teal — Primary · NCS 3020 B50G =====
  // Aksi utama, progress, status selesai.
  static const teal50 = Color(0xFFEDF4F3);
  static const teal100 = Color(0xFFD2E8E5);
  static const teal200 = Color(0xFFB8D2CE);
  static const teal300 = Color(0xFF9ABCB6);
  static const teal400 = Color(0xFF8CB0A8);
  static const teal500 = Color(0xFF7EA29C);
  static const teal600 = Color(0xFF5E8880);
  static const teal700 = Color(0xFF446860);
  static const teal800 = Color(0xFF2E4A44);
  static const teal900 = Color(0xFF1A2C28);

  // ===== Steel — Info · NCS 3030 B =====
  // Kegiatan belajar, instruksi, panduan.
  static const steel50 = Color(0xFFEDF3F7);
  static const steel100 = Color(0xFFD2E2EE);
  static const steel200 = Color(0xFFB5CCDE);
  static const steel300 = Color(0xFF98B6CE);
  static const steel400 = Color(0xFF8AAABF);
  static const steel500 = Color(0xFF7B9DB8);
  static const steel600 = Color(0xFF5C7E98);
  static const steel700 = Color(0xFF426078);
  static const steel800 = Color(0xFF2C4458);
  static const steel900 = Color(0xFF182838);

  // ===== Cream — Aksen · NCS 1020 Y20R =====
  // Reward, highlight, elemen hangat.
  static const cream50 = Color(0xFFFAF8F0);
  static const cream100 = Color(0xFFF2ECD8);
  static const cream200 = Color(0xFFE8DFC0);
  static const cream300 = Color(0xFFDDD1A4);
  static const cream400 = Color(0xFFCFC38C);
  static const cream500 = Color(0xFFC4B878);
  static const cream600 = Color(0xFFA09858);
  static const cream700 = Color(0xFF7C7640);
  static const cream800 = Color(0xFF58542C);
  static const cream900 = Color(0xFF343218);

  // ===== Peach =====
  static const peach50 = Color(0xFFFBF3EF);
  static const peach100 = Color(0xFFF5E0D5);
  static const peach200 = Color(0xFFEECABC);
  static const peach300 = Color(0xFFE4B09C);
  static const peach400 = Color(0xFFD8987E);
  static const peach500 = Color(0xFFC4806C);
  static const peach600 = Color(0xFFA86250);
  static const peach700 = Color(0xFF844838);
  static const peach800 = Color(0xFF5E3228);
  static const peach900 = Color(0xFF381C14);

  // ===== Mauve =====
  static const mauve50 = Color(0xFFF4F0F3);
  static const mauve100 = Color(0xFFE5D8E2);
  static const mauve200 = Color(0xFFD0BCCA);
  static const mauve300 = Color(0xFFBCA0B0);
  static const mauve400 = Color(0xFFB090A4);
  static const mauve500 = Color(0xFFA88898);
  static const mauve600 = Color(0xFF886878);
  static const mauve700 = Color(0xFF664C5A);
  static const mauve800 = Color(0xFF48343E);
  static const mauve900 = Color(0xFF2A1C24);

  // ===== Olive =====
  static const olive50 = Color(0xFFF2F4EE);
  static const olive100 = Color(0xFFDEE6D4);
  static const olive200 = Color(0xFFC8D4BC);
  static const olive300 = Color(0xFFB0C0A0);
  static const olive400 = Color(0xFFA4B48C);
  static const olive500 = Color(0xFF98A878);
  static const olive600 = Color(0xFF788858);
  static const olive700 = Color(0xFF58683E);
  static const olive800 = Color(0xFF3C4828);
  static const olive900 = Color(0xFF222C14);

  // ===== Neutral =====
  static const neutral50 = Color(0xFFFAFCFB);
  static const neutral100 = Color(0xFFF2F5F4);
  static const neutral200 = Color(0xFFE4EDEB);
  static const neutral300 = Color(0xFFCCDAD7);
  static const neutral400 = Color(0xFFB0C0BE);
  static const neutral500 = Color(0xFF8EA09E);
  static const neutral600 = Color(0xFF7A8A88);
  static const neutral700 = Color(0xFF566866);
  static const neutral800 = Color(0xFF353C3A);
  static const neutral900 = Color(0xFF1C2220);

  static const white = Color(0xFFFFFFFF);
  static const transparent = Color(0x00000000);

  // ===== Semantic: surfaces =====
  // The Figma layouts use neutral100 for the app canvas and neutral50 for the
  // cards sitting on it.

  static const background = neutral100;
  static const surface = neutral50;

  /// Plate behind activity artwork.
  static const imagePlate = neutral200;

  // ===== Semantic: ink =====

  static const textPrimary = neutral800;

  /// The muted ink Figma uses for supporting copy. 4.72:1 on [background].
  static const textSecondary = neutral600;

  /// Disabled controls only — WCAG exempts those from the contrast minimum.
  static const textDisabled = neutral500;

  /// Ink for the light 50/100-level tints.
  static const onTint = neutral800;

  /// Ink for filled 600/700-level surfaces.
  static const onFilled = white;

  // ===== Semantic: lines =====

  /// Figma draws card outlines as neutral800 at 8% — a hairline, decorative, so
  /// the 3:1 rule does not apply.
  static const divider = Color(0x14353C3A);

  /// Outlines that carry meaning: inputs, selected cards, focus.
  static const border = neutral600;

  // ===== Semantic: actions =====
  // Figma's documented pairs: "Teal 500 + White" and "Teal 600 + White" for
  // primary buttons, "Peach 500 + White" for the warm accent.

  static const primary = teal500;

  /// Primary call to action.
  static const actionPrimary = teal600;
  static const actionPrimaryPressed = teal700;

  /// Warm accent action (add, reward).
  static const actionAccent = peach600;

  static const focusRing = teal700;

  // ===== Semantic: status =====

  static const success = teal700;
  static const warning = cream800;
  static const error = peach700;
  static const info = steel700;

  static const successTint = teal50;
  static const warningTint = cream100;
  static const errorTint = peach50;
  static const infoTint = steel50;

  // ===== Board accents =====
  // Each board type owns a hue so a parent can tell them apart in the grid.

  static const boardSchedule = mauve300;
  static const boardFirstThen = steel300;
  static const boardWaiting = cream300;
  static const boardEmotion = peach300;
}
