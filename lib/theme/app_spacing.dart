/// Escalas de espaciado y radios del sistema de diseño NODARA.
library;

/// Spacing scale (8pt grid with 4pt sub-increments).
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

/// Radius scale adapted to Material 3.
abstract final class AppRadius {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const pill = 999.0;
}
