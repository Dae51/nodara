import 'package:flutter/material.dart';

import 'package:nodara/core/utils/icon_mapper.dart';
import 'package:nodara/core/widgets/remote_image.dart';
import 'package:nodara/core/widgets/stat_pill.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/features/applications/widgets/application_actions.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_shadows.dart';
import 'package:nodara/theme/app_theme.dart';

/// Tarjeta de una postulación en "Mis Postulaciones".
class ApplicationCard extends StatelessWidget {
  const ApplicationCard({
    super.key,
    required this.application,
    required this.onWithdraw,
  });

  final Application application;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _StatusBadge(estado: application.estado)),
              const SizedBox(width: AppSpacing.sm),
              _RewardPill(application: application),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RemoteImage(
                url: application.imagenUrl,
                width: 56,
                height: 56,
                icon: application.causa.chipIcon,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.oportunidadTitulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMd,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          switch (application.estado) {
                            EstadoPostulacion.pendiente => Icons.nature_people,
                            EstadoPostulacion.completado =>
                              Icons.volunteer_activism,
                            _ => Icons.apartment,
                          },
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            application.orgNombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoBox(application: application),
          const SizedBox(height: AppSpacing.sm),
          ApplicationActions(
            application: application,
            onWithdraw: onWithdraw,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.estado});

  final EstadoPostulacion estado;

  @override
  Widget build(BuildContext context) {
    // El estado se comunica con ícono + texto, no solo con color.
    final (icon, bg, fg) = switch (estado) {
      EstadoPostulacion.aceptado => (
          Icons.autorenew,
          AppColors.secondaryContainer,
          AppColors.onSecondaryContainer,
        ),
      EstadoPostulacion.pendiente => (
          Icons.hourglass_top,
          AppColors.surfaceContainerHigh,
          AppColors.onSurfaceVariant,
        ),
      EstadoPostulacion.completado => (
          Icons.check_circle,
          AppColors.primary.withValues(alpha: 0.1),
          AppColors.primary,
        ),
      EstadoPostulacion.rechazado => (
          Icons.cancel,
          AppColors.error.withValues(alpha: 0.1),
          AppColors.error,
        ),
      EstadoPostulacion.retirado => (
          Icons.history,
          AppColors.surfaceContainerHigh,
          AppColors.onSurfaceVariant,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              estado.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSm
                  .copyWith(color: fg, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardPill extends StatelessWidget {
  const _RewardPill({required this.application});

  final Application application;

  @override
  Widget build(BuildContext context) {
    final estado = application.estado;
    final completed = estado == EstadoPostulacion.completado;
    final pending = estado == EstadoPostulacion.pendiente;
    final label = switch (estado) {
      EstadoPostulacion.pendiente =>
        '+${application.horasEstimadas} hrs proyectadas',
      EstadoPostulacion.completado =>
        '${application.horasQueCuentan} hrs acreditadas',
      _ => '+${application.horasEstimadas} hrs',
    };
    return StatPill(
      label: label,
      background: completed
          ? AppColors.secondaryContainer
          : pending
              ? AppColors.surfaceContainer
              : AppColors.primaryFixed,
      foreground: completed
          ? AppColors.onSecondaryContainer
          : pending
              ? AppColors.onSurfaceVariant
              : AppColors.primary,
      bold: !pending,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    );
  }
}

/// Caja de contexto: el texto se deriva del estado (no se guarda).
class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.application});

  final Application application;

  @override
  Widget build(BuildContext context) {
    final (icon, title, subtitle) = switch (application.estado) {
      EstadoPostulacion.pendiente => (
          Icons.hourglass_top,
          'Postulación enviada',
          'En revisión por el equipo coordinador',
        ),
      EstadoPostulacion.aceptado => (
          Icons.calendar_month,
          'Próxima sesión obligatoria',
          application.horario.isEmpty
              ? 'La organización te contactará'
              : application.horario,
        ),
      EstadoPostulacion.completado => (
          Icons.verified,
          'Horas acreditadas',
          '${application.horasQueCuentan} hrs validadas por ${application.orgNombre}',
        ),
      EstadoPostulacion.rechazado => (
          Icons.info_outline,
          'Postulación no aceptada',
          application.motivo ?? 'Cupos completos o perfil no compatible',
        ),
      EstadoPostulacion.retirado => (
          Icons.undo,
          'Te retiraste de esta convocatoria',
          'Puedes volver a postularte si sigue vigente',
        ),
    };
    final completed = application.estado == EstadoPostulacion.completado;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: application.estado == EstadoPostulacion.pendiente
                ? AppColors.secondary
                : AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      AppTextStyles.labelSm.copyWith(color: AppColors.onSurface),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (completed)
            const Icon(
              Icons.workspace_premium,
              size: 20,
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }
}
