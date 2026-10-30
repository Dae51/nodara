import 'package:flutter/material.dart';

import 'package:nodara/data/models/opportunity.dart';

/// Íconos de cada causa. Viven en la UI porque los modelos no deben
/// conocer `IconData`.
extension CausaIcons on Causa {
  /// Ícono del chip de filtro.
  IconData get chipIcon => switch (this) {
        Causa.medioambiente => Icons.eco,
        Causa.animales => Icons.pets,
        Causa.comunidades => Icons.groups,
        Causa.educacion => Icons.school,
        Causa.salud => Icons.favorite,
        Causa.cultura => Icons.palette,
        Causa.emergencias => Icons.health_and_safety,
      };

  /// Ícono de la insignia sobre la imagen de la tarjeta.
  IconData get badgeIcon => switch (this) {
        Causa.medioambiente => Icons.forest,
        Causa.animales => Icons.pets,
        Causa.comunidades => Icons.volunteer_activism,
        Causa.educacion => Icons.school,
        Causa.salud => Icons.medical_services,
        Causa.cultura => Icons.palette,
        Causa.emergencias => Icons.health_and_safety,
      };
}

const _benefitIcons = <String, IconData>{
  'certificado': Icons.badge_outlined,
  'seguro': Icons.health_and_safety_outlined,
  'refrigerio': Icons.local_cafe_outlined,
  'eco': Icons.eco_outlined,
  'transporte': Icons.directions_bus_outlined,
  'capacitacion': Icons.school_outlined,
};

/// Convierte el `iconKey` guardado en Firestore a un ícono.
IconData iconFromKey(String key) => _benefitIcons[key] ?? Icons.star_outline;
