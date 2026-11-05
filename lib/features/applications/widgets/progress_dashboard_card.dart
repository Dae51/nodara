// Resumen visual de horas que MyApplicationsScreen muestra si el usuario tiene meta.
// Guía de estudio R3: Javier Alejandro Paniagua Morán · carné 20245194.
// Los cálculos y la tarjeta vienen de la base; R3 ajustó distribución y etiqueta
// Activas.
// Referencia del aporte: docs/bitacora/javier.md y commit f0b6416.
// Índice: Horas y porcentaje; Barra de progreso; Contadores.

import 'package:flutter/material.dart';

import 'package:nodara/core/widgets/stat_pill.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Representa métricas ya calculadas por los getters de ApplicationsProvider.
class ProgressDashboardCard extends StatelessWidget {
  // required obliga a pasar el dato; final impide reasignar el campo después.
  const ProgressDashboardCard({
    super.key,
    required this.horasCompletadas,
    required this.horasRequeridas,
    required this.horasFaltantes,
    required this.progreso,
    required this.progresoPorcentaje,
    required this.activas,
    required this.acreditadas,
  });

  final int horasCompletadas;
  final int horasRequeridas;
  final int horasFaltantes;
  // progreso es fracción 0..1; progresoPorcentaje es el entero que se muestra.
  // activas/acreditadas cuentan postulaciones, no horas.
  final double progreso;
  final int progresoPorcentaje;
  final int activas;
  final int acreditadas;

  /// Devuelve horas, barra y contadores; el cálculo ya llegó desde el Provider.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -8,
            child: Icon(
              Icons.workspace_premium,
              size: 72,
              color: AppColors.onSecondaryContainer.withValues(alpha: 0.15),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECCIÓN: Horas y porcentaje
              // Wrap permite que encabezado e insignia salten de línea.
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'PROGRESO UNIVERSITARIO',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.onSecondaryContainer,
                      letterSpacing: 1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.school,
                          size: 14,
                          color: AppColors.onSecondaryFixed,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Servicio Social',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.onSecondaryFixed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '$horasCompletadas',
                    style: AppTextStyles.displayLg.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '/ $horasRequeridas',
                    style: AppTextStyles.headlineMd.copyWith(
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'horas',
                    style: AppTextStyles.titleSm.copyWith(
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  text: 'Horas de Servicio Social Acumuladas ',
                  children: [
                    TextSpan(
                      text: '($progresoPorcentaje% del requisito completado)',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // SECCIÓN: Barra de progreso
              // progreso es fracción 0..1; el porcentaje es solo texto.
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Container(
                  height: 10,
                  color: AppColors.surfaceContainerLowest.withValues(
                    alpha: 0.7,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      // El ternario deja una marca mínima con cero horas;
                      // es un detalle visual, no cambia el progreso del Provider.
                      widthFactor: progreso == 0 ? 0.001 : progreso,
                      child: Container(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // SECCIÓN: Contadores
                  // Wrap mantiene legibles activas, acreditadas y horas faltantes.
                  StatPill(
                    label: 'Activas: $activas',
                    showDot: true,
                    background: AppColors.surfaceContainerLowest,
                    foreground: AppColors.onSurface,
                    bold: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                  ),
                  StatPill(
                    label:
                        '$acreditadas ${acreditadas == 1 ? 'Acreditado' : 'Acreditados'}',
                    icon: Icons.verified,
                    background: AppColors.surfaceContainerLowest,
                    foreground: AppColors.onSurface,
                    bold: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                  ),
                  StatPill(
                    label: horasFaltantes == 0
                        ? '¡Meta cumplida!'
                        : 'Faltan $horasFaltantes hrs',
                    background: AppColors.onSecondaryContainer.withValues(
                      alpha: 0.1,
                    ),
                    foreground: AppColors.onSecondaryContainer,
                    bold: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
