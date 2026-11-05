// Barra inferior de OpportunityDetailScreen: horas y acción de postulación.
import 'package:flutter/material.dart';

import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_shadows.dart';
import 'package:nodara/theme/app_theme.dart';

/// Presenta horas estimadas y delega el toque a onApply, recibido del detalle.
class ApplyBar extends StatelessWidget {
  // required obliga a pasar el dato; final impide reasignar el campo después.
  const ApplyBar({
    super.key,
    required this.hours,
    required this.hasApplied,
    required this.onApply,
    this.isBusy = false,
  });

  final int hours;
  // hasApplied indica una solicitud no retirada; isBusy indica carga o envío.
  final bool hasApplied;
  // ? permite ausencia de acción: null deshabilita el botón sin guardar nada.
  final VoidCallback? onApply;
  final bool isBusy;

  /// Devuelve horas y botón; usa isBusy y hasApplied para elegir su estado visual.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: AppShadows.bottomBar,
      ),
      // SafeArea protege la barra de la navegación del sistema; top:false
      // evita margen superior porque esta pieza está al pie de la pantalla.
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 12,
          ),
          child: Row(
            children: [
              // SECCIÓN: Horas estimadas
              // Llegan de la convocatoria; aquí no se suman horas acreditadas.
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reconocimiento',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '$hours hrs',
                        style: AppTextStyles.titleLg.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              // SECCIÓN: Botón de postulación
              // Expanded entrega al botón el ancho sobrante junto a las horas.
              Expanded(
                child: FilledButton(
                  // El ternario elige null mientras carga/envía. En otro caso,
                  // onApply abre confirmación o la lista, según decida la pantalla.
                  onPressed: isBusy ? null : onApply,
                  style: FilledButton.styleFrom(
                    backgroundColor: hasApplied
                        ? AppColors.tertiary
                        : AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        hasApplied ? Icons.task_alt : Icons.how_to_reg,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      // Flexible deja partir la etiqueta sin desplazar el icono.
                      Flexible(
                        child: Text(
                          isBusy
                              ? 'Cargando…'
                              : hasApplied
                              ? 'Ver mi postulación'
                              : 'Postularme ahora',
                          style: AppTextStyles.labelLg.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
