import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Type scale for Sprout.ly.
///
/// **On the typeface:** these styles used to declare `fontFamily: 'Nunito'` and
/// `'Nunito Sans'`, but neither font was ever bundled — there is no `fonts:`
/// section in pubspec.yaml and no `assets/fonts/`. Every one of those
/// declarations silently fell back to the platform face, so the app has always
/// rendered in Roboto. The names are gone rather than left as a lie.
///
/// To actually ship Nunito: drop the `.ttf` files into `assets/fonts/`, declare
/// a `fonts:` section in pubspec.yaml, and set [family] to `'Nunito'`. Every
/// style below picks it up from that one constant.
///
/// Sizes are a 1.2-ish ratio (product register: tight steps, many elements) and
/// carry no `letterSpacing` on body sizes — Roboto is already well fitted, and
/// the old hand-tuned tracking was inherited from a font that never loaded.
class AppTextStyles {
  AppTextStyles._();

  /// Null means "platform default face". See the class doc to switch to Nunito.
  static const String? family = null;

  static const displayXL = TextStyle(
    fontFamily: family,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const displayL = TextStyle(
    fontFamily: family,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const displayM = TextStyle(
    fontFamily: family,
    fontSize: 23,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static const headingL = TextStyle(
    fontFamily: family,
    fontSize: 19,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  static const headingM = TextStyle(
    fontFamily: family,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const headingS = TextStyle(
    fontFamily: family,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  static const bodyL = TextStyle(
    fontFamily: family,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: AppColors.textPrimary,
  );

  static const bodyM = TextStyle(
    fontFamily: family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: AppColors.textPrimary,
  );

  static const bodyS = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Section and card labels. Primary ink rather than secondary because these
  /// sit on tinted cards, where secondary measures only 4.45:1.
  static const labelL = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: AppColors.textPrimary,
  );

  /// Button and control text. 16sp so it stays legible at arm's length on a
  /// tablet propped on a table.
  static const button = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.1,
  );

  /// 13sp rather than 12: this is a parent-facing app, and captions carry real
  /// information (times, step counts, streak notes).
  static const caption = TextStyle(
    fontFamily: family,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  /// Big, calm numerals for the child-facing runner and the progress figures.
  static const metric = TextStyle(
    fontFamily: family,
    fontSize: 44,
    fontWeight: FontWeight.w800,
    height: 1.05,
    letterSpacing: -1,
    color: AppColors.textPrimary,
  );
}
