import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

/// Material 3 theme for Sprout.ly.
///
/// Component themes are set here rather than per-page: fixing the ColorScheme
/// and button themes once corrects contrast and touch-target size everywhere,
/// instead of hunting through fifteen screens.
///
/// Every touch target is at least 48dp per Material's accessibility minimum —
/// this app is used one-handed by a parent while managing a child, often on a
/// tablet held at arm's length.
class AppTheme {
  AppTheme._();

  /// Material's minimum touch target. Used as the floor for every control.
  static const minTarget = 48.0;

  /// Standard transition length. Short: the parent is mid-task, and a child who
  /// is sensitive to movement should not have to wait out choreography.
  static const motionFast = Duration(milliseconds: 200);
  static const motionBase = Duration(milliseconds: 320);

  /// Deceleration curve. Never bounce or elastic — overshoot reads as playful to
  /// an adult and as unpredictable to a child regulating on this screen.
  static const motionCurve = Curves.easeOutCubic;

  /// [duration], or nothing when the user has asked the system to remove
  /// animations. Honouring that setting is an accessibility requirement, and
  /// this audience is more likely than most to have it switched on.
  static Duration motion(BuildContext context, Duration duration) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  }

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: AppTextStyles.primary,

    colorScheme: const ColorScheme.light(
      primary: AppColors.actionPrimary,
      onPrimary: AppColors.onFilled,
      primaryContainer: AppColors.teal100,
      onPrimaryContainer: AppColors.onTint,

      secondary: AppColors.actionPrimary,
      onSecondary: AppColors.onFilled,
      secondaryContainer: AppColors.peach100,
      onSecondaryContainer: AppColors.onTint,

      tertiary: AppColors.steel700,
      onTertiary: AppColors.onFilled,
      tertiaryContainer: AppColors.steel100,
      onTertiaryContainer: AppColors.onTint,

      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: AppColors.neutral50,
      surfaceContainer: AppColors.neutral100,
      surfaceContainerHigh: AppColors.neutral200,
      surfaceContainerHighest: AppColors.neutral300,
      onSurfaceVariant: AppColors.textSecondary,

      error: AppColors.error,
      onError: AppColors.onFilled,
      errorContainer: AppColors.errorTint,
      onErrorContainer: AppColors.onTint,

      outline: AppColors.border,
      outlineVariant: AppColors.divider,
    ),

    textTheme: const TextTheme(
      displayLarge: AppTextStyles.displayXL,
      displayMedium: AppTextStyles.displayL,
      displaySmall: AppTextStyles.displayM,
      headlineMedium: AppTextStyles.displayM,
      headlineSmall: AppTextStyles.headingL,
      titleLarge: AppTextStyles.headingL,
      titleMedium: AppTextStyles.headingM,
      titleSmall: AppTextStyles.headingS,
      bodyLarge: AppTextStyles.bodyL,
      bodyMedium: AppTextStyles.bodyM,
      bodySmall: AppTextStyles.bodyS,
      labelLarge: AppTextStyles.buttonL,
      labelMedium: AppTextStyles.labelL,
      labelSmall: AppTextStyles.caption,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.displayM,
    ),

    // Cards are containers, not the star. Flat with a hairline reads calmer than
    // stacked shadows, which is what this audience needs.
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: AppColors.divider),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.actionPrimary,
        foregroundColor: AppColors.onFilled,
        disabledBackgroundColor: AppColors.neutral200,
        disabledForegroundColor: AppColors.textDisabled,
        minimumSize: const Size(minTarget, minTarget),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: AppTextStyles.buttonL,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
        elevation: 0,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.actionPrimary,
        minimumSize: const Size(minTarget, minTarget),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: AppTextStyles.buttonL,
        side: const BorderSide(color: AppColors.actionPrimary, width: 1.5),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.actionPrimary,
        minimumSize: const Size(minTarget, minTarget),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        textStyle: AppTextStyles.buttonL,
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size(minTarget, minTarget),
      ),
    ),

    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.actionPrimary,
      side: const BorderSide(color: AppColors.border),
      labelStyle: AppTextStyles.bodyS,
      secondaryLabelStyle: AppTextStyles.bodyS.copyWith(color: AppColors.onFilled),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(AppRadius.pill)),
      showCheckmark: false,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
      labelStyle: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: const OutlineInputBorder(
        borderRadius: AppRadius.button,
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AppRadius.button,
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: AppRadius.button,
        borderSide: BorderSide(color: AppColors.focusRing, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: AppRadius.button,
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
    ),

    // Snackbars for transient feedback, per Material — the app already uses
    // these for save failures, so they need to be legible.
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.neutral900,
      contentTextStyle: AppTextStyles.bodyM.copyWith(color: AppColors.onFilled),
      actionTextColor: AppColors.teal300,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      insetPadding: const EdgeInsets.all(16),
    ),

    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
      titleTextStyle: AppTextStyles.headingL,
      contentTextStyle: AppTextStyles.bodyM,
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadius.xl),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.teal100,
      elevation: 0,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => AppTextStyles.caption.copyWith(
          color: AppColors.textPrimary,
          fontWeight:
              states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 26,
          color: states.contains(WidgetState.selected)
              ? AppColors.teal900
              : AppColors.textSecondary,
        ),
      ),
    ),

    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.teal100,
      elevation: 0,
      selectedIconTheme: IconThemeData(color: AppColors.teal900, size: 26),
      unselectedIconTheme: IconThemeData(color: AppColors.textSecondary, size: 26),
      selectedLabelTextStyle: AppTextStyles.caption,
      unselectedLabelTextStyle: AppTextStyles.caption,
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.actionPrimary,
      linearTrackColor: AppColors.neutral200,
      circularTrackColor: AppColors.neutral200,
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    listTileTheme: const ListTileThemeData(
      titleTextStyle: AppTextStyles.bodyM,
      subtitleTextStyle: AppTextStyles.caption,
      iconColor: AppColors.textSecondary,
      minVerticalPadding: 12,
    ),

    splashFactory: InkSparkle.splashFactory,
  );
}
