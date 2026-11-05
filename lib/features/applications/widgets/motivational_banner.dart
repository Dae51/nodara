// Mensaje decorativo al final de MyApplicationsScreen; su texto es fijo.
// Guía de estudio R3: Javier Alejandro Paniagua Morán · carné 20245194.
// Componente de la base del equipo, sin cambios funcionales en la entrega R3.
// Referencia del aporte: docs/bitacora/javier.md y commit f0b6416.
// Índice: Mensaje motivacional.

import 'package:flutter/material.dart';

import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Presenta un mensaje fijo; no calcula avance ni fecha límite del usuario.
class MotivationalBanner extends StatelessWidget {
  /// Crea este componente visual sin datos externos.
  const MotivationalBanner({super.key});

  /// Devuelve el icono y mensaje fijo que cierra la lista de postulaciones.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      // SECCIÓN: Mensaje motivacional
      // La frase y fecha son fijas: no dependen del progreso ni del calendario.
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt,
                size: 20, color: AppColors.onSecondaryContainer),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Expanded reserva al texto el ancho restante junto al icono.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¡Vas a mitad de camino!',
                    style: AppTextStyles.labelMd),
                Text(
                  'Completá tus horas antes del 30 de Junio para validar tu certificado de fin de curso.',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
