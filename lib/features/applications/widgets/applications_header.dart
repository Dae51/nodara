// Encabezados de MyApplicationsScreen: identidad, avisos y contador de activas.
// Guía de estudio R3: Javier Alejandro Paniagua Morán · carné 20245194.
// R3 simplificó controles de la base y mantuvo avisos solo cuando existe callback.
// Referencia del aporte: docs/bitacora/javier.md y commit f0b6416.
// Índice: ApplicationsHeader; ApplicationsSubHeader.

import 'package:flutter/material.dart';

import 'package:nodara/core/widgets/app_logo.dart';
import 'package:nodara/core/widgets/remote_image.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Muestra logo, avatar y avisos; el callback llega desde HomeShell por la pantalla.
class ApplicationsHeader extends StatelessWidget {
  // required obliga a pasar el dato; final impide reasignar el campo después.
  const ApplicationsHeader({
    super.key,
    required this.avatarUrl,
    this.onNotifications,
  });

  final String avatarUrl;
  final VoidCallback? onNotifications;

  /// Devuelve identidad y avatar; agrega avisos solo si recibió onNotifications.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // SECCIÓN: Encabezado
          // Expanded reparte el ancho restante sin desplazar avatar ni avisos.
          Expanded(
            child: Row(
              children: [
                const AppLogo(markSize: 36, showWordmark: false),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NODARA',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text('Mis Postulaciones', style: AppTextStyles.titleMd),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ? en el tipo permite null. Solo se dibuja el botón si hay acción.
          // El toque llama al callback que HomeShell pasó a MyApplicationsScreen.
          if (onNotifications != null)
            IconButton(
              tooltip: 'Notificaciones',
              onPressed: onNotifications,
              icon: const Icon(
                Icons.notifications_none,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          RemoteImage(
            url: avatarUrl,
            width: 32,
            height: 32,
            icon: Icons.person,
            borderRadius: BorderRadius.circular(32),
          ),
        ],
      ),
    );
  }
}

/// Muestra el título y count, que corresponde a postulaciones activas.
class ApplicationsSubHeader extends StatelessWidget {
  const ApplicationsSubHeader({super.key, required this.count});

  final int count;

  /// Devuelve el título y el contador count recibido de la pantalla.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text('Mis Postulaciones', style: AppTextStyles.headlineSm),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            // SECCIÓN: Contador de activas
            // count llega de provider.activas.length, no del total de solicitudes.
            child: Text(
              '$count',
              style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
