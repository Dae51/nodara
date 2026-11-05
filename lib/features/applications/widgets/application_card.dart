// Tarjeta de cada elemento que MyApplicationsScreen recibe del Provider.
// Guía de estudio R3: Javier Alejandro Paniagua Morán · carné 20245194.
// R3 amplió estados y motivos legibles y conectó las acciones sobre la tarjeta base.
// Referencia del aporte: docs/bitacora/javier.md y commit f0b6416.
// Índice: Estado y horas; Imagen y organización; _InfoBox; ApplicationActions.

import 'package:flutter/material.dart';

import 'package:nodara/core/utils/icon_mapper.dart';
import 'package:nodara/core/widgets/remote_image.dart';
import 'package:nodara/core/widgets/stat_pill.dart';
import 'package:nodara/data/models/application.dart';
import 'package:nodara/features/applications/widgets/application_actions.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_shadows.dart';
import 'package:nodara/theme/app_theme.dart';

/// Presenta una Application y pasa onWithdraw a ApplicationActions.
class ApplicationCard extends StatelessWidget {
  // required obliga a pasar el dato; final impide reasignar el campo después.
  const ApplicationCard({
    super.key,
    required this.application,
    required this.onWithdraw,
  });

  final Application application;
  final VoidCallback onWithdraw;

  /// Devuelve estado, horas, imagen y contexto; delega botones a ApplicationActions.
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
          // SECCIÓN: Estado y horas
          // Wrap pasa una insignia a otra línea si texto y horas no caben juntos.
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _StatusBadge(estado: application.estado),
              _RewardPill(application: application),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECCIÓN: Imagen y organización
              // Se usan los datos copiados en Application por el Repository.
              RemoteImage(
                url: application.imagenUrl,
                width: 56,
                height: 56,
                icon: application.causa.chipIcon,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Expanded ocupa el ancho restante al lado de la imagen.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.oportunidadTitulo,
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
                        // Flexible deja partir el nombre de la organización.
                        Flexible(
                          child: Text(
                            application.orgNombre,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
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
          // SECCIÓN: Botones
          // onWithdraw viene de la pantalla y abre confirmación cuando se pulsa.
          ApplicationActions(application: application, onWithdraw: onWithdraw),
        ],
      ),
    );
  }
}

/// Traduce el estado recibido a icono, colores y etiqueta legible.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.estado});

  final EstadoPostulacion estado;

  /// Devuelve una insignia con icono y texto para reconocer el estado sin depender del
  /// color.
  @override
  Widget build(BuildContext context) {
    // El estado se comunica con ícono + texto, no solo con color.
    // final impide reasignar; (icon, bg, fg) descompone una tupla
    // elegida por switch para usar icono, fondo y texto del mismo estado.
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
      _ => (
        Icons.pending_actions,
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
              style: AppTextStyles.labelSm.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Distingue horas proyectadas y acreditadas mediante StatPill del equipo.
class _RewardPill extends StatelessWidget {
  const _RewardPill({required this.application});

  final Application application;

  /// Devuelve un StatPill con horas y colores elegidos según el estado.
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
      // Ternarios: elige colores según completada, pendiente u otro estado.
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

/// Deriva mensaje y motivo del estado recibido, sin guardar nuevos datos.
class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.application});

  final Application application;

  /// Devuelve el mensaje que corresponde al estado y al motivo de application.
  @override
  Widget build(BuildContext context) {
    // SECCIÓN: Mensaje de estado y motivo
    // ?? usa el mensaje alternativo solo si motivo es null. El texto se deriva
    // del estado de Application; no se guarda una segunda copia del mensaje.
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
        application.motivo ?? 'La organización no indicó un motivo',
      ),
      EstadoPostulacion.retirado => (
        Icons.undo,
        'Te retiraste de esta convocatoria',
        application.motivo ?? 'Puedes volver a postularte si sigue vigente',
      ),
      _ => (
        Icons.pending_actions,
        application.estado.label,
        application.motivo ?? 'La organización está actualizando tu solicitud',
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
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
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
