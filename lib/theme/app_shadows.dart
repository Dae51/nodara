import 'package:flutter/material.dart';

/// Sombras del sistema de diseño. Son los mismos valores que antes estaban
/// repetidos en varios widgets; solo se centralizan aquí.
abstract final class AppShadows {
  /// Tarjetas y superficies blancas (AppCard, tarjetas de postulación).
  static const card = <BoxShadow>[
    BoxShadow(color: Color(0x0F1B254B), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A3157CB), blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// Barra de búsqueda del feed.
  static const searchBar = <BoxShadow>[
    BoxShadow(color: Color(0x0F1B254B), blurRadius: 4, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A3157CB), blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// Marca del logo.
  static const logo = <BoxShadow>[
    BoxShadow(color: Color(0x141B1C19), blurRadius: 4, offset: Offset(0, 1)),
  ];

  /// Chips de filtro.
  static const chip = <BoxShadow>[
    BoxShadow(color: Color(0x141B1C19), blurRadius: 3, offset: Offset(0, 1)),
  ];

  /// Barra inferior fija (botón de postularse).
  static const bottomBar = <BoxShadow>[
    BoxShadow(color: Color(0x141B254B), blurRadius: 20, offset: Offset(0, -4)),
  ];

  /// Halo amarillo del avatar en el saludo.
  static const avatarGlow = <BoxShadow>[
    BoxShadow(color: Color(0x59FED346), blurRadius: 8, offset: Offset(0, 2)),
  ];
}
