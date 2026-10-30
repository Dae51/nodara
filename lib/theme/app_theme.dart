import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

export 'app_spacing.dart';

/// Typography scale from the Civic Pulse design system, rendered with
/// Roboto Flex at the exact sizes/weights/line-heights specified in DESIGN.md.
abstract final class AppTextStyles {
  static TextStyle _roboto({
    required double size,
    required FontWeight weight,
    required double height,
    double spacing = 0,
  }) =>
      GoogleFonts.robotoFlex(
        fontSize: size,
        fontWeight: weight,
        height: height / size,
        letterSpacing: spacing * size,
        color: AppColors.onSurface,
      );

  static final displayLg =
      _roboto(size: 40, weight: FontWeight.w700, height: 48, spacing: -0.02);
  static final headlineLg =
      _roboto(size: 32, weight: FontWeight.w700, height: 40, spacing: -0.01);
  static final headlineMobile =
      _roboto(size: 26, weight: FontWeight.w700, height: 34, spacing: -0.01);
  static final headlineMd =
      _roboto(size: 24, weight: FontWeight.w600, height: 32);
  static final headlineSm =
      _roboto(size: 20, weight: FontWeight.w600, height: 28);
  static final titleLg =
      _roboto(size: 18, weight: FontWeight.w600, height: 24);
  static final titleMd =
      _roboto(size: 16, weight: FontWeight.w600, height: 24, spacing: 0.01);
  static final titleSm =
      _roboto(size: 14, weight: FontWeight.w600, height: 20, spacing: 0.01);
  static final bodyLg =
      _roboto(size: 16, weight: FontWeight.w400, height: 24, spacing: 0.01);
  static final bodyMd =
      _roboto(size: 14, weight: FontWeight.w400, height: 20, spacing: 0.01);
  static final bodySm =
      _roboto(size: 12, weight: FontWeight.w400, height: 16, spacing: 0.02);
  static final labelLg =
      _roboto(size: 14, weight: FontWeight.w600, height: 20, spacing: 0.02);
  static final labelMd =
      _roboto(size: 12, weight: FontWeight.w600, height: 16, spacing: 0.03);
  static final labelSm =
      _roboto(size: 11, weight: FontWeight.w600, height: 16, spacing: 0.04);
}

abstract final class AppTheme {
  static const _scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.primaryFixed,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFF555E88),
    onTertiaryContainer: Color(0xFFD3DAFF),
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceDim: Color(0xFFDBDAD4),
    surfaceBright: AppColors.surface,
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    inverseSurface: Color(0xFF30312D),
    onInverseSurface: Color(0xFFF2F1EB),
    inversePrimary: Color(0xFFB6C4FF),
    surfaceTint: Color(0xFF2E55C9),
    primaryFixed: AppColors.primaryFixed,
    primaryFixedDim: Color(0xFFB6C4FF),
    onPrimaryFixed: AppColors.onPrimaryFixed,
    onPrimaryFixedVariant: Color(0xFF033AB0),
    secondaryFixed: AppColors.secondaryFixed,
    secondaryFixedDim: Color(0xFFECC236),
    onSecondaryFixed: AppColors.onSecondaryFixed,
    onSecondaryFixedVariant: Color(0xFF574500),
    tertiaryFixed: AppColors.tertiaryFixed,
    tertiaryFixedDim: Color(0xFFBBC4F4),
    onTertiaryFixed: AppColors.onTertiaryFixed,
    onTertiaryFixedVariant: Color(0xFF3B456C),
  );

  static ThemeData get light {
    final textTheme = TextTheme(
      displayLarge: AppTextStyles.displayLg,
      headlineLarge: AppTextStyles.headlineLg,
      headlineMedium: AppTextStyles.headlineMd,
      headlineSmall: AppTextStyles.headlineSm,
      titleLarge: AppTextStyles.titleLg,
      titleMedium: AppTextStyles.titleMd,
      titleSmall: AppTextStyles.titleSm,
      bodyLarge: AppTextStyles.bodyLg,
      bodyMedium: AppTextStyles.bodyMd,
      bodySmall: AppTextStyles.bodySm,
      labelLarge: AppTextStyles.labelLg,
      labelMedium: AppTextStyles.labelMd,
      labelSmall: AppTextStyles.labelSm,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: _scheme,
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleMd,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: AppTextStyles.labelLg,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelLg,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        selectedColor: AppColors.secondaryContainer,
        side: const BorderSide(color: AppColors.outlineVariant),
        labelStyle: AppTextStyles.labelMd,
        secondaryLabelStyle:
            AppTextStyles.labelMd.copyWith(color: AppColors.onSecondaryContainer),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.outline),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.secondaryContainer,
        indicatorShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        height: 80,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppTextStyles.labelSm.copyWith(color: AppColors.onSurface)
              : AppTextStyles.labelSm.copyWith(color: AppColors.onSurfaceVariant),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? AppColors.onSecondaryContainer
                : AppColors.onSurfaceVariant,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.onSurface,
        contentTextStyle:
            AppTextStyles.labelMd.copyWith(color: AppColors.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceContainerHighest,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.onSurfaceVariant,
        labelStyle: AppTextStyles.labelMd,
        unselectedLabelStyle: AppTextStyles.labelMd,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }
}
