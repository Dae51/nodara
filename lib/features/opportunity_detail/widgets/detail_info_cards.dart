// Tarjetas de título, organización, horario, horas y cupos del detalle.
import 'package:flutter/material.dart';

import 'package:nodara/core/utils/icon_mapper.dart';
import 'package:nodara/core/widgets/app_card.dart';
import 'package:nodara/core/widgets/avatar_stack.dart';
import 'package:nodara/core/widgets/impact_progress_bar.dart';
import 'package:nodara/core/widgets/info_row.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Presenta título y organización de la convocatoria recibida.
class DetailTitleCard extends StatelessWidget {
  // required obliga a pasar el dato; final impide reasignar el campo después.
  const DetailTitleCard({super.key, required this.opportunity});

  final Opportunity opportunity;

  /// Devuelve título, organización, verificación y reseñas si hay calificación.
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SECCIÓN: Título y organización
          Text(
            opportunity.titulo,
            style: AppTextStyles.headlineMobile.copyWith(height: 1.25),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primaryFixed,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  opportunity.causa.chipIcon,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Expanded reserva para la organización el ancho restante al icono.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Flexible permite partir el nombre y dejar sitio al sello.
                        Flexible(
                          child: Text(
                            opportunity.orgNombre,
                            style: AppTextStyles.titleSm,
                          ),
                        ),
                        if (opportunity.verificada) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Wrap mueve insignia y reseñas a otra línea cuando no caben.
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            'ONG Aliada Universitaria',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        // El patrón rating? toma solo valores no nulos; final
                        // conserva esa calificación sin reasignarla en este bloque.
                        if (opportunity.calificacion case final rating?)
                          Text(
                            '• $rating ★ (${opportunity.resenas} reseñas)',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Agrupa horario, sede, horas y cupos usando componentes compartidos.
class DetailSpecSheet extends StatelessWidget {
  const DetailSpecSheet({super.key, required this.opportunity});

  final Opportunity opportunity;

  /// Devuelve la ficha delegando filas a InfoRow y horas/cupos a widgets locales.
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_available,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Detalles de la Convocatoria',
                        style: AppTextStyles.titleSm,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  'Ciclo 2025-1',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // SECCIÓN: Horario y sede
          // InfoRow es del equipo; recibe textos del modelo, sin consultar datos.
          InfoRow(
            icon: Icons.calendar_month,
            label: 'Días y horario',
            title: opportunity.horario,
            subtitle: opportunity.compromiso,
          ),
          const SizedBox(height: AppSpacing.sm),
          InfoRow(
            icon: Icons.pin_drop,
            label: 'Modalidad y sede',
            title: opportunity.ubicacion,
            // Ternario: omite la referencia si viene vacía y muestra modalidad.
            subtitle: opportunity.referencia.isEmpty
                ? 'Modalidad ${opportunity.modalidad.label}'
                : 'Modalidad ${opportunity.modalidad.label} · ${opportunity.referencia}',
          ),
          const SizedBox(height: AppSpacing.sm),
          // SECCIÓN: Horas y cupos
          // Son datos estimados y getters del modelo, no resultados de una escritura.
          _HoursHighlight(hours: opportunity.horasEstimadas),
          const SizedBox(height: AppSpacing.sm),
          _SpotsBlock(opportunity: opportunity),
        ],
      ),
    );
  }
}

/// Muestra hours como estimación de la convocatoria, sin acreditar horas.
class _HoursHighlight extends StatelessWidget {
  const _HoursHighlight({required this.hours});

  final int hours;

  /// Devuelve el bloque de hours junto a las etiquetas fijas del diseño.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timer,
              size: 18,
              color: AppColors.onSecondaryFixed,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Horas de servicio social',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  '$hours horas certificadas',
                  style: AppTextStyles.titleMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              'Válido UV',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.onSecondaryFixed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lee cupos y ocupación calculados por Opportunity y los representa visualmente.
class _SpotsBlock extends StatelessWidget {
  const _SpotsBlock({required this.opportunity});

  final Opportunity opportunity;

  /// Devuelve cupos libres, barra de ocupación y avatares del modelo recibido.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        children: [
          // Wrap distribuye el texto de cupos en varias líneas si falta espacio.
          Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(Icons.group, size: 16, color: AppColors.tertiary),
              const SizedBox(width: 4),
              Text(
                'Cupos disponibles',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                '${opportunity.cuposLibres} de ${opportunity.cuposTotal} lugares libres',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // ocupacion y cuposLibres se calculan al leer el modelo (getters).
          ImpactProgressBar(value: opportunity.ocupacion, height: 8),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              AvatarStack(images: opportunity.avataresInscritos, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Ya se sumaron ${opportunity.cuposOcupados} compañeros',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
