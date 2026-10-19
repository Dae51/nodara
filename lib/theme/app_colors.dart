import 'package:flutter/material.dart';

/// Raw civic tokens extracted from the NODARA / EcháUnaMano design system
/// (`civic_pulse/DESIGN.md` and the Stitch `code.html` Tailwind config).
///
/// These are intentionally kept as plain [Color] constants (not part of the
/// [ColorScheme]) for the few places where the design uses bespoke tints
/// (amber banners, progress bars, avatar stacks, etc.).
abstract final class AppColors {
  static const primary = Color(0xFF093DB2);
  static const primaryContainer = Color(0xFF3157CB);
  static const primaryFixed = Color(0xFFDCE1FF);
  static const onPrimaryFixed = Color(0xFF001550);

  static const secondary = Color(0xFF735C00);
  static const secondaryContainer = Color(0xFFFED346);
  static const secondaryFixed = Color(0xFFFFE087);
  static const onSecondaryContainer = Color(0xFF725B00);
  static const onSecondaryFixed = Color(0xFF231A00);

  static const tertiary = Color(0xFF3D466E);
  static const tertiaryFixed = Color(0xFFDDE1FF);
  static const onTertiaryFixed = Color(0xFF0E193E);

  static const surface = Color(0xFFFBF9F3);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF5F3EE);
  static const surfaceContainer = Color(0xFFF0EEE8);
  static const surfaceContainerHigh = Color(0xFFEAE8E2);
  static const surfaceContainerHighest = Color(0xFFE4E2DD);

  static const onSurface = Color(0xFF1B1C19);
  static const onSurfaceVariant = Color(0xFF444653);
  static const outline = Color(0xFF747685);
  static const outlineVariant = Color(0xFFC4C5D6);

  static const error = Color(0xFFBA1A1A);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
}
