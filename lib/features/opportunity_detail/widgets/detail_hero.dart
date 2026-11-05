// Imagen y acciones superiores que utiliza OpportunityDetailScreen.
import 'package:flutter/material.dart';

import 'package:nodara/core/utils/icon_mapper.dart';
import 'package:nodara/core/widgets/remote_image.dart';
import 'package:nodara/data/models/opportunity.dart';
import 'package:nodara/theme/app_colors.dart';
import 'package:nodara/theme/app_theme.dart';

/// Superpone controles a la imagen; delega compartir y favoritos a la pantalla.
class DetailHero extends StatelessWidget {
  // required obliga a pasar el dato; final impide reasignar el campo después.
  const DetailHero({
    super.key,
    required this.opportunity,
    required this.isFavorite,
    required this.onShare,
    required this.onBookmark,
  });

  final Opportunity opportunity;
  final bool isFavorite;
  final VoidCallback onShare;
  final VoidCallback onBookmark;

  /// Devuelve la imagen con controles superpuestos y el aviso inferior.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 288,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // SECCIÓN: Imagen
          // Stack coloca imagen, degradado, botones y aviso en capas.
          RemoteImage(
            url: opportunity.imagenUrl,
            icon: opportunity.causa.chipIcon,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xCC1B1C19), Colors.transparent],
              ),
            ),
          ),
          // SECCIÓN: Compartir y favoritos
          // onShare copia texto y onBookmark alterna favorito en la pantalla.
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                _CircleAction(icon: Icons.share, onTap: onShare),
                const SizedBox(width: AppSpacing.sm),
                _CircleAction(
                  // Ternario: icono lleno si es favorito, contorno si no lo es.
                  icon: isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  onTap: onBookmark,
                ),
              ],
            ),
          ),
          // SECCIÓN: Aviso de convocatoria
          // Este aviso es texto fijo; no evalúa cupos ni fecha de cierre.
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.bolt,
                    size: 16,
                    color: AppColors.onSecondaryFixed,
                  ),
                  const SizedBox(width: 4),
                  // Flexible permite varias líneas dentro del ancho del aviso.
                  Flexible(
                    child: Text(
                      'Convocatoria Abierta · Cupos Limitados',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSecondaryFixed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón circular que ejecuta onTap y reserva un área táctil de 48 × 48.
class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  /// Devuelve un control táctil que ejecuta onTap sin modificar datos aquí.
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        // InkWell ejecuta el callback recibido al tocar y dibuja la respuesta táctil.
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, size: 20, color: AppColors.onSurface),
        ),
      ),
    );
  }
}
